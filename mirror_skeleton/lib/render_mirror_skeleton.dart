import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Visual category of a generated bone (skeleton placeholder).
enum BoneType { text, circle, roundedRect, rect }

/// A single skeleton placeholder shape derived from a real render object.
class Bone {
  final Offset offset;
  final Size size;
  final BoneType type;
  final double cornerRadius;

  /// For text bones, per-line rectangles in coordinates relative to [offset].
  /// When null, the bone is painted as a single block.
  final List<Rect>? lineRects;

  const Bone({
    required this.offset,
    required this.size,
    required this.type,
    this.cornerRadius = 4,
    this.lineRects,
  });
}

class _IgnoredRegion {
  final RenderBox renderObject;
  final Offset offset;
  _IgnoredRegion(this.renderObject, this.offset);
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
  bool _adaptiveSpeed;

  final List<Bone> _bones = [];
  final List<_IgnoredRegion> _ignoredRegions = [];
  bool _bonesDetected = false;

  AnimationController? _shimmerController;
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
    bool adaptiveSpeed = true,
  }) : _isLoading = isLoading,
       _shimmerColor = shimmerColor,
       _shimmerDuration = shimmerDuration,
       _adaptiveSpeed = adaptiveSpeed;

  Duration get _effectiveDuration {
    if (!_adaptiveSlow) return _shimmerDuration;
    final ms = (_shimmerDuration.inMilliseconds * _slowFactor).round();
    return Duration(milliseconds: ms);
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _tickerProvider = _CustomTickerProvider();
    _shimmerController = AnimationController(
      duration: _effectiveDuration,
      vsync: _tickerProvider!,
    )..addListener(markNeedsPaint);
    if (_isLoading) {
      _shimmerController!.repeat();
      _registerTimingsCallback();
    }
  }

  @override
  void detach() {
    _unregisterTimingsCallback();
    _shimmerController?.dispose();
    _shimmerController = null;
    _tickerProvider = null;
    super.detach();
  }

  @override
  void performLayout() {
    super.performLayout();
    // Re-detect bones if our layout changed (window resize, etc.).
    _bonesDetected = false;
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
      _shimmerController?.repeat();
      _registerTimingsCallback();
    } else {
      _shimmerController?.stop();
      _unregisterTimingsCallback();
    }
    markNeedsPaint();
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

  set adaptiveSpeed(bool value) {
    if (_adaptiveSpeed == value) return;
    _adaptiveSpeed = value;
    if (_isLoading && _adaptiveSpeed) {
      _registerTimingsCallback();
    } else if (!_adaptiveSpeed) {
      _unregisterTimingsCallback();
      _adaptiveSlow = false;
      _applyShimmerDuration();
    }
  }

  // ---- paint ----

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_isLoading) {
      super.paint(context, offset);
      return;
    }

    if (!_bonesDetected) {
      _bones.clear();
      _ignoredRegions.clear();
      if (child != null) {
        _detectBones(child!);
      }
      _bonesDetected = true;
    }

    _paintBones(context, offset);
    _paintShimmer(context, offset);
    _paintIgnoredSubtrees(context, offset);
  }

  // ---- detection ----

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

  void _detectBones(RenderObject renderObject) {
    if (renderObject is RenderSkeletonIgnore) {
      if (renderObject.size != Size.zero) {
        _ignoredRegions.add(
          _IgnoredRegion(renderObject, _positionOf(renderObject)),
        );
      }
      return;
    }

    if (renderObject is RenderParagraph) {
      _addTextBone(renderObject, _positionOf(renderObject));
      return;
    }

    if (renderObject is RenderImage) {
      _addImageBone(renderObject, _positionOf(renderObject));
      return;
    }

    if (renderObject is RenderDecoratedBox) {
      final decoration = renderObject.decoration;
      if (decoration is BoxDecoration &&
          _isLeafDecoration(decoration, renderObject)) {
        _addDecoratedBoxBone(
          renderObject,
          _positionOf(renderObject),
          decoration,
        );
        return;
      }
    }

    // `Container(color: x)` (and bare `ColoredBox`) use the private
    // `_RenderColoredBox` instead of `RenderDecoratedBox`. Detect by type
    // name and treat as a rectangular leaf when it has no bone descendants.
    if (renderObject is RenderBox && _isColoredBox(renderObject)) {
      if (!_hasBoneDescendant(renderObject)) {
        _addColoredBoxBone(renderObject);
        return;
      }
    }

    renderObject.visitChildren(_detectBones);
  }

  static bool _isColoredBox(RenderObject ro) {
    return ro.runtimeType.toString() == '_RenderColoredBox';
  }

  /// A decorated box is a "leaf" (gets its own bone) when it has a visible
  /// fill AND none of its descendants would themselves produce a bone.
  /// Circles are always treated as leaves so [CircleAvatar] always becomes
  /// a circle placeholder.
  bool _isLeafDecoration(BoxDecoration deco, RenderBox box) {
    final hasFill =
        deco.color != null || deco.gradient != null || deco.image != null;
    if (!hasFill) return false;
    if (deco.shape == BoxShape.circle) return true;
    return !_hasBoneDescendant(box);
  }

  bool _hasBoneDescendant(RenderObject root) {
    var found = false;
    void walk(RenderObject ro) {
      if (found || ro is RenderSkeletonIgnore) return;
      if (ro is RenderParagraph) {
        if (ro.text.toPlainText().isNotEmpty) {
          found = true;
          return;
        }
      } else if (ro is RenderImage) {
        found = true;
        return;
      } else if (ro is RenderDecoratedBox) {
        final d = ro.decoration;
        if (d is BoxDecoration &&
            (d.color != null || d.gradient != null || d.image != null)) {
          found = true;
          return;
        }
      } else if (_isColoredBox(ro)) {
        found = true;
        return;
      }
      ro.visitChildren(walk);
    }

    root.visitChildren(walk);
    return found;
  }

  void _addTextBone(RenderParagraph p, Offset offset) {
    final size = p.size;
    if (size.isEmpty) return;
    final plain = p.text.toPlainText();
    if (plain.isEmpty) {
      _bones.add(
        Bone(
          offset: offset,
          size: size,
          type: BoneType.roundedRect,
          cornerRadius: 4,
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
      ),
    );
  }

  void _addColoredBoxBone(RenderBox r) {
    if (r.size.isEmpty) return;
    _bones.add(
      Bone(
        offset: _positionOf(r),
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: 4,
      ),
    );
  }

  void _addImageBone(RenderImage r, Offset offset) {
    _bones.add(
      Bone(
        offset: offset,
        size: r.size,
        type: BoneType.roundedRect,
        cornerRadius: 8,
      ),
    );
  }

  void _addDecoratedBoxBone(
    RenderDecoratedBox r,
    Offset offset,
    BoxDecoration deco,
  ) {
    if (deco.shape == BoxShape.circle) {
      _bones.add(Bone(offset: offset, size: r.size, type: BoneType.circle));
      return;
    }
    var radius = 4.0;
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
      ),
    );
  }

  // ---- bone painting ----

  void _paintBones(PaintingContext context, Offset offset) {
    final paint = Paint()..color = _shimmerColor;
    for (final bone in _bones) {
      final boneOffset = offset + bone.offset;
      switch (bone.type) {
        case BoneType.text:
          _paintTextBone(context.canvas, boneOffset, bone, paint);
          break;
        case BoneType.circle:
          final r = bone.size.shortestSide / 2;
          context.canvas.drawCircle(
            boneOffset + Offset(bone.size.width / 2, bone.size.height / 2),
            r,
            paint,
          );
          break;
        case BoneType.roundedRect:
          context.canvas.drawRRect(
            RRect.fromRectAndRadius(
              boneOffset & bone.size,
              Radius.circular(bone.cornerRadius),
            ),
            paint,
          );
          break;
        case BoneType.rect:
          context.canvas.drawRect(boneOffset & bone.size, paint);
          break;
      }
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
    final controller = _shimmerController;
    if (controller == null || _bones.isEmpty) return;

    final shimmerValue = controller.value;
    final w = size.width;
    final shimmerCenter = w * shimmerValue;
    const shimmerWidth = 140.0;

    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.0),
        Colors.white.withValues(alpha: 0.35),
        Colors.white.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    for (final bone in _bones) {
      final boneOffset = offset + bone.offset;
      final boneRect = boneOffset & bone.size;
      final shimmerLeft = shimmerCenter - shimmerWidth / 2;
      final shimmerRight = shimmerCenter + shimmerWidth / 2;
      if (shimmerRight <= bone.offset.dx ||
          shimmerLeft >= bone.offset.dx + bone.size.width) {
        continue;
      }

      final shader = gradient.createShader(
        Rect.fromLTWH(
          offset.dx + shimmerLeft,
          boneRect.top,
          shimmerWidth,
          boneRect.height.clamp(1.0, double.infinity),
        ),
      );
      final shimmerPaint = Paint()..shader = shader;

      switch (bone.type) {
        case BoneType.circle:
          final r = bone.size.shortestSide / 2;
          context.canvas.drawCircle(
            boneOffset + Offset(bone.size.width / 2, bone.size.height / 2),
            r,
            shimmerPaint,
          );
          break;
        case BoneType.roundedRect:
          context.canvas.drawRRect(
            RRect.fromRectAndRadius(
              boneRect,
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
      context.paintChild(ignored.renderObject, offset + ignored.offset);
    }
  }
}
