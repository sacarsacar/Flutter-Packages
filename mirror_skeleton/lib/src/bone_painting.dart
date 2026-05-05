part of 'render_mirror_skeleton.dart';

/// Pulse mode multiplies the bone alpha by a smooth triangle wave so the
/// skeleton "breathes" between [_pulseMin] and 1.0.
const double _pulseMin = 0.55;

/// Fade mode dips deeper than pulse for a more pronounced blink.
const double _fadeMin = 0.2;

/// Floor opacity for bones outside the wave's reach. Anything farther than
/// the wave band from the wave's centre dims to this value instead of going
/// fully transparent — keeps the skeleton readable as a whole.
const double _waveMin = 0.45;

extension _BonePainting on RenderMirrorSkeleton {
  double get _pulseAlpha {
    final controller = _shimmerController;
    if (controller == null || !controller.isAnimating) return 1.0;
    final v = controller.value;
    final tri = v < 0.5 ? v * 2 : 2 - v * 2; // 0 → 1 → 0
    switch (_style) {
      case MirrorSkeletonStyle.pulse:
        return _pulseMin + (1.0 - _pulseMin) * tri;
      case MirrorSkeletonStyle.fade:
        return _fadeMin + (1.0 - _fadeMin) * tri;
      case MirrorSkeletonStyle.shimmer:
      case MirrorSkeletonStyle.wave:
        return 1.0;
    }
  }

  /// Per-bone alpha multiplier for [MirrorSkeletonStyle.wave]. The wave's
  /// centre travels across the layout along the active [ShimmerDirection]
  /// axis; bones near the centre keep full alpha, bones beyond the wave
  /// band dim to [_waveMin]. Linear falloff keeps the math cheap and the
  /// effect predictable.
  double _waveAlphaFor(Bone bone) {
    if (_style != MirrorSkeletonStyle.wave) return 1.0;
    final controller = _shimmerController;
    if (controller == null || !controller.isAnimating) return 1.0;
    final isHorizontal =
        _shimmerDirection == ShimmerDirection.leftToRight ||
        _shimmerDirection == ShimmerDirection.rightToLeft;
    final reversed =
        _shimmerDirection == ShimmerDirection.rightToLeft ||
        _shimmerDirection == ShimmerDirection.bottomToTop;
    final t = reversed ? 1.0 - controller.value : controller.value;
    final axisLength = isHorizontal ? size.width : size.height;
    final waveCenter = axisLength * t;
    // Wider band than shimmer so the falloff feels like a wave rather than
    // a moving spotlight.
    final waveBand = (axisLength * 0.5).clamp(120.0, 400.0);
    final boneCenter = isHorizontal
        ? bone.offset.dx + bone.size.width / 2
        : bone.offset.dy + bone.size.height / 2;
    final distance = (boneCenter - waveCenter).abs();
    if (distance >= waveBand) return _waveMin;
    final factor = 1.0 - distance / waveBand; // 1 at centre, 0 at band edge
    return _waveMin + (1.0 - _waveMin) * factor;
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
      final alpha = pulseAlpha * _waveAlphaFor(bone);
      final paint = _bonePaint(bone, alpha);
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
    // Only the shimmer style draws a moving highlight overlay. The other
    // styles convey motion via alpha modulation in _paintBones, so the
    // gradient pass would just stack a redundant sweep on top.
    if (_style != MirrorSkeletonStyle.shimmer) return;

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
