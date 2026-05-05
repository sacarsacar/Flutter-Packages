import 'package:flutter/material.dart';

/// Visual category of a generated bone (skeleton placeholder).
enum BoneType { text, circle, roundedRect, rect }

/// Direction the shimmer highlight sweeps across the skeleton.
enum ShimmerDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }

/// Animation style used while the skeleton is visible.
///
/// - [MirrorSkeletonStyle.shimmer] sweeps a moving highlight across the bones.
/// - [MirrorSkeletonStyle.pulse] oscillates the bone opacity in place between
///   ~55% and 100%. A calm, in-place loading state.
/// - [MirrorSkeletonStyle.fade] like [pulse] but with a deeper dip (~20% to
///   100%) for a more pronounced blink.
/// - [MirrorSkeletonStyle.wave] each bone's opacity peaks as a moving wave
///   passes its position along the active [ShimmerDirection] axis. Reads
///   like [shimmer] but uses alpha instead of a gradient overlay — gentler
///   and shader-free.
enum MirrorSkeletonStyle { shimmer, pulse, fade, wave }

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
