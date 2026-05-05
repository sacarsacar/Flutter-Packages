# Changelog

## 0.3.0

API tightening, TickerMode awareness, and pub.dev publishing fixes.

### Breaking changes

- **Internal files moved to `lib/src/`.** The package now exposes a
  single public entrypoint, `package:mirror_skeleton/mirror_skeleton.dart`.
  If you were importing `package:mirror_skeleton/render_mirror_skeleton.dart`
  directly to reach `RenderMirrorSkeleton`, `Bone`, or `BoneType`, switch
  to `package:mirror_skeleton/src/render_mirror_skeleton.dart`. These
  types are not part of the public API and may change without notice.
- **`MirrorSkeleton` parameter types tightened.** `shimmerDuration`,
  `transitionDuration`, `shimmerHighlightColor`, `shimmerHighlightIntensity`,
  `shimmerDirection`, and `style` are no longer nullable; pass the
  defaults explicitly if you need them. `shimmerColor` remains nullable
  (null still means "derive from the active theme").

### Added

- **TickerMode awareness.** A `MirrorSkeleton` inside an off-screen
  `TabBarView` page (or any `TickerMode(enabled: false)` subtree) now
  stops its shimmer ticker, so invisible loading states don't burn
  frames in the background.

### Fixes

- **TextField / TextFormField no longer skeletonise as "boxes inside a
  box".** Previously a `TextField` with a `prefixIcon`, `suffixIcon`,
  `labelText`, and `OutlineInputBorder` would emit a separate bone for
  each of those pieces — the icons, the label, the hint, the editable
  region, and the border decoration all stacked inside one another.
  Detection now identifies the field by widget identity and emits a
  single rounded-rect bone for the whole control.
- **MIT license file shipped.** Previous versions had a placeholder
  `LICENSE` that pub.dev's analyzer rejected. The README has always
  said MIT; the file now matches.
- **Transparent-color containers no longer emit phantom backdrops.**
  `Container(color: Colors.transparent)` was being treated as
  "contentful" because the color reference was non-null. Detection now
  also checks alpha, so an invisible container is invisible in the
  skeleton too.
- **`README` install snippet pinned to the right version.**
- **README "Limitations" section corrected** to describe the actual
  current behavior of `Transform.rotate` / `RotatedBox` (bones are
  drawn rotated; only the shimmer overlay is skipped).

### Performance

- **Frame-timing buffer is a `Queue` instead of a `List`.** Sliding
  the window no longer pays an O(N) `removeAt(0)` cost every frame
  during adaptive-speed sampling.

## 0.2.1

### Fixes

- **Filled containers / Cards / gradient panels with content now show in
  the skeleton.** Previously a `Container(decoration: BoxDecoration(...),
  child: ...)` or a `Card` wrapping content would emit bones only for
  the *children* and leave the card silhouette invisible — the wallet
  gradient card, the music-player hero artwork, the analytics chart
  panels, etc. They now emit a low-opacity *backdrop* bone for the card
  shape, then the inner content bones layer on top at full opacity (the
  pattern production skeletons use).
- **Charts read as charts during loading.** Leaf `CustomPaint` widgets
  are now shape-aware: a square small one (donut, pie, gauge) becomes a
  circle bone; a wide one (sparkline, bar, line, area) becomes a row of
  varying-height bar bones, so the loading state actually signals
  "chart" instead of a featureless rectangle. Anything that doesn't
  match falls back to the existing rounded-rect bone.
- **Chat screen demo no longer hangs in the loading state.** The example
  had `isLoading: true` hardcoded; it now ticks off after a delay like
  the other screens.

## 0.2.0

Detection accuracy, performance, and lifecycle hardening.

### Behavior changes

- **Progress indicators are no longer skeletonised.** A real
  `CircularProgressIndicator`, `LinearProgressIndicator`, or
  `RefreshProgressIndicator` is a different kind of loading affordance —
  stamping a pill on top would be misleading. Their subtree is now
  skipped entirely (no bone, no recursion). Third-party widgets whose
  render-object class name contains `Progress`, `Loader`, or `Spinner`
  are also skipped.
- **Form controls now look like the real widget.** Switch becomes a
  pill (track) plus a thumb circle, Slider becomes a thin track plus a
  thumb, Radio becomes a stroked ring, Checkbox becomes an outlined
  rounded square. Previously they were all generic rounded rectangles.
- **`Icon` becomes a chunky rounded square** instead of a thin one-line
  text bone, matching the icon's actual silhouette.
- **`ClipRRect` / `ClipOval` shapes propagate** to descendant images,
  containers, and icon bones — wrap an image in `ClipRRect(borderRadius:
  16)` and the bone now uses radius 16 instead of the default 8.

### Performance

- **O(N²) → O(N) detection.** A single bottom-up walk now precomputes,
  for every node, whether its subtree contains a bone-producing widget.
  The detection pass queries this in O(1) instead of re-walking the
  subtree from every leaf candidate. Visible jank when `isLoading` first
  flips on long lists is gone.
- **Auto-scaled shimmer band.** The highlight stripe now scales as 30%
  of the active axis (clamped 80–240px), so it looks right on phones
  *and* tablets instead of feeling tiny on wide layouts.

### Memory / lifecycle

- **Bone state is released after fade-out.** When `isLoading` flips off
  and the crossfade completes, the bone list, ignored-region list, and
  descendant cache are cleared so the render object stops pinning
  descendant render objects in memory.
- **Frame-timing observer cleared on detach** alongside controllers, in
  addition to the existing fade-out cleanup.
- **Stale `SkeletonIgnore` references are tolerated.** Hit-testing and
  paint now skip ignored regions whose render object has detached
  (e.g. parent rebuilt out of the tree mid-loading).

### Widget identity (internal)

- A custom `Element` is used to walk descendant *widgets* (not just
  render objects). Modern Flutter renders Switch / Checkbox / Radio /
  CircularProgressIndicator all through the same generic
  `RenderCustomPaint`, so widget identity is the only reliable way to
  know which control is which. This is why the form-control silhouettes
  and progress-skipping behaviors above can be precise.

### Tests

- New coverage for progress-indicator skip, icon detection,
  ClipRRect / ClipOval radius inheritance, Switch / Slider / Radio /
  Checkbox shapes, and bone-state release after fade-out.

## 0.1.0

Major rewrite focused on real-world widget coverage and pub.dev quality.

### Added

- **Auto-detection for the full Material control set**: `ElevatedButton`,
  `FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`,
  `FloatingActionButton`, `Chip`, `ActionChip`, `InputChip`, `Switch`,
  `Checkbox`, `Radio`, `Slider`, `LinearProgressIndicator`,
  `CircularProgressIndicator`, `TextField`, custom `CustomPaint`,
  border-only `Divider`, `Card`, and `Material` surfaces.
- **`SkeletonIgnore` widget** — wrap any subtree to keep it fully
  rendered (and tappable) during loading.
- **Theme-synced default shimmer color** derived from
  `Theme.of(context).colorScheme.primary` when `shimmerColor` is omitted.
- **`shimmerDuration` parameter** — customize sweep speed; defaults to
  1500ms.
- **`transitionDuration` parameter** — smooth crossfade between
  skeleton and real content when `isLoading` flips. Defaults to 250ms.
- **Adaptive shimmer speed** — frame timings sampled via
  `SchedulerBinding.addTimingsCallback`; shimmer slows automatically on
  jank.
- **Multi-line text wrapping** — `RenderParagraph.getBoxesForSelection`
  used to emit one bone per visual line at actual wrapped width.
- **Sliver-aware positioning** via
  `RenderBox.localToGlobal(_, ancestor: this)`, so `ListView` and
  `GridView` items skeletonize at their correct positions.
- **Hit testing absorbed during loading** — taps don't leak to
  underlying widgets.
- **Semantics excluded during loading** — screen readers see a single
  `Loading` live region.
- **Reduced-motion compliance** — shimmer animation pauses when
  `MediaQuery.disableAnimations` is true.

### Tests

- Comprehensive widget-test coverage for detection, hit blocking,
  semantics, fade transition, and reduced-motion handling.

### Notes

- Minimum Flutter version bumped to 3.27.0 (uses `Color.withValues`).

## 0.0.1

- Initial scaffold.
