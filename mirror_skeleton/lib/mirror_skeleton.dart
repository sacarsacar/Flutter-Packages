import 'package:flutter/material.dart';

import 'src/render_mirror_skeleton.dart';

export 'src/render_mirror_skeleton.dart' show ShimmerDirection, MirrorSkeletonStyle;

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

  /// One full sweep duration for the shimmer highlight. Defaults to 1500ms.
  /// With [adaptiveSpeed] enabled this acts as the baseline — the effective
  /// duration may scale up on devices that drop frames.
  final Duration shimmerDuration;

  /// Crossfade duration when [isLoading] flips from `true` to `false`.
  /// Defaults to 250ms. Pass [Duration.zero] to disable the fade and snap
  /// straight to the real content.
  final Duration transitionDuration;

  /// When `true` (default), the shimmer animation slows down automatically
  /// on devices that drop frames so the loading state never feels laggy.
  final bool adaptiveSpeed;

  /// Color of the moving highlight that sweeps across the bones.
  /// Defaults to white.
  final Color shimmerHighlightColor;

  /// Peak alpha of the highlight gradient, 0.0–1.0. Defaults to 0.35.
  final double shimmerHighlightIntensity;

  /// Direction the shimmer sweep travels. Defaults to
  /// [ShimmerDirection.leftToRight].
  final ShimmerDirection shimmerDirection;

  /// Loading animation style. Defaults to [MirrorSkeletonStyle.shimmer].
  /// Use [MirrorSkeletonStyle.pulse] for a calmer, opacity-oscillation
  /// effect instead of a sweeping highlight.
  final MirrorSkeletonStyle style;

  const MirrorSkeleton({
    super.key,
    required this.isLoading,
    this.shimmerColor,
    this.shimmerDuration = const Duration(milliseconds: 1500),
    this.transitionDuration = const Duration(milliseconds: 250),
    this.adaptiveSpeed = true,
    this.shimmerHighlightColor = Colors.white,
    this.shimmerHighlightIntensity = 0.35,
    this.shimmerDirection = ShimmerDirection.leftToRight,
    this.style = MirrorSkeletonStyle.shimmer,
    super.child,
  });

  Color _resolveShimmerColor(BuildContext context) {
    if (shimmerColor != null) return shimmerColor!;
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final base = theme.brightness == Brightness.dark
        ? const Color(0xFF2A2A2A)
        : const Color(0xFFE6E6E6);
    return Color.alphaBlend(primary.withValues(alpha: 0.10), base);
  }

  bool _resolveAnimationsEnabled(BuildContext context) {
    final disabled = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disabled) return false;
    return TickerMode.valuesOf(context).enabled;
  }

  @override
  RenderMirrorSkeleton createRenderObject(BuildContext context) {
    return RenderMirrorSkeleton(
      isLoading: isLoading,
      shimmerColor: _resolveShimmerColor(context),
      shimmerDuration: shimmerDuration,
      transitionDuration: transitionDuration,
      adaptiveSpeed: adaptiveSpeed,
      animationsEnabled: _resolveAnimationsEnabled(context),
      highlightColor: shimmerHighlightColor,
      highlightIntensity: shimmerHighlightIntensity,
      shimmerDirection: shimmerDirection,
      style: style,
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
      ..shimmerDuration = shimmerDuration
      ..transitionDuration = transitionDuration
      ..adaptiveSpeed = adaptiveSpeed
      ..animationsEnabled = _resolveAnimationsEnabled(context)
      ..highlightColor = shimmerHighlightColor
      ..highlightIntensity = shimmerHighlightIntensity
      ..shimmerDirection = shimmerDirection
      ..style = style;
  }

  @override
  SingleChildRenderObjectElement createElement() => _MirrorSkeletonElement(this);
}

/// Custom element that exposes itself to the render object so the render
/// pass can walk descendant *widgets* (not just render objects). This is the
/// only reliable way to tell a Switch from a Checkbox in modern Flutter:
/// both share the same `RenderCustomPaint` type, and only the owning widget
/// reveals which control is which.
class _MirrorSkeletonElement extends SingleChildRenderObjectElement {
  _MirrorSkeletonElement(MirrorSkeleton super.widget);

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    (renderObject as RenderMirrorSkeleton).attachOwnerElement(this);
  }

  @override
  void unmount() {
    (renderObject as RenderMirrorSkeleton).attachOwnerElement(null);
    super.unmount();
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
