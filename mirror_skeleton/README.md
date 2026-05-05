# 🦴 Mirror Skeleton

Render-tree aware shimmer skeletons for Flutter. Wrap any widget tree in one line — `MirrorSkeleton` walks the actual `RenderObject` tree and generates pixel-matched bones for every text run, image, container, button, form control, and progress indicator it finds. **Zero layout shift** when your data arrives.

[![Pub](https://img.shields.io/pub/v/mirror_skeleton.svg)](https://pub.dev/packages/mirror_skeleton)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/Tests-30%2F30%20Passing-brightgreen)](https://github.com/sakarchaulagain/Flutter-Packages/mirror_skeleton)
[![Analysis](https://img.shields.io/badge/Analysis-0%20Issues-brightgreen)](https://pub.dev/packages/mirror_skeleton)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.27%2B-blue)](https://flutter.dev)

---

## ✨ The 30-Second Pitch

```dart
MirrorSkeleton(
  isLoading: loading,
  child: YourPage(),
);
```

That's it. No parallel placeholder tree to maintain, no per-widget shimmer config. Edit your real UI and the skeleton stays in sync — automatically.

---
---
## 🎬 Demo

<div style="display: flex; flex-wrap: wrap; gap: 10px; justify-content: center;">
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example1.gif" alt="Demo 1" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example2.gif" alt="Demo 2" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example3.gif" alt="Demo 3" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example4.gif" alt="Demo 4" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example5.gif" alt="Demo 5" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example6.gif" alt="Demo 6" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example7.gif" alt="Demo 7" style="width: 100%;">
  </div>
  <div style="flex: 1 1 calc(33.333% - 10px); min-width: 250px; max-width: 300px; text-align: center;">
    <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/mirror_skeleton/demo/example8.gif" alt="Demo 8" style="width: 100%;">
  </div>
</div>

---

---

## 🎯 Why Mirror Skeleton

Most skeleton libraries make you hand-craft a parallel widget tree that mirrors your real UI, doubling maintenance every time the design shifts. `mirror_skeleton` inspects the laid-out render tree at paint time and projects a shape for every visible element it finds.

| Feature | Hand-crafted skeleton | mirror_skeleton |
| --- | --- | --- |
| Match your real UI | manual | ✅ automatic |
| Survives design changes | rewrite | ✅ free |
| Zero layout shift | only if pixel-perfect | ✅ always |
| Multi-line text wrapping | manual line-count math | ✅ automatic |
| Theme-tinted color | manual | ✅ automatic |
| Excluded brand elements | custom logic | ✅ `SkeletonIgnore` |
| Buttons / chips / form controls | manual placeholders | ✅ auto-detected |
| Hides children from screen readers | manual `ExcludeSemantics` | ✅ built in |
| Blocks taps during loading | manual `IgnorePointer` | ✅ built in |
| Smooth crossfade when loaded | manual `AnimatedSwitcher` | ✅ built in |
| Honors reduced-motion setting | manual | ✅ built in |
| Multiple animation styles | manual | ✅ shimmer / pulse / fade / wave |

---

## 🚀 Quick Start (2 Steps!)

### Step 1: Add to Dependencies

```yaml
# pubspec.yaml
dependencies:
  mirror_skeleton: ^0.3.0
```

Then run:

```bash
flutter pub get
```

### Step 2: Wrap Your Widget Tree

```dart
import 'package:mirror_skeleton/mirror_skeleton.dart';

MirrorSkeleton(
  isLoading: _loading,
  child: ProfileBody(user: _user ?? User.placeholder()),
);
```

That's it! 🎉 The widget tree under `child` renders as-is when `isLoading` is `false`. While `isLoading` is `true`, the same tree is walked at paint time and replaced with shimmering bones matching every visible element — at the exact same positions and sizes.

---

## 📖 Complete Usage Guide

### 🦴 Basic Skeleton Wrap

```dart
class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    final user = await api.getUser();
    setState(() {
      _user = user;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MirrorSkeleton(
      isLoading: _loading,
      child: ProfileBody(user: _user ?? User.placeholder()),
    );
  }
}
```

When `_loading` flips off, the real content fades in over a smooth 250ms crossfade. No visible pop, no jump.

### 🛡️ Keep Brand Elements Visible with `SkeletonIgnore`

Wrap any subtree in `SkeletonIgnore` to opt it out of skeletonization:

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: Column(
    children: [
      SkeletonIgnore(
        child: Image.asset('assets/logo.png'), // stays visible & tappable
      ),
      ProfileBody(user: user), // shimmers
    ],
  ),
);
```

The logo stays fully painted while everything around it shimmers. Useful for:
- Brand logos and hero illustrations
- Navigation rails / app bars you want to keep functional
- Background patterns and decorative imagery
- Any element that should stay visible during loading

### 🎨 Customize the Look

```dart
MirrorSkeleton(
  isLoading: loading,
  shimmerColor: Colors.indigo.shade100,         // optional — bone color
  shimmerDuration: Duration(seconds: 2),        // sweep duration (default 1500ms)
  transitionDuration: Duration(milliseconds: 200), // crossfade out (default 250ms)
  adaptiveSpeed: true,                          // slow shimmer on jank
  shimmerHighlightColor: Colors.white,          // moving highlight color
  shimmerHighlightIntensity: 0.35,              // peak alpha 0.0–1.0
  shimmerDirection: ShimmerDirection.leftToRight,
  style: MirrorSkeletonStyle.shimmer,           // shimmer / pulse / fade / wave
  child: YourPage(),
);
```

When `shimmerColor` is omitted, MirrorSkeleton derives a tone from `Theme.of(context).colorScheme.primary` so the loading state always feels native to your brand — light or dark mode.

### 🌊 Animation Styles

Pick the loading vibe that fits your app:

```dart
// Default — sweeping highlight
MirrorSkeleton(
  isLoading: loading,
  style: MirrorSkeletonStyle.shimmer,
  child: YourPage(),
);

// Calm in-place opacity oscillation (~55% → 100%)
MirrorSkeleton(
  isLoading: loading,
  style: MirrorSkeletonStyle.pulse,
  child: YourPage(),
);

// Deeper blink (~20% → 100%) — more pronounced
MirrorSkeleton(
  isLoading: loading,
  style: MirrorSkeletonStyle.fade,
  child: YourPage(),
);

// Per-bone wave that travels along the shimmer axis
MirrorSkeleton(
  isLoading: loading,
  style: MirrorSkeletonStyle.wave,
  child: YourPage(),
);
```

### ↔️ Shimmer Direction (4 Options)

```dart
ShimmerDirection.leftToRight   // ➡️  Default
ShimmerDirection.rightToLeft   // ⬅️
ShimmerDirection.topToBottom   // ⬇️
ShimmerDirection.bottomToTop   // ⬆️
```

```dart
MirrorSkeleton(
  isLoading: loading,
  shimmerDirection: ShimmerDirection.topToBottom,
  child: YourPage(),
);
```

---

## 🎯 Auto-Detected Widgets

Anything in this list becomes a properly-shaped bone with **no extra code**:

### 📝 Text & Icons
- `Text`, `RichText` — multi-line text emits one bone per visual line at the actual wrapped width
- `Icon` — chunky rounded-square bone matching the icon's footprint

### 🖼️ Images
- `Image.asset`, `Image.network`, `Image.file`, `Image.memory`
- `ClipRRect` / `ClipOval` shapes propagate to descendant images (a `ClipRRect(borderRadius: 16)` wrapping an image gives a bone with radius 16)

### 📦 Containers & Surfaces
- `Container(color: ...)`, `Container(decoration: ...)`, `ColoredBox`, `DecoratedBox`
- `BoxShape.circle` becomes a circle bone; rectangular shapes preserve `borderRadius`
- `Card`, `Material` — emits a low-opacity backdrop for the surface, then layers inner content bones on top (the same pattern production skeletons use for gradient cards, hero artwork, analytics panels, etc.)

### 👤 Avatars
- `CircleAvatar` of any size

### 🔘 Buttons & Chips
- `ElevatedButton`, `FilledButton`, `OutlinedButton`, `TextButton`
- `IconButton`, `FloatingActionButton`
- `Chip`, `ActionChip`, `InputChip`

### ☑️ Form Controls (look like the real widget)
- `TextField`, `TextFormField` — full-field rounded rect
- `Switch` — pill track + thumb circle
- `Slider` — thin track + thumb
- `Radio` — stroked ring
- `Checkbox` — outlined rounded square

### ⏳ Progress (intentionally **not** skeletonised)
- A real `CircularProgressIndicator`, `LinearProgressIndicator`, or `RefreshProgressIndicator` is a different kind of loading affordance — stamping a pill on top would be misleading. Their subtree is skipped entirely. Third-party widgets whose render-object class name contains `Progress`, `Loader`, or `Spinner` are also skipped.

### 📊 Custom Charts (shape-aware)
Leaf `CustomPaint` widgets are detected by aspect:
- **Square small** (donut, pie, gauge) → circle bone
- **Wide** (sparkline, bar, line, area) → row of varying-height bar bones, so the loading state actually signals "chart"
- **Anything else** → rounded-rect fallback

### ➖ Dividers
- Thin border-only decorations render as a hairline bone

### 📐 Layout Widgets (traversed)
`Row`, `Column`, `Stack`, `Padding`, `SizedBox`, `AspectRatio`, `Expanded`, `Flexible`, `ListView`, `GridView`, `SingleChildScrollView`, `CustomScrollView` — traversed and used to compute exact bone positions via `RenderBox.localToGlobal`.

---

## 🛠️ Built-in Polish

Things you don't have to remember to wire up:

- **🚫 Hit testing absorbed during loading.** Taps don't leak through to underlying widgets — `onPressed` handlers won't fire while the skeleton is up.
- **🔇 Semantics excluded during loading.** Screen readers see a single `Loading` live region instead of reading placeholder text.
- **🎬 Smooth crossfade when `isLoading` flips off.** Real content fades in over `transitionDuration` (250ms by default) — no visible pop.
- **♿ Reduced motion respected.** When `MediaQuery.of(context).disableAnimations` is `true`, the shimmer stops sweeping and the bones stay static.
- **⚡ Adaptive shimmer speed.** Frame timings are sampled and the shimmer slows automatically on devices that drop frames.
- **💤 TickerMode-aware.** A `MirrorSkeleton` inside an off-screen `TabBarView` page (or any `TickerMode(enabled: false)` subtree) stops its shimmer ticker so it doesn't burn frames when invisible.
- **📐 Zero layout shift.** Bones are derived from the laid-out subtree, so the real content slots into exactly the same coordinates.
- **🧹 Memory released after fade-out.** When the crossfade completes, the bone list, ignored-region list, and descendant cache are cleared so the render object stops pinning descendants in memory.

---

## 💡 Real-World Examples

### Profile Page with Avatar, Bio & Stats

```dart
class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _loading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _user = await api.getUser();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.avatar)),
            Text(user.name, style: TextStyle(fontSize: 24)),
            Text(user.bio, maxLines: 3),
            Row(children: [
              StatChip(label: 'Followers', value: user.followers),
              StatChip(label: 'Following', value: user.following),
              StatChip(label: 'Posts', value: user.posts),
            ]),
          ],
        ),
      ),
    );
  }
}
```

### Feed List with Hero Image Excluded

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: CustomScrollView(
    slivers: [
      SliverToBoxAdapter(
        // Brand hero stays visible the whole time
        child: SkeletonIgnore(
          child: Image.asset('assets/hero.png'),
        ),
      ),
      SliverList.builder(
        itemBuilder: (_, i) => ArticleTile(article: articles[i]),
        itemCount: articles.length,
      ),
    ],
  ),
);
```

### Tab View with Per-Tab Loading

```dart
TabBarView(
  children: [
    MirrorSkeleton(isLoading: _loadingFeed,    child: FeedPage()),
    MirrorSkeleton(isLoading: _loadingTrending, child: TrendingPage()),
    MirrorSkeleton(isLoading: _loadingSaved,   child: SavedPage()),
  ],
);
```

Each tab shimmers independently, and off-screen tabs pause their shimmer ticker automatically (TickerMode-aware) — no wasted frames.

### Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: _load,
  child: MirrorSkeleton(
    isLoading: _loading,
    child: ListView.builder(
      itemBuilder: (_, i) => ArticleTile(article: articles[i]),
      itemCount: articles.length,
    ),
  ),
);
```

The `RefreshProgressIndicator` is intentionally skipped during skeletonization, so the spinner remains visible above the shimmering list — exactly like production apps.

---

## 📚 API Reference

### `MirrorSkeleton`

| Parameter | Type | Default | Notes |
| --- | --- | --- | --- |
| `isLoading` | `bool` | required | Show skeleton vs. real child |
| `child` | `Widget?` | – | The tree to skeletonize |
| `shimmerColor` | `Color?` | derived from theme | Bone color. `null` → derived from `Theme.of(context).colorScheme.primary` |
| `shimmerDuration` | `Duration` | `1500ms` | One full sweep |
| `transitionDuration` | `Duration` | `250ms` | Crossfade duration. `Duration.zero` to disable |
| `adaptiveSpeed` | `bool` | `true` | Slow shimmer on frame drops |
| `shimmerHighlightColor` | `Color` | `Colors.white` | Color of the moving highlight |
| `shimmerHighlightIntensity` | `double` | `0.35` | Peak alpha of the highlight, 0.0–1.0 |
| `shimmerDirection` | `ShimmerDirection` | `leftToRight` | Sweep direction |
| `style` | `MirrorSkeletonStyle` | `shimmer` | `shimmer` / `pulse` / `fade` / `wave` |

### `SkeletonIgnore`

Wraps a subtree and renders it normally over the skeleton. Useful for brand logos, hero illustrations, or anything that should remain visible during loading.

```dart
SkeletonIgnore(child: YourBrandWidget())
```

### `ShimmerDirection`

```dart
enum ShimmerDirection { leftToRight, rightToLeft, topToBottom, bottomToTop }
```

### `MirrorSkeletonStyle`

```dart
enum MirrorSkeletonStyle { shimmer, pulse, fade, wave }
```

| Style | Effect |
| --- | --- |
| `shimmer` | Sweeping highlight gradient — the classic skeleton look |
| `pulse` | Calm in-place opacity oscillation (~55% ↔ 100%) |
| `fade` | Pronounced blink (~20% ↔ 100%) |
| `wave` | Per-bone alpha wave traveling along the shimmer axis — gentler than `shimmer`, shader-free |

---

## 🧠 Best Practices

### ✅ Do's
- ✓ Wrap the **smallest meaningful subtree** (the body of a screen, a list, a card) — not the whole `MaterialApp`
- ✓ Render real widgets with **placeholder data** while loading — `User.placeholder()`, `List.filled(6, Article.placeholder())` — so layout matches the loaded state
- ✓ Use `SkeletonIgnore` for **brand logos, hero images, navigation chrome**
- ✓ Trust the auto-detection — it covers virtually all standard Flutter widgets
- ✓ Test with **dark mode** — theme-derived colors adapt automatically

### ❌ Don'ts
- ✗ Don't toggle `isLoading` rapidly — let the crossfade finish for a polished feel
- ✗ Don't wrap a `Scaffold` directly — wrap the `body`, not the whole `Scaffold` (so the AppBar stays interactive)
- ✗ Don't worry about progress indicators inside the tree — they're auto-skipped, not skeletonized
- ✗ Don't forget to provide **placeholder data** to your widgets while loading; `MirrorSkeleton` shapes bones from what's actually laid out

---

## 🆘 Troubleshooting

| Issue | Solution |
|-------|----------|
| Skeleton shows nothing | Make sure `isLoading: true` and that the `child` actually lays out (provide placeholder data so widgets get a real size) |
| Real content "pops" in | Increase `transitionDuration` for a softer crossfade, or set it to `Duration.zero` if you want a hard cut |
| Shimmer feels laggy | `adaptiveSpeed: true` is on by default — try release mode (`flutter run --release`) for true performance |
| Bones at wrong positions | Wrap a smaller subtree closer to the actual content, not the whole app |
| Logo gets shimmered | Wrap it in `SkeletonIgnore` |
| Custom widget not detected | Wrap it in a sized `Container(color: ...)` during loading, or use `SkeletonIgnore` to keep it visible |
| Rotated bone has no shimmer overlay | Known: `Transform.rotate` / `RotatedBox` bones are drawn at the correct rotated position but the shimmer highlight skips them — they still receive the bone color |

---

## ⚠️ Limitations

- `Transform.rotate` / `RotatedBox` bones are drawn at the correct rotated position, but the moving shimmer highlight skips them — they still receive the bone color, just without the sweep overlay.
- Truly bespoke `RenderBox` subclasses outside the patterns above: fall back to wrapping in a `Container(color: ...)` of equivalent size during loading, or wrap in `SkeletonIgnore` to keep them visible.

---

## 📊 Quality & Testing

- ✅ 30/30 tests passing (100%)
- ✅ 0 code analysis issues
- ✅ Full null safety
- ✅ Dartdoc on all public API
- ✅ Flutter 3.27.0+
- ✅ Dart 3.11.3+

---

## 📁 Project Structure

```
mirror_skeleton/
├── lib/
│   ├── mirror_skeleton.dart          # Public entrypoint
│   └── src/
│       ├── render_mirror_skeleton.dart  # Render object & owner element
│       ├── bone_detection.dart       # Render-tree → bones
│       ├── bone_painting.dart        # Bones → canvas
│       └── bones.dart                # Bone, BoneType, ShimmerDirection, MirrorSkeletonStyle
├── test/
│   └── mirror_skeleton_test.dart     # 30 widget tests
├── example/                          # 14-page demo gallery
│   └── lib/
│       └── pages/                    # Profile, Feed, Grid, Article, Chat, Dashboard, Controls, …
└── pubspec.yaml
```

---

## 🎬 Example App

A complete demo gallery is in [`example/`](./example) covering:

- **Profile** — Avatar, multi-line bio, stat row
- **Feed** — `ListView` of article tiles with images
- **Product Grid** — `GridView` with cards, prices, ratings
- **Article** — Hero image, paragraphs, author row
- **Messages / Conversations** — Chat list with avatars and unread badges
- **Dashboard** — Mixed layout with `SkeletonIgnore` brand banner
- **Controls Gallery** — Buttons, chips, switches, sliders, progress, text fields
- **Login** — `TextField`s, password toggle, `Checkbox`, social buttons
- **Settings** — Sectioned `ListTile`s with `Switch`, `Checkbox`, `Slider`, `Divider`
- **Music Player** — Hero artwork, sliders, transport row, queue list
- **Wallet** — Gradient balance card, action chips, transaction list
- **Analytics** — Sparkline + bar + donut `CustomPaint` charts and stats
- **Shimmer Styles** — Live playground for direction, style, color, intensity

Run it:

```bash
cd example
flutter pub get
flutter run
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. Report issues on [GitHub](https://github.com/sakarchaulagain/mirror_skeleton/issues)
2. Submit pull requests with improvements
3. Help improve documentation

---

## 📄 License

MIT License — see [LICENSE](./LICENSE) for details.

---

## 📚 Resources

- [Example App](./example/) — Complete demo gallery with 14+ screens
- [Changelog](./CHANGELOG.md) — Version history
- [GitHub](https://github.com/sakarchaulagain/mirror_skeleton) — Source code
- [Pub.dev](https://pub.dev/packages/mirror_skeleton) — Package registry

---

<div align="center">

**Made with 🦴 for the Flutter community**

⭐ [Star on GitHub](https://github.com/sakarchaulagain/mirror_skeleton) if `mirror_skeleton` saves you a Sunday afternoon!

</div>
