import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Visual category of a generated bone (skeleton placeholder).
enum BoneType { text, circle, roundedRect, rect }

/// Direction the shimmer highlight sweeps across the skeleton.
enum ShimmerDirection {
  leftToRight,
  rightToLeft,
  topToBottom,
  bottomToTop,
}

/// Animation style used while the skeleton is visible.
///
/// - [MirrorSkeletonStyle.shimmer] sweeps a moving highlight across the bones.
/// - [MirrorSkeletonStyle.pulse] oscillates the bone opacity in place. Useful
///   for designs that prefer a calmer loading state.
enum MirrorSkeletonStyle { shimmer, pulse }

/// A single skeleton placeholder shape derived from a real render object.
class Bone {
  final Offset offset;
  final Size size;
  final BoneType type;
  final double cornerRadius;

  /// For text bones, per-line rectangles in coordinates relative to [offset].
  /// When null, the bone is painted as a single block.
  final List<Rect>? lineRects;

  /// Cumulative transform from the bone's local coordinates to the skeleton
  /// root. When the matrix is a pure translation [offset] is sufficient and
  /// this is null. Non-null when an ancestor [RenderTransform] (e.g.
  /// `Transform.rotate`, `RotatedBox`) introduces rotation, scaling, or
  /// skew — in which case the painter applies the matrix to the canvas
  /// before drawing the shape.
  final Matrix4? transform;

  /// When non-null, the bone is drawn with [PaintingStyle.stroke] of this
  /// width instead of being filled. Used for outline-style controls
  /// (radio buttons, unchecked checkboxes) so the skeleton looks like the
  /// real widget rather than a solid block.
  final double? strokeWidth;

  /// Multiplies the bone color's alpha when painting. Used to render
  /// secondary shapes — a Switch's track behind its thumb, a Slider's
  /// track behind its handle — at lower prominence than the primary
  /// shape, mirroring the actual widget's visual hierarchy.
  final double opacityScale;

  const Bone({
    required this.offset,
    required this.size,
    required this.type,
    this.cornerRadius = 4,
    this.lineRects,
    this.transform,
    this.strokeWidth,
    this.opacityScale = 1.0,
  });
}

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

class _CustomTickerProvider extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

/// Render object for [SkeletonIgnore]. Used as a sentinel during render-tree
/// traversal: when [RenderMirrorSkeleton] sees this in the descendant chain,
/// it preserves the subtree instead of replacing it with a bone.
class RenderSkeletonIgnore extends RenderProxyBox {
  RenderSkeletonIgnore({RenderBox? child}) : super(child);
}

/// Render object that walks its child subtree and paints an auto-generated
/// shimmering skeleton in place of the real content while [isLoading] is true.
class RenderMirrorSkeleton extends RenderProxyBox {
  bool _isLoading;
  Color _shimmerColor;
  Duration _shimmerDuration;
  Duration _transitionDuration;
  bool _adaptiveSpeed;
  bool _disableAnimations;
  Color _highlightColor;
  double _highlightIntensity;
  ShimmerDirection _shimmerDirection;
  MirrorSkeletonStyle _style;

  final List<Bone> _bones = [];
  final List<_IgnoredRegion> _ignoredRegions = [];
  final Map<RenderObject, _DescFlags> _descCache = {};
  final Map<RenderObject, _WidgetKind> _kindMap = {};
  Element? _ownerElement;
  bool _bonesDetected = false;

  AnimationController? _shimmerController;
  AnimationController? _fadeController;
  _CustomTickerProvider? _tickerProvider;

  /// Multiplier applied to [_shimmerDuration] when adaptive slow mode kicks
  /// in (frame timings exceed the threshold).
  static const double _slowFactor = 1.6;
  bool _adaptiveSlow = false;
  final List<double> _frameSamples = [];
  TimingsCallback? _timingsCallback;

  RenderMirrorSkeleton({
    required bool isLoading,
    required Color shimmerColor,
    required Duration shimmerDuration,
    required Duration transitionDuration,
    required Color highlightColor,
    required double highlightIntensity,
    required ShimmerDirection shimmerDirection,
    required MirrorSkeletonStyle style,
    bool adaptiveSpeed = true,
    bool disableAnimations = false,
  }) : _isLoading = isLoading,
       _shimmerColor = shimmerColor,
       _shimmerDuration = shimmerDuration,
       _transitionDuration = transitionDuration,
       _adaptiveSpeed = adaptiveSpeed,
       _disableAnimations = disableAnimations,
       _highlightColor = highlightColor,
       _highlightIntensity = highlightIntensity,
       _shimmerDirection = shimmerDirection,
       _style = style;

  /// Called by [_MirrorSkeletonElement] on mount/unmount so the render
  /// object can walk descendant widgets when detection runs. Without this,
  /// modern Flutter form controls (Switch / Checkbox / Radio) — all of
  /// which share a generic `RenderCustomPaint` — would be indistinguishable
  /// from each other or from a custom-painted graph.
  void attachOwnerElement(Element? element) {
    _ownerElement = element;
  }

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

  Duration get _effectiveDuration {
    if (!_adaptiveSlow) return _shimmerDuration;
    final ms = (_shimmerDuration.inMilliseconds * _slowFactor).round();
    return Duration(milliseconds: ms);
  }

  /// Bones detected during the most recent paint pass. Exposed for tests
  /// that need to assert on the generated skeleton structure.
  @visibleForTesting
  List<Bone> get bones => List.unmodifiable(_bones);

  /// Current opacity of the skeleton overlay, where `1.0` means fully
  /// loading and `0.0` means fully transitioned to the real content.
  /// Exposed for tests verifying the crossfade animation.
  @visibleForTesting
  double get fadeValue => _fadeController?.value ?? (_isLoading ? 1.0 : 0.0);

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _tickerProvider = _CustomTickerProvider();
    _shimmerController = AnimationController(
      duration: _effectiveDuration,
      vsync: _tickerProvider!,
    )..addListener(markNeedsPaint);
    _fadeController = AnimationController(
      duration: _transitionDuration,
      vsync: _tickerProvider!,
      value: _isLoading ? 1.0 : 0.0,
    )
      ..addListener(markNeedsPaint)
      ..addStatusListener(_onFadeStatusChange);
    if (_isLoading && !_disableAnimations) {
      _shimmerController!.repeat();
      _registerTimingsCallback();
    }
  }

  @override
  void detach() {
    _unregisterTimingsCallback();
    _shimmerController?.dispose();
    _fadeController?.dispose();
    _shimmerController = null;
    _fadeController = null;
    _tickerProvider = null;
    _bones.clear();
    _ignoredRegions.clear();
    _descCache.clear();
    _frameSamples.clear();
    super.detach();
  }

  void _onFadeStatusChange(AnimationStatus status) {
    // Once the fade-out finishes, stop the shimmer ticker, drop the
    // adaptive-speed observer, AND release bone state so we don't hold
    // references to descendant render objects when no skeleton is visible.
    if (status == AnimationStatus.dismissed && !_isLoading) {
      _shimmerController?.stop();
      _unregisterTimingsCallback();
      _bones.clear();
      _ignoredRegions.clear();
      _descCache.clear();
      _bonesDetected = false;
    }
  }

  @override
  void performLayout() {
    final oldSize = hasSize ? size : null;
    super.performLayout();
    // Only invalidate the bone cache when our footprint actually changed
    // (window resize, orientation change, parent layout shift). Re-walking
    // a deep render tree on every layout pass is wasted work when the
    // skeleton is already accurate.
    if (oldSize != size) {
      _bonesDetected = false;
    }
  }

  // ---- adaptive speed ----

  void _registerTimingsCallback() {
    if (!_adaptiveSpeed || _timingsCallback != null) return;
    _timingsCallback = _onFrameTimings;
    SchedulerBinding.instance.addTimingsCallback(_timingsCallback!);
  }

  void _unregisterTimingsCallback() {
    if (_timingsCallback != null) {
      SchedulerBinding.instance.removeTimingsCallback(_timingsCallback!);
      _timingsCallback = null;
    }
  }

  void _onFrameTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      _frameSamples.add(t.totalSpan.inMicroseconds / 1000.0);
      if (_frameSamples.length > 30) _frameSamples.removeAt(0);
    }
    if (_frameSamples.length < 20) return;
    final avg =
        _frameSamples.reduce((a, b) => a + b) / _frameSamples.length;
    // 60Hz target ≈ 16.67ms/frame.
    if (avg > 22 && !_adaptiveSlow) {
      _adaptiveSlow = true;
      _applyShimmerDuration();
    } else if (avg < 14 && _adaptiveSlow) {
      _adaptiveSlow = false;
      _applyShimmerDuration();
    }
  }

  void _applyShimmerDuration() {
    final controller = _shimmerController;
    if (controller == null) return;
    controller.duration = _effectiveDuration;
    if (controller.isAnimating) {
      controller.stop();
      controller.repeat();
    }
  }

  // ---- setters ----

  set isLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    _bonesDetected = false;
    if (_isLoading) {
      // Snap fully visible — no fade-in for entering loading state.
      _fadeController?.value = 1.0;
      if (!_disableAnimations) {
        _shimmerController?.repeat();
        _registerTimingsCallback();
      }
    } else {
      // Fade out smoothly. Shimmer keeps animating until fade completes
      // (handled in _onFadeStatusChange).
      if (_transitionDuration == Duration.zero) {
        _fadeController?.value = 0.0;
      } else {
        _fadeController?.animateBack(0.0, duration: _transitionDuration);
      }
    }
    markNeedsPaint();
    // Make absorbed-state hit testing and "Loading" semantics flip too.
    markNeedsSemanticsUpdate();
  }

  set shimmerColor(Color value) {
    if (_shimmerColor == value) return;
    _shimmerColor = value;
    markNeedsPaint();
  }

  set shimmerDuration(Duration value) {
    if (_shimmerDuration == value) return;
    _shimmerDuration = value;
    _applyShimmerDuration();
  }

  set transitionDuration(Duration value) {
    if (_transitionDuration == value) return;
    _transitionDuration = value;
    _fadeController?.duration = value;
  }

  set adaptiveSpeed(bool value) {
    if (_adaptiveSpeed == value) return;
    _adaptiveSpeed = value;
    if (_isLoading && _adaptiveSpeed && !_disableAnimations) {
      _registerTimingsCallback();
    } else if (!_adaptiveSpeed) {
      _unregisterTimingsCallback();
      _adaptiveSlow = false;
      _applyShimmerDuration();
    }
  }

  set highlightColor(Color value) {
    if (_highlightColor == value) return;
    _highlightColor = value;
    markNeedsPaint();
  }

  set highlightIntensity(double value) {
    if (_highlightIntensity == value) return;
    _highlightIntensity = value;
    markNeedsPaint();
  }

  set shimmerDirection(ShimmerDirection value) {
    if (_shimmerDirection == value) return;
    _shimmerDirection = value;
    markNeedsPaint();
  }

  set style(MirrorSkeletonStyle value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  set disableAnimations(bool value) {
    if (_disableAnimations == value) return;
    _disableAnimations = value;
    if (_disableAnimations) {
      _shimmerController?.stop();
      _unregisterTimingsCallback();
      markNeedsPaint();
    } else if (_isLoading) {
      _shimmerController?.repeat();
      if (_adaptiveSpeed) _registerTimingsCallback();
    }
  }

  // ---- paint ----

  @override
  void paint(PaintingContext context, Offset offset) {
    final fade = _fadeController?.value ?? (_isLoading ? 1.0 : 0.0);

    // Fully loaded → just paint real content.
    if (fade <= 0) {
      super.paint(context, offset);
      return;
    }

    if (!_bonesDetected) {
      _bones.clear();
      _ignoredRegions.clear();
      _descCache.clear();
      _kindMap.clear();
      if (child != null) {
        // 1. Walk the element tree once to identify form controls / icons /
        //    progress indicators by widget identity (modern Flutter renders
        //    these all through generic RenderCustomPaint, so render-object
        //    type alone can't distinguish them).
        _populateKindMap();
        // 2. Single bottom-up pass populates the "has bone descendant" cache.
        //    Combined with the top-down detection walk this keeps detection
        //    strictly O(N) on tree size — the previous repeated subtree
        //    queries from each leaf candidate were O(N²).
        _populateContentCache(child!);
        // 3. Top-down emit bones.
        _detectBones(child!);
        // Free RenderObject references once detection is done. The maps
        // are rebuilt next time _bonesDetected flips.
        _descCache.clear();
        _kindMap.clear();
      }
      _bonesDetected = true;
    }

    // Mid-fade → real content underneath, skeleton on top with alpha.
    if (fade < 1.0) {
      super.paint(context, offset);
      context.pushOpacity(offset, (255 * fade).round(), (innerCtx, innerOffset) {
        _paintBones(innerCtx, innerOffset);
        _paintShimmer(innerCtx, innerOffset);
      });
      _paintIgnoredSubtrees(context, offset);
      return;
    }

    // Fully loading → skeleton only.
    _paintBones(context, offset);
    _paintShimmer(context, offset);
    _paintIgnoredSubtrees(context, offset);
  }

  // ---- interaction & semantics blocking while loading ----

  @override
  bool hitTestSelf(Offset position) => _isLoading;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    if (_isLoading) {
      // Allow taps to flow into SkeletonIgnore subtrees so brand elements
      // remain interactive, but block everything else.
      for (final ignored in _ignoredRegions) {
        if (!ignored.renderObject.attached) continue;
        final localPosition = position - ignored.offset;
        if (ignored.renderObject.size.contains(localPosition)) {
          if (ignored.renderObject.hitTest(result, position: localPosition)) {
            return true;
          }
        }
      }
      return false;
    }
    return super.hitTestChildren(result, position: position);
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    // While loading, don't expose the underlying tree to assistive
    // technologies. Screen readers should announce a single "Loading" state
    // instead of reading placeholder text.
    if (_isLoading) return;
    super.visitChildrenForSemantics(visitor);
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    if (_isLoading) {
      config
        ..isSemanticBoundary = true
        ..label = 'Loading'
        ..textDirection = TextDirection.ltr
        ..liveRegion = true;
    }
  }

  // ---- detection helpers ----

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

  static bool _isPureTranslation(Matrix4 m) {
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
        return d.color != null || d.gradient != null || d.image != null;
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
        kind == _WidgetKind.slider) {
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
        final hasFill = decoration.color != null ||
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

  static bool _isColoredBox(RenderObject ro) {
    return ro.runtimeType.toString() == '_RenderColoredBox';
  }

  /// Form-control / TextField render objects use private `_RenderXxx`
  /// types. Match by name pattern so we cover all subclasses and keep
  /// working across Flutter versions.
  ///
  /// Note: progress indicators are NOT in this list — see
  /// [_isProgressOrLoader].
  static bool _matchesCustomLeafName(RenderObject ro) {
    final name = ro.runtimeType.toString();
    return name.contains('Toggleable') ||
        name.contains('Switch') ||
        name.contains('Checkbox') ||
        name.contains('Radio') ||
        name.contains('Slider') ||
        name.contains('Editable');
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

  /// Backdrop bones (cards, panels, gradient containers wrapping content)
  /// render at this fraction of the bone color's alpha. Low enough that
  /// inner content bones at full alpha still pop visually, high enough
  /// that the card silhouette is clearly visible.
  static const double _backdropOpacity = 0.4;

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

  /// Bone for form controls and TextField content, detected by type-name
  /// pattern. Each control type produces a shape that mirrors the real
  /// widget so the skeleton "reads" as a switch / radio / slider /
  /// checkbox rather than a generic pill.
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

  // ---- bone painting ----

  /// Pulse mode multiplies the bone alpha by a smooth triangle wave so the
  /// skeleton "breathes" between [_pulseMin] and 1.0.
  static const double _pulseMin = 0.55;
  double get _pulseAlpha {
    if (_style != MirrorSkeletonStyle.pulse) return 1.0;
    final controller = _shimmerController;
    if (controller == null || !controller.isAnimating) return 1.0;
    final v = controller.value;
    final tri = v < 0.5 ? v * 2 : 2 - v * 2; // 0 → 1 → 0
    return _pulseMin + (1.0 - _pulseMin) * tri;
  }

  /// Build the fill/stroke paint for [bone] in solid-bone-color mode,
  /// already factoring the pulse alpha and bone-specific opacity scale.
  Paint _bonePaint(Bone bone, double pulseAlpha) {
    final scaledAlpha = _shimmerColor.a * pulseAlpha * bone.opacityScale;
    final color = scaledAlpha == _shimmerColor.a
        ? _shimmerColor
        : _shimmerColor.withValues(alpha: scaledAlpha);
    final paint = Paint()..color = color;
    if (bone.strokeWidth != null) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = bone.strokeWidth!;
    }
    return paint;
  }

  void _paintBones(PaintingContext context, Offset offset) {
    final pulseAlpha = _pulseAlpha;
    final canvas = context.canvas;
    for (final bone in _bones) {
      final paint = _bonePaint(bone, pulseAlpha);
      // Transformed bones (rotated/scaled) draw in the bone's local space:
      // apply the cumulative matrix and draw at (0, 0) of size.
      if (bone.transform != null) {
        canvas.save();
        canvas.translate(offset.dx, offset.dy);
        canvas.transform(bone.transform!.storage);
        _drawBoneShape(canvas, Offset.zero, bone, paint);
        canvas.restore();
        continue;
      }
      _drawBoneShape(canvas, offset + bone.offset, bone, paint);
    }
  }

  /// Single dispatch helper that draws any bone shape at [offset]. The
  /// caller supplies the prepared [Paint] (fill or stroke).
  void _drawBoneShape(Canvas canvas, Offset offset, Bone bone, Paint paint) {
    switch (bone.type) {
      case BoneType.text:
        _paintTextBone(canvas, offset, bone, paint);
        break;
      case BoneType.circle:
        // Insetting by half the stroke width keeps stroked circles inside
        // the bone bounds (default Paint style centres the stroke on the
        // path, which would otherwise paint outside the radio's box).
        final stroke = bone.strokeWidth ?? 0;
        final r = (bone.size.shortestSide - stroke) / 2;
        canvas.drawCircle(
          offset + Offset(bone.size.width / 2, bone.size.height / 2),
          r,
          paint,
        );
        break;
      case BoneType.roundedRect:
        final stroke = bone.strokeWidth ?? 0;
        final rect = (offset & bone.size).deflate(stroke / 2);
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(bone.cornerRadius)),
          paint,
        );
        break;
      case BoneType.rect:
        canvas.drawRect(offset & bone.size, paint);
        break;
    }
  }

  void _paintTextBone(Canvas canvas, Offset offset, Bone bone, Paint paint) {
    final lines = bone.lineRects;
    if (lines != null && lines.isNotEmpty) {
      for (final line in lines) {
        final rect = Rect.fromLTWH(
          offset.dx + line.left,
          offset.dy + line.top,
          line.width,
          line.height,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
      }
      return;
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & bone.size, const Radius.circular(4)),
      paint,
    );
  }

  // ---- shimmer ----

  void _paintShimmer(PaintingContext context, Offset offset) {
    // Pulse mode handles its visual via alpha modulation in _paintBones; no
    // sweeping highlight is drawn.
    if (_style == MirrorSkeletonStyle.pulse) return;

    final controller = _shimmerController;
    if (controller == null || _bones.isEmpty) return;

    final isHorizontal =
        _shimmerDirection == ShimmerDirection.leftToRight ||
        _shimmerDirection == ShimmerDirection.rightToLeft;
    final reversed =
        _shimmerDirection == ShimmerDirection.rightToLeft ||
        _shimmerDirection == ShimmerDirection.bottomToTop;

    final t = reversed ? 1.0 - controller.value : controller.value;
    final axisLength = isHorizontal ? size.width : size.height;
    // Auto-scale band so the highlight feels right on phones AND tablets.
    // Pure constant 140 looked tiny on wide layouts and oversized on a
    // standalone 80px skeleton.
    final shimmerBand = (axisLength * 0.3).clamp(80.0, 240.0);
    final shimmerCenter = axisLength * t;
    final shimmerLow = shimmerCenter - shimmerBand / 2;
    final shimmerHigh = shimmerCenter + shimmerBand / 2;

    final highlight = _highlightColor;
    final intensity = _highlightIntensity;
    final gradient = LinearGradient(
      begin: isHorizontal ? Alignment.centerLeft : Alignment.topCenter,
      end: isHorizontal ? Alignment.centerRight : Alignment.bottomCenter,
      colors: [
        highlight.withValues(alpha: 0.0),
        highlight.withValues(alpha: intensity),
        highlight.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    for (final bone in _bones) {
      // Rotated/scaled bones live in a tilted coordinate system; the
      // axis-aligned shimmer sweep would land in the wrong place. Their
      // shapes still paint correctly via the transformed-bone path in
      // _paintBones — we just skip the highlight overlay here.
      if (bone.transform != null) continue;

      final boneOffset = offset + bone.offset;
      final boneRect = boneOffset & bone.size;

      // Skip bones the shimmer band hasn't reached along the active axis.
      final boneLow = isHorizontal ? bone.offset.dx : bone.offset.dy;
      final boneHigh = isHorizontal
          ? bone.offset.dx + bone.size.width
          : bone.offset.dy + bone.size.height;
      if (shimmerHigh <= boneLow || shimmerLow >= boneHigh) continue;

      final shaderRect = isHorizontal
          ? Rect.fromLTWH(
              offset.dx + shimmerLow,
              boneRect.top,
              shimmerBand,
              boneRect.height.clamp(1.0, double.infinity),
            )
          : Rect.fromLTWH(
              boneRect.left,
              offset.dy + shimmerLow,
              boneRect.width.clamp(1.0, double.infinity),
              shimmerBand,
            );
      final shimmerPaint = Paint()..shader = gradient.createShader(shaderRect);
      if (bone.strokeWidth != null) {
        shimmerPaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = bone.strokeWidth!;
      }

      final stroke = bone.strokeWidth ?? 0;
      switch (bone.type) {
        case BoneType.circle:
          final r = (bone.size.shortestSide - stroke) / 2;
          context.canvas.drawCircle(
            boneOffset + Offset(bone.size.width / 2, bone.size.height / 2),
            r,
            shimmerPaint,
          );
          break;
        case BoneType.roundedRect:
          context.canvas.drawRRect(
            RRect.fromRectAndRadius(
              boneRect.deflate(stroke / 2),
              Radius.circular(bone.cornerRadius),
            ),
            shimmerPaint,
          );
          break;
        case BoneType.text:
          final lines = bone.lineRects;
          if (lines != null && lines.isNotEmpty) {
            for (final line in lines) {
              final rect = Rect.fromLTWH(
                boneOffset.dx + line.left,
                boneOffset.dy + line.top,
                line.width,
                line.height,
              );
              context.canvas.drawRRect(
                RRect.fromRectAndRadius(rect, const Radius.circular(4)),
                shimmerPaint,
              );
            }
          } else {
            context.canvas.drawRect(boneRect, shimmerPaint);
          }
          break;
        case BoneType.rect:
          context.canvas.drawRect(boneRect, shimmerPaint);
          break;
      }
    }
  }

  // ---- ignored subtrees ----

  void _paintIgnoredSubtrees(PaintingContext context, Offset offset) {
    for (final ignored in _ignoredRegions) {
      // The ignored region's render object can be detached if its widget
      // was rebuilt out of the tree between detection and paint — guard
      // against painting a stale child.
      if (!ignored.renderObject.attached) continue;
      context.paintChild(ignored.renderObject, offset + ignored.offset);
    }
  }
}
