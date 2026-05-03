import 'package:flutter/material.dart';
import 'package:mirror_skeleton/render_mirror_skeleton.dart';

/// Wraps any widget tree and replaces it with an auto-generated shimmer
/// skeleton while [isLoading] is `true`.
///
/// Usage is one line:
///
/// ```dart
/// MirrorSkeleton(isLoading: loading, child: YourPage());
/// ```
///
/// The skeleton is built by inspecting the actual render tree, so spacing,
/// sizes, shapes (circles, rounded rects), text line wrapping, and images
/// are mirrored automatically — there is zero layout shift when loading
/// flips off.
///
/// - [shimmerColor] is optional. When omitted, MirrorSkeleton picks a tone
///   derived from `Theme.of(context).colorScheme.primary` so it feels native
///   to the app's brand.
/// - [shimmerDuration] is optional. When omitted, defaults to 1500ms.
/// - [adaptiveSpeed] watches the frame rate and slows the shimmer
///   automatically on devices that can't keep up at 60fps.
/// - Wrap any subtree in [SkeletonIgnore] to keep the real content visible
///   even while the surrounding skeleton animates.
class MirrorSkeleton extends SingleChildRenderObjectWidget {
  /// Whether to render the skeleton instead of the real [child].
  final bool isLoading;

  /// Color of the bone (placeholder) shapes. When `null`, derived from
  /// `Theme.of(context).colorScheme.primary` at 10% opacity blended onto a
  /// neutral background.
  final Color? shimmerColor;

  /// One full sweep duration for the shimmer highlight. When `null`, defaults
  /// to 1500ms. With [adaptiveSpeed] enabled this acts as the baseline — the
  /// effective duration may scale up on devices that drop frames.
  final Duration? shimmerDuration;

  /// When `true` (default), the shimmer animation slows down automatically
  /// on devices that drop frames so the loading state never feels laggy.
  final bool adaptiveSpeed;

  const MirrorSkeleton({
    super.key,
    required this.isLoading,
    this.shimmerColor,
    this.shimmerDuration,
    this.adaptiveSpeed = true,
    super.child,
  });

  static const Duration _defaultDuration = Duration(milliseconds: 1500);

  Color _resolveShimmerColor(BuildContext context) {
    if (shimmerColor != null) return shimmerColor!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final base = theme.brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE6E6E6);
    return Color.alphaBlend(primary.withValues(alpha: 0.10), base);
  }

  @override
  RenderMirrorSkeleton createRenderObject(BuildContext context) {
    return RenderMirrorSkeleton(
      isLoading: isLoading,
      shimmerColor: _resolveShimmerColor(context),
      shimmerDuration: shimmerDuration ?? _defaultDuration,
      adaptiveSpeed: adaptiveSpeed,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderMirrorSkeleton renderObject,
  ) {
    renderObject
      ..isLoading = isLoading
      ..shimmerColor = _resolveShimmerColor(context)
      ..shimmerDuration = shimmerDuration ?? _defaultDuration
      ..adaptiveSpeed = adaptiveSpeed;
  }
}

/// Marks a subtree to be excluded from skeletonization.
///
/// Anything wrapped in [SkeletonIgnore] is rendered normally even while the
/// surrounding [MirrorSkeleton] is loading. Useful for backgrounds, brand
/// logos, or any element that should remain visible during loading.
///
/// ```dart
/// MirrorSkeleton(
///   isLoading: loading,
///   child: Column(children: [
///     SkeletonIgnore(child: Image.asset('logo.png')),
///     ProfileBody(),
///   ]),
/// );
/// ```
class SkeletonIgnore extends SingleChildRenderObjectWidget {
  const SkeletonIgnore({super.key, super.child});

  @override
  RenderSkeletonIgnore createRenderObject(BuildContext context) {
    return RenderSkeletonIgnore();
  }
}
