# Mirror Skeleton — Example App

A fully-featured, interactive demonstration of the `mirror_skeleton` package showing real-world screens (profile, feed, grid, chat, dashboard, …) flipping between their loading and loaded states with **zero layout shift** and zero hand-crafted skeletons.

[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.27%2B-blue)](https://flutter.dev)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)

---

## 📱 What's Inside

This example app demonstrates **14 production-style screens**, each running through MirrorSkeleton with one line of code:

```dart
MirrorSkeleton(isLoading: _loading, child: YourPage());
```

No parallel placeholder tree. No per-widget shimmer config. The page below runs unchanged — `MirrorSkeleton` walks its render tree and projects bones for every visible element.

### 🖼️ Screen Gallery

| Screen | What it demonstrates |
|--------|----------------------|
| 👤 **Profile** | Avatar, multi-line bio, stat row |
| 📰 **Feed** | `ListView` of article tiles with images |
| 🛍️ **Product Grid** | `GridView` with cards, prices, ratings |
| 📖 **Article** | Hero image, paragraphs, author row |
| 💬 **Messages** | Chat list with avatars and unread badges |
| 💬 **Conversations** | Single-thread chat screen |
| 📊 **Dashboard** | Mixed layout with `SkeletonIgnore` brand banner |
| 🎛️ **Controls Gallery** | Buttons, chips, switches, sliders, progress, text fields |
| 🔐 **Login** | `TextField`s, password toggle, `Checkbox`, social buttons |
| ⚙️ **Settings** | Sectioned `ListTile`s with `Switch`, `Checkbox`, `Slider`, `Divider` |
| 🎵 **Music Player** | Hero artwork, sliders, transport row, queue list |
| 💳 **Wallet** | Gradient balance card, action chips, transaction list |
| 📈 **Analytics** | Sparkline + bar + donut `CustomPaint` charts and stats |
| 🎨 **Shimmer Styles** | Live playground for direction, style, color, intensity |

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.27.0 or higher
- Dart 3.11.3 or higher
- A connected device, simulator, or emulator

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/sakarchaulagain/Flutter-Packages/mirror_skeleton.git
cd mirror_skeleton/example

# Get dependencies
flutter pub get

# Run the app
flutter run

# Or run in release mode for true performance
flutter run --release
```

### Pick a screen

The home screen lists every demo. Tap one and you'll see it open in its loading state — bones shimmering across every visible element — then crossfade to the real content after a short delay.

---

## 🎯 What Each Screen Teaches

### 1. Profile Page

**What you learn:** Auto-detected `CircleAvatar`, multi-line `Text`, and `Row` of stat chips.

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: Column(
    children: [
      CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.avatar)),
      Text(user.name, style: TextStyle(fontSize: 24)),
      Text(user.bio, maxLines: 3),
      Row(children: [...stats]),
    ],
  ),
);
```

The avatar becomes a circle bone. The bio's three wrapped lines become three separate bones at the actual wrapped widths.

---

### 2. Feed Page

**What you learn:** `ListView.builder` items skeletonize at their correct positions via `RenderBox.localToGlobal`. Image thumbnails become rounded-rect bones; titles and snippets become text bones.

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: ListView.builder(
    itemBuilder: (_, i) => ArticleTile(article: articles[i]),
    itemCount: articles.length,
  ),
);
```

Pre-load `articles` with placeholder data so the layout matches the loaded state.

---

### 3. Product Grid

**What you learn:** `GridView` cards including image, title, price, and rating chip — all auto-detected. `Card` surfaces emit a low-opacity backdrop bone with inner content bones layered on top.

---

### 4. Article Page

**What you learn:** Hero image, multi-paragraph body text, author row. Long paragraphs are wrapped by Flutter and `mirror_skeleton` emits one bone per visual line at the actual wrapped width.

---

### 5. Messages / Conversations

**What you learn:** Chat list pattern — `CircleAvatar`, two-line message preview, unread `Container(decoration: BoxDecoration(shape: BoxShape.circle, ...))` becomes a circle bone.

---

### 6. Dashboard with `SkeletonIgnore`

**What you learn:** Brand elements stay visible during loading.

```dart
MirrorSkeleton(
  isLoading: _loading,
  child: Column(
    children: [
      SkeletonIgnore(
        child: BrandBanner(), // never shimmers, stays tappable
      ),
      DashboardCards(),     // shimmers normally
    ],
  ),
);
```

---

### 7. Controls Gallery

**What you learn:** Each form control gets a *shape-correct* bone — not a generic rounded rectangle.

| Control | Bone shape |
|---------|-----------|
| `Switch` | Pill track + thumb circle |
| `Checkbox` | Outlined rounded square |
| `Radio` | Stroked ring |
| `Slider` | Thin track + thumb |
| `TextField` | Full-field rounded rect |
| `ElevatedButton` / `FilledButton` / `OutlinedButton` / `TextButton` | Button-shaped rounded rect |
| `IconButton` / `FAB` | Circle bone |
| `Chip` / `ActionChip` / `InputChip` | Pill-shaped bone |
| `LinearProgressIndicator` / `CircularProgressIndicator` | **Skipped** — real spinner shows through |

---

### 8. Login Page

**What you learn:** Auth screens. Email/password `TextField`s become field-shaped bones. The "Show password" `IconButton` becomes a circle bone. The `Checkbox` for "Remember me" becomes an outlined rounded square. Social buttons become shape-correct rounded rects.

---

### 9. Settings Page

**What you learn:** Sectioned settings UIs. `ListTile`s with `Switch`, `Checkbox`, `Slider` trailing controls all skeletonize correctly. `Divider`s render as hairline bones.

---

### 10. Music Player

**What you learn:** Mixed hero + control layout. The hero artwork `Card` emits a backdrop bone *plus* layered content bones (the same pattern production skeletons use for gradient cards). The transport row buttons and the queue list below all skeletonize automatically.

---

### 11. Wallet

**What you learn:** Gradient `Container(decoration: BoxDecoration(gradient: ...))` cards used to "disappear" in naive skeleton libraries — `mirror_skeleton` emits a low-opacity backdrop bone for the card silhouette, then layers the inner balance / action chips on top.

---

### 12. Analytics

**What you learn:** Charts are detected by aspect.

| Chart kind | Detection | Bone |
|-----------|-----------|------|
| Sparkline / bar / line / area (wide) | Wide leaf `CustomPaint` | Row of varying-height bar bones |
| Donut / pie / gauge (square small) | Square leaf `CustomPaint` | Circle bone |
| Anything else | Fallback | Rounded-rect bone |

The loading state actually signals "chart" instead of a featureless rectangle.

---

### 13. Shimmer Styles Playground

**What you learn:** Live, interactive controls for every customization parameter:

- `MirrorSkeletonStyle` — `shimmer` / `pulse` / `fade` / `wave`
- `ShimmerDirection` — `leftToRight` / `rightToLeft` / `topToBottom` / `bottomToTop`
- `shimmerColor` — pick any color, or let it derive from theme
- `shimmerHighlightColor` and `shimmerHighlightIntensity`
- `shimmerDuration` — sweep speed
- `transitionDuration` — crossfade

Use this screen to dial in the loading vibe that fits your app, then copy the parameters into your real `MirrorSkeleton` wrap.

---

## 💻 Implementation Pattern

Every demo screen follows the same structure — that's the point.

```dart
class FeedPage extends StatefulWidget {
  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  bool _loading = true;
  List<Article> _articles = List.filled(8, Article.placeholder());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final articles = await mockRepo.getArticles();
    if (!mounted) return;
    setState(() {
      _articles = articles;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feed')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: ListView.builder(
          itemBuilder: (_, i) => ArticleTile(article: _articles[i]),
          itemCount: _articles.length,
        ),
      ),
    );
  }
}
```

Three things to note:

1. **The widget tree never changes.** Same `ListView.builder` whether loading or loaded.
2. **Placeholder data does the layout work.** `List.filled(8, Article.placeholder())` ensures the tree lays out at realistic sizes so bones land in realistic positions.
3. **`MirrorSkeleton` is the only loading-aware widget.** No `if (loading) Skeleton() else RealUI()` branching anywhere.

---

## 📱 Responsive Design

Every demo screen uses standard Flutter layout patterns and scales naturally:

```bash
# Mobile (< 600px)
flutter run -d <iphone-or-android>

# Tablet (600–1024px)
flutter run -d ipad

# Desktop (> 1024px)
flutter run -d macos
flutter run -d windows
flutter run -d linux

# Web
flutter run -d chrome
```

`mirror_skeleton` reads positions and sizes from the laid-out render tree, so bones automatically follow whatever responsive layout your widgets render at the current screen size.

---

## 🧪 Testing Checklist

Verify the package works end-to-end:

### ✓ Auto-detection
- [ ] Open **Profile** — avatar is a circle, bio shows three line bones, stats are pill bones
- [ ] Open **Feed** — image thumbnails are rounded-rect bones, titles and snippets are text bones
- [ ] Open **Product Grid** — card surfaces have backdrop + inner content bones
- [ ] Open **Controls Gallery** — Switch shows pill+thumb, Slider shows track+thumb, Radio shows ring, Checkbox shows outlined square
- [ ] Open **Analytics** — sparklines render as bar rows, donut as circle, fallback as rounded-rect

### ✓ Built-in polish
- [ ] Tap during loading — taps don't register on underlying widgets
- [ ] Enable VoiceOver / TalkBack — only "Loading" is announced
- [ ] When loading flips off — content crossfades in over 250ms (no pop)
- [ ] Open **Dashboard** — brand banner stays painted while everything around it shimmers
- [ ] Open **Music Player** — start playback then navigate away and back; shimmer pauses while off-screen (TickerMode)

### ✓ Reduced motion
- [ ] Enable Reduce Motion in OS accessibility settings — bones stop sweeping but stay visible
- [ ] Disable Reduce Motion — shimmer resumes

### ✓ Customization
- [ ] Open **Shimmer Styles** — switch between `shimmer` / `pulse` / `fade` / `wave`; verify each animates differently
- [ ] Change `shimmerDirection` — sweep direction follows
- [ ] Change `shimmerColor` — bone color updates instantly
- [ ] Change `shimmerHighlightIntensity` to 0.0 — highlight disappears, bones stay solid

---

## 🎯 Key Takeaways

After working through these demos, you'll understand:

✅ How **one-line wrapping** replaces hand-crafted skeleton trees  
✅ Which Flutter widgets are **auto-detected** (almost all of them)  
✅ When and how to use **`SkeletonIgnore`** for brand elements  
✅ How **shape-aware bones** make form controls and charts read correctly during loading  
✅ How to pick the right **animation style** (`shimmer` / `pulse` / `fade` / `wave`)  
✅ How **theme integration** keeps loading states feeling native to your brand  
✅ How **built-in polish** (hit-blocking, semantics, crossfade, reduced-motion, TickerMode) eliminates dozens of small chores

---

## 📚 Next Steps

### 1. Read the Full Documentation
- [Main Package README](../README.md) — Complete feature reference
- [Package Changelog](../CHANGELOG.md) — Version history

### 2. Integrate into Your App
Follow the same pattern as the example screens:
- Wrap the smallest meaningful subtree (a screen body, a list, a card)
- Provide placeholder data so widgets lay out at realistic sizes
- Toggle `isLoading` based on your data source
- Use `SkeletonIgnore` for any brand element that should stay visible

### 3. Customize for Your Brand
Use the Shimmer Styles playground to dial in the look, then copy the parameters into your real wrap:

```dart
MirrorSkeleton(
  isLoading: loading,
  shimmerColor: Colors.indigo.shade100,
  style: MirrorSkeletonStyle.pulse,
  shimmerDirection: ShimmerDirection.topToBottom,
  child: YourPage(),
);
```

---

## 🤝 Contribute

Have improvements for this example?

1. [Report Issues](https://github.com/sakarchaulagain/mirror_skeleton/issues) — Found a bug?
2. [Submit PRs](https://github.com/sakarchaulagain/mirror_skeleton/pulls) — Have enhancements?

---

<div align="center">

**Explore. Wrap. Ship. 🦴**

Start with the **Profile** screen and work your way through the gallery to see every detection pattern in action.

[⬆ Back to Top](#mirror-skeleton--example-app)

</div>
