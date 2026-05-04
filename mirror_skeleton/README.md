# mirror_skeleton

Render-tree aware shimmer skeletons for Flutter. Wrap any widget tree in
one line — `MirrorSkeleton` walks the actual `RenderObject` tree and
generates pixel-matched bones for every text run, image, container,
button, form control, and progress indicator it finds. Zero layout shift
when the data arrives.

```dart
MirrorSkeleton(
  isLoading: loading,
  child: YourPage(),
);
```

That's it. No parallel placeholder tree to maintain, no per-widget
shimmer config. Edit your real UI and the skeleton stays in sync
automatically.

## Why mirror_skeleton

Most skeleton libraries make you hand-craft a parallel widget tree that
mirrors your real UI, doubling maintenance every time the design shifts.
`mirror_skeleton` inspects the laid-out render tree at paint time and
projects a shape for every visible element it finds.

| Feature | Hand-crafted skeleton | mirror_skeleton |
| --- | --- | --- |
| Match your real UI | manual | automatic |
| Survives design changes | rewrite | free |
| Zero layout shift | only if you got it pixel-right | always |
| Multi-line text wrapping | manual line-count math | automatic |
| Theme-tinted color | manual | automatic |
| Excluded brand elements | custom logic | `SkeletonIgnore` |
| Buttons / chips / form controls | manual placeholders | auto-detected |
| Hides children from screen readers | manual `ExcludeSemantics` | built in |
| Blocks taps during loading | manual `IgnorePointer` | built in |
| Smooth crossfade when loaded | manual `AnimatedSwitcher` | built in |
| Honors reduced motion setting | manual | built in |

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  mirror_skeleton: ^0.1.0
```

Then:

```dart
import 'package:mirror_skeleton/mirror_skeleton.dart';
```

## Usage

### One-line wrap

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: ProfileBody(user: _user ?? User.placeholder()),
);
```

The widget tree under `child` is rendered as-is when `isLoading` is
`false`. While `isLoading` is `true`, the same tree is walked at paint
time and replaced with shimmering bones matching every visible element.

### Keep brand elements visible

Wrap any subtree in `SkeletonIgnore` to opt it out of skeletonization:

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: Column(
    children: [
      SkeletonIgnore(child: Image.asset('assets/logo.png')),
      ProfileBody(user: user),
    ],
  ),
);
```

The logo stays fully painted (and tappable) while everything around it
shimmers.

### Customization

```dart
MirrorSkeleton(
  isLoading: loading,
  shimmerColor: Colors.indigo.shade100,        // optional
  shimmerDuration: const Duration(seconds: 2), // optional, default 1500ms
  transitionDuration: const Duration(milliseconds: 200), // crossfade duration
  adaptiveSpeed: true,                         // slow down on jank
  child: YourPage(),
);
```

When `shimmerColor` is omitted, MirrorSkeleton derives a tone from
`Theme.of(context).colorScheme.primary` so the loading state always
feels native to your brand.

## Auto-detected widgets

Anything in this list becomes a properly-shaped bone with no extra code:

- **Text**: `Text`, `RichText`, `Icon` — multi-line text emits one bone
  per visual line at the actual wrapped width
- **Images**: `Image.asset`, `Image.network`, `Image.file`, `Image.memory`
- **Containers**: `Container(color: ...)`, `Container(decoration: ...)`,
  `ColoredBox`, `DecoratedBox` — `BoxShape.circle` becomes a circle bone,
  rectangular shapes preserve `borderRadius`
- **Avatars**: `CircleAvatar` of any size
- **Cards / Material surfaces**: `Card`, `Material` — recurses into
  content rather than blocking it
- **Buttons**: `ElevatedButton`, `FilledButton`, `OutlinedButton`,
  `TextButton`, `IconButton`, `FloatingActionButton`
- **Chips**: `Chip`, `ActionChip`, `InputChip`
- **Form controls**: `TextField`, `TextFormField`, `Switch`, `Checkbox`,
  `Radio`, `Slider`
- **Progress**: `LinearProgressIndicator`, `CircularProgressIndicator`
- **Custom paint**: bare `CustomPaint` widgets get a single bone matching
  their footprint
- **Dividers**: thin border-only decorations render as a hairline bone
- **Layout widgets** (`Row`, `Column`, `Stack`, `Padding`, `SizedBox`,
  `AspectRatio`, `Expanded`, `Flexible`, `ListView`, `GridView`,
  `SingleChildScrollView`, `CustomScrollView`) — traversed and used to
  compute exact bone positions via `RenderBox.localToGlobal`

## Built-in polish

- **Hit testing absorbed during loading.** Taps don't leak through to
  underlying widgets — `onPressed` handlers won't fire while the
  skeleton is up.
- **Semantics excluded during loading.** Screen readers see a single
  `Loading` live region instead of reading placeholder text.
- **Smooth crossfade when `isLoading` flips off.** Real content fades in
  over `transitionDuration` (250ms by default) — no visible pop.
- **Reduced motion respected.** When
  `MediaQuery.of(context).disableAnimations` is `true`, the shimmer
  stops sweeping and the bones stay static.
- **Adaptive shimmer speed.** Frame timings are sampled and the shimmer
  slows automatically on devices that drop frames.
- **Zero layout shift.** Bones are derived from the laid-out subtree, so
  the real content slots into exactly the same coordinates.

## Example

A complete demo gallery is in [`example/`](./example) covering profile,
feed list, product grid, article view, chat list, dashboard, and a
controls gallery (buttons / chips / switches / sliders / progress / text
fields).

```bash
cd example
flutter run
```

## API

### `MirrorSkeleton`

| Parameter | Type | Default | Notes |
| --- | --- | --- | --- |
| `isLoading` | `bool` | required | Show skeleton vs. real child |
| `child` | `Widget?` | – | The tree to skeletonize |
| `shimmerColor` | `Color?` | derived from theme | Bone color |
| `shimmerDuration` | `Duration?` | 1500ms | One sweep duration |
| `transitionDuration` | `Duration?` | 250ms | Fade-out duration. `Duration.zero` to disable |
| `adaptiveSpeed` | `bool` | `true` | Slow shimmer on frame drops |

### `SkeletonIgnore`

Wraps a subtree and renders it normally over the skeleton. Useful for
brand logos, hero illustrations, or anything that should remain visible
during loading.

## Limitations

- `Transform.rotate` / `RotatedBox`: bones land at the right position
  but are drawn axis-aligned, not rotated.
- Truly bespoke `RenderBox` subclasses outside the patterns above:
  fall back to wrapping in a `Container(color: ...)` of equivalent size
  during loading, or wrap in `SkeletonIgnore` to keep them visible.

## License

MIT — see [LICENSE](./LICENSE).
