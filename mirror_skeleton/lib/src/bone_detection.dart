part of 'render_mirror_skeleton.dart';

class _IgnoredRegion {
  final RenderBox renderObject;
  final Offset offset;
  _IgnoredRegion(this.renderObject, this.offset);
}

/// Identities we look up by walking the *element* tree (not the render
/// tree). Modern Flutter renders Switch / Checkbox / Radio all through the
/// same `RenderCustomPaint`, so the only way to tell them apart at runtime
/// is via the owning [Widget]. Detection consults this map first; if a
/// node's identity is known the appropriate widget-shaped bone is emitted.
enum _WidgetKind {
  progress,
  icon,
  switchControl,
  radio,
  checkbox,
  slider,
  textField,
}

/// Per-node flags computed in a single bottom-up walk and queried in O(1)
/// during top-down detection. Replaces a recursive subtree query that ran
/// from every leaf candidate (O(N²) on deep trees).
class _DescFlags {
  /// Some strict descendant would itself produce a bone if reached.
  final bool hasContent;

  /// Some strict descendant is a form control (Switch / Radio / Checkbox /
  /// Slider / Editable). Lets a wrapping `RenderPhysicalShape` know to
  /// recurse instead of stamping a generic pill over the real control.
  final bool hasFormControl;

  const _DescFlags({required this.hasContent, required this.hasFormControl});
}

/// Ambient context passed down through bone detection so that container-like
/// clippers ([ClipRRect], [ClipOval]) can imprint their shape onto the bones
/// of their (otherwise shape-less) descendants — most importantly images,
/// containers, and icons.
class _DetectContext {
  final double? clipRadius;
  final bool clipOval;
  const _DetectContext({this.clipRadius, this.clipOval = false});
  static const empty = _DetectContext();
  _DetectContext withClipRadius(double r) =>
      _DetectContext(clipRadius: r, clipOval: false);
  _DetectContext asOval() => const _DetectContext(clipOval: true);
}

/// Backdrop bones (cards, panels, gradient containers wrapping content)
/// render at this fraction of the bone color's alpha. Low enough that
/// inner content bones at full alpha still pop visually, high enough
/// that the card silhouette is clearly visible.
const double _backdropOpacity = 0.4;

bool _isColoredBox(RenderObject ro) {
  return ro.runtimeType.toString() == '_RenderColoredBox';
}

/// Form-control / TextField render objects use private `_RenderXxx`
/// types. Match by name pattern so we cover all subclasses and keep
/// working across Flutter versions.
///
/// Note: progress indicators are NOT in this list — see
/// `_isProgressOrLoader`.
bool _matchesCustomLeafName(RenderObject ro) {
  final name = ro.runtimeType.toString();
  return name.contains('Toggleable') ||
      name.contains('Switch') ||
      name.contains('Checkbox') ||
      name.contains('Radio') ||
      name.contains('Slider') ||
      name.contains('Editable');
}

bool _isPureTranslation(Matrix4 m) {
  // Upper-left 3x3 must be the identity for the matrix to be a pure
  // translation. Allow tiny floating-point error.
  const eps = 1e-6;
  return (m.entry(0, 0) - 1).abs() < eps &&
      (m.entry(1, 1) - 1).abs() < eps &&
      (m.entry(2, 2) - 1).abs() < eps &&
      m.entry(0, 1).abs() < eps &&
      m.entry(0, 2).abs() < eps &&
      m.entry(1, 0).abs() < eps &&
      m.entry(1, 2).abs() < eps &&
      m.entry(2, 0).abs() < eps &&
      m.entry(2, 1).abs() < eps;
}

extension _BoneDetection on RenderMirrorSkeleton {
  /// Walk descendant elements once and record, for each owning widget's
  /// outermost render object, which control kind it is. Detection consults
  /// this map first so it can dispatch on real widget identity rather than
  /// the (often ambiguous) render-object type name.
  void _populateKindMap() {
    _kindMap.clear();
    final root = _ownerElement;
    if (root == null) return;
    void visit(Element e) {
      final w = e.widget;
      _WidgetKind? kind;
      if (w is CircularProgressIndicator ||
          w is LinearProgressIndicator ||
          w is RefreshProgressIndicator) {
        kind = _WidgetKind.progress;
      } else if (w is Icon) {
        kind = _WidgetKind.icon;
      } else if (w is Switch) {
        kind = _WidgetKind.switchControl;
      } else if (w is Radio) {
        kind = _WidgetKind.radio;
      } else if (w is Checkbox) {
        kind = _WidgetKind.checkbox;
      } else if (w is Slider) {
        kind = _WidgetKind.slider;
      } else if (w is TextField || w is TextFormField) {
        kind = _WidgetKind.textField;
      }
      if (kind != null) {
        final ro = e.renderObject;
        // Multiple wrapper elements (StatelessWidget/StatefulWidget chain)
        // resolve to the same render object — keep the outermost (first)
        // identity so a Switch wrapped in a Tooltip stays a "Switch", not
        // whatever its inner wrapper happened to be.
        if (ro != null) _kindMap.putIfAbsent(ro, () => kind!);
      }
      e.visitChildren(visit);
    }
    root.visitChildren(visit);
  }

  /// Position of [renderObject] in this render object's local coordinates.
  /// Uses [RenderBox.localToGlobal] with `this` as ancestor so that all
  /// parent-data flavours (box, sliver, stack, etc.) are handled uniformly.
  Offset _positionOf(RenderObject renderObject) {
    if (renderObject is! RenderBox) return Offset.zero;
    try {
      return renderObject.localToGlobal(Offset.zero, ancestor: this);
    } catch (_) {
      return Offset.zero;
    }
  }

  /// Cumulative transform from [renderObject] up to this skeleton's
  /// coordinate space, but only when the transform contains rotation,
  /// scale, or skew. Pure translations return null because [_positionOf]
  /// already captures them and a null transform lets the fast paint path
  /// run without `canvas.save()`/`transform()`.
  Matrix4? _transformOf(RenderObject renderObject) {
    if (renderObject is! RenderBox) return null;
    try {
      final m = renderObject.getTransformTo(this);
      if (_isPureTranslation(m)) return null;
      return m;
    } catch (_) {
      return null;
    }
  }

  // ---- O(N) descendant precomputation ----

  /// True when [ro] (considered alone) would emit a bone if encountered
  /// during the top-down detection walk. Used by [_populateContentCache] to
  /// build the strict-descendants cache in a single bottom-up pass.
  bool _isContentful(RenderObject ro) {
    final kind = _kindMap[ro];
    if (kind == _WidgetKind.progress) return false;
    if (kind != null) return true; // form controls / icons emit bones
    if (ro is RenderSkeletonIgnore) return false;
    if (_isProgressOrLoader(ro)) return false;
    if (ro is RenderParagraph) return ro.text.toPlainText().isNotEmpty;
    if (ro is RenderImage) return true;
    if (ro is RenderDecoratedBox) {
      final d = ro.decoration;
      if (d is BoxDecoration) {
        final c = d.color;
        final hasVisibleColor = c != null && c.a > 0;
        return hasVisibleColor || d.gradient != null || d.image != null;
      }
      return false;
    }
    if (_isColoredBox(ro)) return true;
    if (ro is RenderPhysicalShape || ro is RenderPhysicalModel) return true;
    if (_matchesCustomLeafName(ro)) return true;
    if (ro is RenderCustomPaint) return true;
    return false;
  }

  /// True when [ro]'s subtree contains a form control. Drives the
  /// [_isPhysicalShapeLeaf] decision so a wrapping Material/InkWell yields
  /// to the Switch / Radio / Checkbox / Slider underneath instead of
  /// stamping a featureless pill on top.
  bool _isFormControlNode(RenderObject ro) {
    final kind = _kindMap[ro];
    if (kind == _WidgetKind.switchControl ||
        kind == _WidgetKind.radio ||
        kind == _WidgetKind.checkbox ||
        kind == _WidgetKind.slider ||
        kind == _WidgetKind.textField) {
      return true;
    }
    return _matchesCustomLeafName(ro);
  }

  /// Bottom-up traversal that records, for every node, the flags listed in
  /// [_DescFlags]. The detection pass then queries them in O(1) instead of
  /// re-walking the subtree from every candidate leaf — the original
  /// implementation was quadratic on deep trees (e.g. long ListViews) and
  /// showed up as visible jank when `isLoading` first flipped on.
  _DescFlags _populateContentCache(RenderObject ro) {
    if (ro is RenderSkeletonIgnore || _isProgressOrLoader(ro)) {
      const flags = _DescFlags(hasContent: false, hasFormControl: false);
      _descCache[ro] = flags;
      return flags;
    }
    var anyContent = false;
    var anyFormControl = false;
    ro.visitChildren((child) {
      final childFlags = _populateContentCache(child);
      if (_isContentful(child) || childFlags.hasContent) anyContent = true;
      if (_isFormControlNode(child) || childFlags.hasFormControl) {
        anyFormControl = true;
      }
    });
    final flags = _DescFlags(
      hasContent: anyContent,
      hasFormControl: anyFormControl,
    );
    _descCache[ro] = flags;
    return flags;
  }

  bool _hasBoneDescendant(RenderObject root) {
    return _descCache[root]?.hasContent ?? false;
  }

  bool _hasFormControlDescendant(RenderObject root) {
    return _descCache[root]?.hasFormControl ?? false;
  }

  /// True for `CircularProgressIndicator`, `LinearProgressIndicator`,
  /// `RefreshProgressIndicator` (matched via the element-tree kind map),
  /// and any third-party widget whose render-object class name contains
  /// `Progress`, `Loader`, or `Spinner`. Returning true here causes the
  /// subtree to be skipped entirely during detection — no bone, no
  /// recursion, no overlay — so a real spinner can keep ticking instead
  /// of being replaced with a meaningless pill.
  bool _isProgressOrLoader(RenderObject ro) {
    if (_kindMap[ro] == _WidgetKind.progress) return true;
    final name = ro.runtimeType.toString();
    return name.contains('Progress') ||
        name.contains('Loader') ||
        name.contains('Spinner');
  }

  bool _isPhysicalShapeLeaf(RenderBox r) {
    if (r.size.isEmpty) return false;
    // A wrapping Material/InkWell around a form control would otherwise
    // capture the leaf and stamp a generic pill on top. Defer to the form
    // control so it can draw its real silhouette (Switch's track + thumb,
    // Radio's ring, etc.).
    if (_hasFormControlDescendant(r)) return false;
    // Buttons / chips / FABs are short. Treat as leaf so the pill becomes a
    // single bone instead of just the label text.
    if (r.size.height <= 64) return true;
    return !_hasBoneDescendant(r);
  }

  // ---- detection walk ----

  void _detectBones(
    RenderObject renderObject, [
    _DetectContext ctx = _DetectContext.empty,
  ]) {
    if (renderObject is RenderSkeletonIgnore) {
      if (renderObject.size != Size.zero) {
        _ignoredRegions.add(
          _IgnoredRegion(renderObject, _positionOf(renderObject)),
        );
      }
      return;
    }

    // Spinners, progress indicators, and third-party loaders are a
    // different kind of loading affordance. Skeletonising them would just
    // stack a pill on top of a pill. Skip the subtree entirely so they
    // simply don't appear during the loading phase.
    if (_isProgressOrLoader(renderObject)) return;

    // Widget identity (from the element walk) wins over render-object
    // type. Modern Flutter renders Switch, Checkbox, Radio, and
    // CircularProgressIndicator all through the same `RenderCustomPaint`
    // so this is the only reliable way to give each its real silhouette.
    final kind = _kindMap[renderObject];
    if (kind != null && renderObject is RenderBox) {
      switch (kind) {
        case _WidgetKind.progress:
          return;
        case _WidgetKind.icon:
          _addIconBoneFromBox(renderObject, ctx);
          return;
        case _WidgetKind.switchControl:
          _addSwitchBones(renderObject);
          return;
        case _WidgetKind.radio:
          _addRadioBone(renderObject);
          return;
        case _WidgetKind.checkbox:
          _addCheckboxBone(renderObject);
          return;
        case _WidgetKind.slider:
          _addSliderBones(renderObject);
          return;
        case _WidgetKind.textField:
          _addTextFieldBone(renderObject);
          return;
      }
    }

    // Track ambient clip context so descendant images / containers /
    // icons can adopt the surrounding clip's shape.
    if (renderObject is RenderClipRRect &&
        renderObject.clipBehavior != Clip.none) {
      final raw = renderObject.borderRadius;
      final resolved = raw is BorderRadius
          ? raw
          : raw.resolve(TextDirection.ltr);
      final newCtx = ctx.withClipRadius(resolved.topLeft.x);
      renderObject.visitChildren((c) => _detectBones(c, newCtx));
      return;
    }
    if (renderObject is RenderClipOval &&
        renderObject.clipBehavior != Clip.none) {
      renderObject.visitChildren((c) => _detectBones(c, ctx.asOval()));
      return;
    }

    if (renderObject is RenderParagraph) {
      _addTextBone(renderObject, _positionOf(renderObject));
      return;
    }

    if (renderObject is RenderImage) {
      _addImageBone(renderObject, _positionOf(renderObject), ctx);
      return;
    }

    // RenderDecoratedBox (a Container with BoxDecoration). Three cases:
    //  1. Leaf with fill → solid bone, stop recursion.
    //  2. Has fill AND has bone descendants → emit a low-opacity *backdrop*
    //     bone for the card silhouette, then recurse so inner content
    //     bones layer on top. Without this the gradient wallet card,
    //     analytics Card panels, and music hero artwork would be invisible
    //     in the skeleton — only their inner text/icons would draw.
    //  3. No fill (border-only) → handled further down.
    if (renderObject is RenderDecoratedBox) {
      final decoration = renderObject.decoration;
      if (decoration is BoxDecoration) {
        final c = decoration.color;
        final hasVisibleColor = c != null && c.a > 0;
        final hasFill = hasVisibleColor ||
            decoration.gradient != null ||
            decoration.image != null;
        if (hasFill) {
          if (decoration.shape == BoxShape.circle ||
              !_hasBoneDescendant(renderObject)) {
            _addDecoratedBoxBone(
              renderObject,
              _positionOf(renderObject),
              decoration,
              ctx,
            );
            return;
          }
          _addDecoratedBoxBone(
            renderObject,
            _positionOf(renderObject),
            decoration,
            ctx,
            backdrop: true,
          );
          // Fall through to recurse so the inner content layers on top.
        }
      }
    }

    // `Container(color: x)` (and bare `ColoredBox`) use the private
    // `_RenderColoredBox` instead of `RenderDecoratedBox`. Same two-case
    // treatment as above.
    if (renderObject is RenderBox && _isColoredBox(renderObject)) {
      if (!_hasBoneDescendant(renderObject)) {
        _addColoredBoxBone(renderObject, ctx);
        return;
      }
      _addColoredBoxBone(renderObject, ctx, backdrop: true);
      // Fall through to recurse.
    }

    // Material/Card/PhysicalShape — covers ElevatedButton, FilledButton,
    // OutlinedButton, TextButton, Chip, ActionChip, FloatingActionButton,
    // and Card. Buttons and chips are short and become a single rounded
    // bone; tall shapes (Cards, surfaces) emit a backdrop bone so the
    // card silhouette is visible, then recurse to bone the content.
    if (renderObject is RenderPhysicalShape) {
      if (_isPhysicalShapeLeaf(renderObject)) {
        _addPhysicalShapeBone(renderObject);
        return;
      }
      _addPhysicalShapeBone(renderObject, backdrop: true);
      // Fall through to recurse.
    }
    if (renderObject is RenderPhysicalModel) {
      if (_isPhysicalShapeLeaf(renderObject)) {
        _addPhysicalModelBone(renderObject);
        return;
      }
      _addPhysicalModelBone(renderObject, backdrop: true);
      // Fall through to recurse.
    }

    // Form controls (Switch, Checkbox, Radio, Slider) and TextField
    // editable region — detected by render-object type name since most
    // subtypes are private to flutter/material. Each gets a widget-shaped
    // skeleton (track + thumb, ring, outlined square) instead of a
    // generic pill so the loading state hints at the actual control.
    if (renderObject is RenderBox && _matchesCustomLeafName(renderObject)) {
      _addCustomLeafBone(renderObject);
      return;
    }

    // CustomPaint that draws something but has no bone descendants.
    if (renderObject is RenderCustomPaint &&
        !_hasBoneDescendant(renderObject)) {
      _addCustomLeafBone(renderObject);
      return;
    }

    // Border-only decorations (e.g. Divider) — render a thin line bone.
    if (renderObject is RenderDecoratedBox) {
      final decoration = renderObject.decoration;
      if (decoration is BoxDecoration &&
          decoration.border != null &&
          !_hasBoneDescendant(renderObject)) {
        _addBorderBone(renderObject, decoration);
        return;
      }
    }

    renderObject.visitChildren((c) => _detectBones(c, ctx));
  }

  // ---- icon ----

  /// Icons are identified by widget identity (`Icon` widget) via the
  /// element-tree walk. The widget's outer render object is typically a
  /// `RenderSemanticsAnnotations` or `RenderConstrainedBox` whose bounds
  /// match the visible icon — close enough to draw a chunky rounded
  /// square in place of the glyph, with the corner radius honouring any
  /// surrounding [ClipRRect] / [ClipOval].
  void _addIconBoneFromBox(RenderBox r, _DetectContext ctx) {
    if (r.size.isEmpty) return;
    final transform = _transformOf(r);
    final offset = _positionOf(r);
    if (ctx.clipOval) {
      _bones.add(
        Bone(
          offset: offset,
          size: r.size,
          type: BoneType.circle,
          transform: transform,
        ),
      );
      return;
    }
    final radius = ctx.clipRadius ?? (r.size.shortestSide / 4);
    _bones.add(
      Bone(
        offset: offset,
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: radius,
        transform: transform,
      ),
    );
  }

  // ---- text ----

  void _addTextBone(RenderParagraph p, Offset offset) {
    final size = p.size;
    if (size.isEmpty) return;
    final transform = _transformOf(p);
    final plain = p.text.toPlainText();
    if (plain.isEmpty) {
      _bones.add(
        Bone(
          offset: offset,
          size: size,
          type: BoneType.roundedRect,
          cornerRadius: 4,
          transform: transform,
        ),
      );
      return;
    }

    List<Rect>? lineRects;
    try {
      final boxes = p.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: plain.length),
      );
      // Group boxes by approximate top → one entry per visual line.
      final lines = <List<TextBox>>[];
      for (final b in boxes) {
        var added = false;
        for (final line in lines) {
          if ((line.first.top - b.top).abs() < 2) {
            line.add(b);
            added = true;
            break;
          }
        }
        if (!added) lines.add([b]);
      }
      if (lines.isNotEmpty) {
        lineRects = [
          for (final line in lines)
            Rect.fromLTRB(
              line.map((b) => b.left).reduce((a, b) => a < b ? a : b),
              line.map((b) => b.top).reduce((a, b) => a < b ? a : b),
              line.map((b) => b.right).reduce((a, b) => a > b ? a : b),
              line.map((b) => b.bottom).reduce((a, b) => a > b ? a : b),
            ),
        ];
      }
    } catch (_) {
      // Some paragraph configurations (e.g. with placeholders) may throw.
    }

    _bones.add(
      Bone(
        offset: offset,
        size: size,
        type: BoneType.text,
        cornerRadius: 4,
        lineRects: lineRects,
        transform: transform,
      ),
    );
  }

  // ---- generic shape leaves ----

  void _addColoredBoxBone(
    RenderBox r,
    _DetectContext ctx, {
    bool backdrop = false,
  }) {
    if (r.size.isEmpty) return;
    final transform = _transformOf(r);
    final offset = _positionOf(r);
    final opacity = backdrop ? _backdropOpacity : 1.0;
    if (ctx.clipOval) {
      _bones.add(
        Bone(
          offset: offset,
          size: r.size,
          type: BoneType.circle,
          transform: transform,
          opacityScale: opacity,
        ),
      );
      return;
    }
    final radius = ctx.clipRadius ?? 4.0;
    _bones.add(
      Bone(
        offset: offset,
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: radius,
        transform: transform,
        opacityScale: opacity,
      ),
    );
  }

  void _addPhysicalShapeBone(
    RenderPhysicalShape r, {
    bool backdrop = false,
  }) {
    if (r.size.isEmpty) return;
    final size = r.size;
    final offset = _positionOf(r);
    final transform = _transformOf(r);
    final opacity = backdrop ? _backdropOpacity : 1.0;

    // Material widgets wrap their `ShapeBorder` in a private `_ShapeBorderClipper`.
    // Inspect dynamically so we can read accurate corner radii from
    // `RoundedRectangleBorder`, `StadiumBorder`, etc.
    final shape = _shapeFromClipper(r.clipper);

    if (shape is CircleBorder) {
      _bones.add(
        Bone(
          offset: offset,
          size: size,
          type: BoneType.circle,
          transform: transform,
          opacityScale: opacity,
        ),
      );
      return;
    }
    if (shape is StadiumBorder) {
      _bones.add(
        Bone(
          offset: offset,
          size: size,
          type: BoneType.roundedRect,
          cornerRadius: size.height / 2,
          transform: transform,
          opacityScale: opacity,
        ),
      );
      return;
    }

    double? radius = _radiusFromShape(shape);
    if (radius == null) {
      // Heuristic fallback for unknown shapes.
      if ((size.width - size.height).abs() < 2 && size.shortestSide <= 80) {
        _bones.add(
          Bone(
            offset: offset,
            size: size,
            type: BoneType.circle,
            transform: transform,
            opacityScale: opacity,
          ),
        );
        return;
      }
      final half = size.height / 2;
      radius = half < 24 ? half : 24.0;
    }
    _bones.add(
      Bone(
        offset: offset,
        size: size,
        type: BoneType.roundedRect,
        cornerRadius: radius,
        transform: transform,
        opacityScale: opacity,
      ),
    );
  }

  /// Pull a [ShapeBorder] out of a [CustomClipper] using dynamic dispatch
  /// because Flutter's `_ShapeBorderClipper` is private.
  ShapeBorder? _shapeFromClipper(CustomClipper<Path>? clipper) {
    if (clipper == null) return null;
    try {
      final dynamic c = clipper;
      final shape = c.shape;
      if (shape is ShapeBorder) return shape;
    } catch (_) {}
    return null;
  }

  /// Best-effort corner radius from any rectangular [ShapeBorder] subclass
  /// that exposes a `borderRadius` property.
  double? _radiusFromShape(ShapeBorder? shape) {
    if (shape == null) return null;
    try {
      final dynamic s = shape;
      final br = s.borderRadius;
      if (br is BorderRadius) return br.topLeft.x;
      if (br is BorderRadiusDirectional) return br.topStart.x;
    } catch (_) {}
    return null;
  }

  void _addPhysicalModelBone(
    RenderPhysicalModel r, {
    bool backdrop = false,
  }) {
    if (r.size.isEmpty) return;
    final transform = _transformOf(r);
    final opacity = backdrop ? _backdropOpacity : 1.0;
    if (r.shape == BoxShape.circle) {
      _bones.add(
        Bone(
          offset: _positionOf(r),
          size: r.size,
          type: BoneType.circle,
          transform: transform,
          opacityScale: opacity,
        ),
      );
      return;
    }
    final radius = r.borderRadius?.topLeft.x ?? 4.0;
    _bones.add(
      Bone(
        offset: _positionOf(r),
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: radius == 0 ? 4 : radius,
        transform: transform,
        opacityScale: opacity,
      ),
    );
  }

  // ---- form-control specific shapes ----

  /// Bone for form controls, charts, and TextField content. Each control
  /// type produces a shape that mirrors the real widget so the skeleton
  /// "reads" as a switch / radio / slider / checkbox / chart rather than a
  /// featureless pill.
  void _addCustomLeafBone(RenderObject ro) {
    if (ro is! RenderBox || ro.size.isEmpty) return;
    final name = ro.runtimeType.toString();

    if (name.contains('Switch')) {
      _addSwitchBones(ro);
      return;
    }
    if (name.contains('Slider')) {
      _addSliderBones(ro);
      return;
    }
    if (name.contains('Radio')) {
      _addRadioBone(ro);
      return;
    }
    if (name.contains('Checkbox')) {
      _addCheckboxBone(ro);
      return;
    }

    // Leaf RenderCustomPaint without a child is almost always a chart,
    // gauge, donut, or sparkline. Pick a shape that *looks* like a chart
    // — circle for square donut/pie/gauge, multiple "bars" for wide chart
    // panels — so the loading state actually signals "chart" instead of
    // a featureless rectangle.
    if (ro is RenderCustomPaint) {
      _addChartBones(ro);
      return;
    }

    // Editable text fields and any other unspecified leaves.
    _bones.add(
      Bone(
        offset: _positionOf(ro),
        size: ro.size,
        type: BoneType.roundedRect,
        cornerRadius: 4,
        transform: _transformOf(ro),
      ),
    );
  }

  /// Heuristic chart-shaped bone for leaf [RenderCustomPaint]s.
  ///
  /// - **Square + small** (≤ 200px shortest side, square within 15%) →
  ///   circle, for donuts / pies / gauges / radial widgets.
  /// - **Wide + tall** (aspect ≥ 1.4, height ≥ 50px) → a row of bars of
  ///   varying heights, which reads convincingly as any kind of x-axis
  ///   chart (bar / line / area / sparkline). Skeleton screens commonly
  ///   simplify charts to bars regardless of the real chart type, since
  ///   bars communicate "data here" without committing to specifics.
  /// - **Otherwise** → rounded rect (icon-like or unknown).
  void _addChartBones(RenderBox r) {
    final size = r.size;
    final offset = _positionOf(r);
    final transform = _transformOf(r);
    final aspect = size.width / size.height;

    if ((aspect - 1.0).abs() < 0.15 && size.shortestSide <= 200) {
      _bones.add(
        Bone(
          offset: offset,
          size: size,
          type: BoneType.circle,
          transform: transform,
        ),
      );
      return;
    }

    if (aspect >= 1.4 && size.height >= 50) {
      // Bar heights chosen to look like real-world chart data — varied
      // enough to read as a bar chart, not too uniform to look fake.
      const heights = [0.55, 0.85, 0.40, 0.70, 0.60, 0.90, 0.48];
      const n = 7;
      // Bars take ~2/3 of the width, spaced evenly.
      final barWidth = size.width / (n * 1.6);
      final spacing = (size.width - n * barWidth) / (n + 1);
      for (var i = 0; i < n; i++) {
        final h = heights[i] * size.height;
        final x = spacing * (i + 1) + barWidth * i;
        final y = size.height - h;
        _bones.add(
          Bone(
            offset: offset + Offset(x, y),
            size: Size(barWidth, h),
            type: BoneType.roundedRect,
            cornerRadius: 4,
            transform: transform,
          ),
        );
      }
      return;
    }

    _bones.add(
      Bone(
        offset: offset,
        size: size,
        type: BoneType.roundedRect,
        cornerRadius: 4,
        transform: transform,
      ),
    );
  }

  /// Switch → outlined pill (track) + filled circle (thumb on the
  /// trailing side). Reads as an actual switch instead of a featureless
  /// pill.
  void _addSwitchBones(RenderBox r) {
    final size = r.size;
    final offset = _positionOf(r);
    final transform = _transformOf(r);
    // Track: pill outline at full bone bounds.
    _bones.add(
      Bone(
        offset: offset,
        size: size,
        type: BoneType.roundedRect,
        cornerRadius: size.height / 2,
        transform: transform,
        opacityScale: 0.55,
      ),
    );
    // Thumb: filled circle, slightly inset, positioned on the trailing
    // side so the silhouette matches the more-common "on" Switch visual.
    final inset = (size.height * 0.18).clamp(2.0, 6.0);
    final thumbDiameter = (size.height - inset * 2).clamp(8.0, size.height);
    final thumbX = (size.width - thumbDiameter - inset).clamp(
      0.0,
      size.width - thumbDiameter,
    );
    final thumbY = (size.height - thumbDiameter) / 2;
    _bones.add(
      Bone(
        offset: offset + Offset(thumbX, thumbY),
        size: Size(thumbDiameter, thumbDiameter),
        type: BoneType.circle,
        transform: transform,
      ),
    );
  }

  /// Slider → thin track running across the bone's centre + a filled
  /// thumb circle near the centre. The whole slider's render box is
  /// taller than its visible track, so we draw the track as a thin strip
  /// rather than filling the bounds.
  void _addSliderBones(RenderBox r) {
    final size = r.size;
    final offset = _positionOf(r);
    final transform = _transformOf(r);
    const trackHeight = 4.0;
    final trackY = (size.height - trackHeight) / 2;
    _bones.add(
      Bone(
        offset: offset + Offset(0, trackY),
        size: Size(size.width, trackHeight),
        type: BoneType.roundedRect,
        cornerRadius: trackHeight / 2,
        transform: transform,
        opacityScale: 0.55,
      ),
    );
    const thumbDiameter = 20.0;
    final thumbX = (size.width - thumbDiameter) / 2;
    final thumbY = (size.height - thumbDiameter) / 2;
    _bones.add(
      Bone(
        offset: offset + Offset(thumbX, thumbY),
        size: const Size(thumbDiameter, thumbDiameter),
        type: BoneType.circle,
        transform: transform,
      ),
    );
  }

  /// Radio → ring (stroked circle) instead of a filled disc, so it reads
  /// as a radio button rather than a CircleAvatar.
  void _addRadioBone(RenderBox r) {
    _bones.add(
      Bone(
        offset: _positionOf(r),
        size: r.size,
        type: BoneType.circle,
        transform: _transformOf(r),
        strokeWidth: 2.0,
      ),
    );
  }

  /// TextField / TextFormField → single rounded-rect bone covering the
  /// whole field. Without this the prefix/suffix icons, label, hint, and
  /// the editable region inside each emit their own bone, giving the
  /// loading state a "boxes inside the box" look.
  void _addTextFieldBone(RenderBox r) {
    if (r.size.isEmpty) return;
    _bones.add(
      Bone(
        offset: _positionOf(r),
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: 8,
        transform: _transformOf(r),
      ),
    );
  }

  /// Checkbox → outlined rounded square. Without checked state this is
  /// the universal "checkbox" silhouette.
  void _addCheckboxBone(RenderBox r) {
    _bones.add(
      Bone(
        offset: _positionOf(r),
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: 3,
        transform: _transformOf(r),
        strokeWidth: 2.0,
      ),
    );
  }

  /// Border-only decorations like [Divider]. Renders a thin bone matching
  /// the visible border edge instead of a full-rect fill.
  void _addBorderBone(RenderDecoratedBox r, BoxDecoration deco) {
    if (r.size.isEmpty) return;
    final size = r.size;
    final offset = _positionOf(r);
    final border = deco.border;
    // Pick the thickest visible side.
    var thickness = 1.0;
    var top = 0.0;
    if (border is Border) {
      final sides = [border.top, border.right, border.bottom, border.left];
      final widest = sides.reduce(
        (a, b) => a.width >= b.width ? a : b,
      );
      thickness = widest.width > 0 ? widest.width : 1.0;
      // Place the bone where the visible border lives. For a typical Divider
      // (bottom border) this puts the line at the bottom edge.
      if (border.bottom.width > 0 && border.top.width == 0) {
        top = size.height - thickness;
      } else if (border.top.width > 0 && border.bottom.width == 0) {
        top = 0;
      } else {
        top = (size.height - thickness) / 2;
      }
    }
    _bones.add(
      Bone(
        offset: offset + Offset(0, top),
        size: Size(size.width, thickness),
        type: BoneType.roundedRect,
        cornerRadius: thickness / 2,
        transform: _transformOf(r),
      ),
    );
  }

  void _addImageBone(RenderImage r, Offset offset, _DetectContext ctx) {
    if (r.size.isEmpty) return;
    final transform = _transformOf(r);
    if (ctx.clipOval) {
      _bones.add(
        Bone(
          offset: offset,
          size: r.size,
          type: BoneType.circle,
          transform: transform,
        ),
      );
      return;
    }
    final radius = ctx.clipRadius ?? 8.0;
    _bones.add(
      Bone(
        offset: offset,
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: radius,
        transform: transform,
      ),
    );
  }

  void _addDecoratedBoxBone(
    RenderDecoratedBox r,
    Offset offset,
    BoxDecoration deco,
    _DetectContext ctx, {
    bool backdrop = false,
  }) {
    final transform = _transformOf(r);
    final opacity = backdrop ? _backdropOpacity : 1.0;
    // Decoration's own circle wins over ambient context.
    if (deco.shape == BoxShape.circle) {
      _bones.add(
        Bone(
          offset: offset,
          size: r.size,
          type: BoneType.circle,
          transform: transform,
          opacityScale: opacity,
        ),
      );
      return;
    }
    if (ctx.clipOval) {
      _bones.add(
        Bone(
          offset: offset,
          size: r.size,
          type: BoneType.circle,
          transform: transform,
          opacityScale: opacity,
        ),
      );
      return;
    }
    // Decoration's own borderRadius wins over ambient clip radius. Fall
    // back to ambient clip radius, then to the default 4.
    var radius = ctx.clipRadius ?? 4.0;
    final br = deco.borderRadius;
    if (br is BorderRadius) {
      radius = br.topLeft.x;
    }
    _bones.add(
      Bone(
        offset: offset,
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: radius,
        transform: transform,
        opacityScale: opacity,
      ),
    );
  }
}
