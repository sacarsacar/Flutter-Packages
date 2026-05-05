import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

import 'bones.dart';

export 'bones.dart';

part 'bone_detection.dart';
part 'bone_painting.dart';

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
  bool _animationsEnabled;
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
  static const int _frameSampleWindow = 30;
  bool _adaptiveSlow = false;
  final Queue<double> _frameSamples = Queue<double>();
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
    bool animationsEnabled = true,
  }) : _isLoading = isLoading,
       _shimmerColor = shimmerColor,
       _shimmerDuration = shimmerDuration,
       _transitionDuration = transitionDuration,
       _adaptiveSpeed = adaptiveSpeed,
       _animationsEnabled = animationsEnabled,
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
    if (_isLoading && _animationsEnabled) {
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
      if (_frameSamples.length > _frameSampleWindow) {
        _frameSamples.removeFirst();
      }
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
      if (_animationsEnabled) {
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
    if (_isLoading && _adaptiveSpeed && _animationsEnabled) {
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

  set animationsEnabled(bool value) {
    if (_animationsEnabled == value) return;
    _animationsEnabled = value;
    if (!_animationsEnabled) {
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
}
