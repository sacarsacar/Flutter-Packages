# Mirror Skeleton

A **zero-config**, intelligent Flutter package that automatically detects your UI structure and renders beautiful skeleton loading animations. No wrapper widgets, no configuration—just one line of code.

## What Makes It Different

Unlike other skeleton packages that require you to manually define "bones" or wrap widgets, **MirrorSkeleton** uses **RenderObject introspection** to automatically understand your widget tree and render skeletons that **mirror your actual UI**—not just generic boxes.

### The Problem with Existing Solutions

Traditional packages like Skeletonizer require:
```dart
// ❌ Lots of boilerplate
Skeletonizer(
  enabled: isLoading,
  child: Column(
    children: [
      Bone.text(lines: 2),
      Bone.icon(),
      Bone.avatar(),
      // ... manually define every skeleton
    ],
  ),
);
```

### The MirrorSkeleton Approach

```dart
// ✅ Just wrap your existing UI
MirrorSkeleton(
  isLoading: isLoading,
  child: YourComplexPage(), // Zero changes needed!
)
```

---

## How It Works

MirrorSkeleton uses **deep render tree analysis** to automatically detect UI elements:

### Stage 1: Automatic Detection 🔍
When `isLoading: true`, the package traverses your entire widget tree and identifies:
- **Text widgets** → Renders multi-line text skeletons
- **Circular images** → Detects `CircleAvatar` and draws circles
- **Rectangular images** → Draws rectangles for `Image` widgets
- **ListTiles** → Auto-detects leading icon + title/subtitle pattern
- **Icons & containers** → Renders appropriate shapes

### Stage 2: Intelligent Rendering 🎨
Instead of showing the real UI, it paints custom skeletons based on detected shapes:
- Text: Multiple lines with diminishing width on last line
- Images: Circles or rectangles matching actual dimensions
- ListTile: Icon + title + subtitle placeholder layout
- Icons: Rounded squares

### Stage 3: Fluid Shimmer Animation ✨
A smooth gradient wave flows across all skeletons, creating a premium loading experience.

---

## Key Features

✅ **One-Line Integration** - No widget wrapping, no configuration  
✅ **Auto-Detection** - Understands TextWidget, Image, CircleAvatar, ListTile, etc.  
✅ **Deep Nesting Support** - Works with complex nested layouts (5+ levels deep)  
✅ **Shape-Aware** - Circles stay circles, rectangles stay rectangles  
✅ **Layout Preservation** - Layout doesn't shift when data loads  
✅ **Customizable Colors** - Change shimmer color to match your brand  
✅ **Performance Optimized** - Single pass detection, minimal overhead  

---

## Getting Started

### Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  mirror_skeleton: ^0.0.1
```

Then run:
```bash
flutter pub get
```

### Basic Usage

Wrap any widget with `MirrorSkeleton`:

```dart
import 'package:mirror_skeleton/mirror_skeleton.dart';

class MyProfile extends StatefulWidget {
  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool _isLoading = true;
  late UserData _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _userData = UserData(
        name: 'John Doe',
        bio: 'Flutter Developer',
        avatar: 'https://...',
      );
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MirrorSkeleton(
      isLoading: _isLoading,
      child: _buildProfileUI(),
    );
  }

  Widget _buildProfileUI() {
    if (_isLoading) {
      return _buildPlaceholder();
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(_userData.avatar),
        ),
        SizedBox(height: 16),
        Text(
          _userData.name,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(_userData.bio),
      ],
    );
  }

  Widget _buildPlaceholder() {
    // Return the same structure as real data
    // MirrorSkeleton will auto-detect and render skeletons
    return Column(
      children: [
        CircleAvatar(radius: 50),
        SizedBox(height: 16),
        Container(height: 20, width: 150),
        Container(height: 14, width: 100),
      ],
    );
  }
}
```

---

## Advanced Examples

### Example 1: ListView with ListTiles

```dart
MirrorSkeleton(
  isLoading: isLoading,
  shimmerColor: Colors.grey[300],
  child: ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.avatar),
        ),
        title: Text(item.name),
        subtitle: Text(item.email),
        trailing: Icon(Icons.arrow_forward),
      );
    },
  ),
)
```

MirrorSkeleton automatically detects:
- ✅ Leading circular avatar
- ✅ Title and subtitle text lines
- ✅ Trailing icon

**Result**: Beautiful ListTile skeleton without any configuration!

---

### Example 2: Complex Nested Layout

```dart
MirrorSkeleton(
  isLoading: isLoading,
  child: SingleChildScrollView(
    child: Column(
      children: [
        // Header
        Container(
          height: 200,
          child: Image.network(url),
        ),
        // Title
        Text('Product Title'),
        // Details in a Row
        Row(
          children: [
            CircleAvatar(), // User avatar
            Column(
              children: [
                Text('Author Name'),
                Text('Published Date'),
              ],
            ),
          ],
        ),
        // Description
        Text('Lorem ipsum...'),
      ],
    ),
  ),
)
```

MirrorSkeleton detects all nested elements automatically!

---

### Example 3: Custom Shimmer Color

```dart
MirrorSkeleton(
  isLoading: isLoading,
  shimmerColor: Color(0xFFE8F4F8), // Light blue
  child: MyWidget(),
)
```

---

## API Reference

### MirrorSkeleton

```dart
MirrorSkeleton({
  required bool isLoading,
  Color shimmerColor = const Color(0xFFE0E0E0),
  required Widget child,
})
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isLoading` | `bool` | required | When `true`, shows skeleton. When `false`, shows real UI. |
| `shimmerColor` | `Color` | `Color(0xFFE0E0E0)` | Color of the skeleton and shimmer effect |
| `child` | `Widget` | required | Your UI widget tree |

---

## How Detection Works

### Supported Elements

| Element | Detection | Renders As |
|---------|-----------|-----------|
| `Text` | via RenderParagraph | Multi-line text skeleton |
| `Image` | via RenderImage | Rectangle or circle (if square) |
| `CircleAvatar` | Size + shape detection | Circular skeleton |
| `ListTile` | Horizontal flex detection | Icon + title + subtitle |
| `Icon` | Size-based (8-64px square) | Rounded square |
| `Container` | Generic fallback | Rectangle |

### Unsupported Edge Cases

- **CustomPaint** widgets (rendered as plain rectangles)
- **Shimmer/Animation widgets** (may cause detection issues)
- **Highly custom layouts** (consider wrapping with `Visibility` instead)

---

## Performance

✅ **Single-pass detection** - Only scans tree once on first paint  
✅ **Minimal overhead** - Detection cached after first render  
✅ **No rebuilds** - Skeleton stays static during animation  
✅ **Smooth 60fps** - Optimized gradient animation  

---

## Troubleshooting

### "My layout looks wrong in skeleton mode"

**Issue**: Placeholder widgets don't match real UI structure.

**Solution**: Return the same widget tree structure for both loading and loaded states:

```dart
// ❌ Wrong
child: isLoading ? SizedBox() : MyWidget()

// ✅ Correct
child: MyWidget() // Return same structure always
```

---

### "Skeleton doesn't detect my custom widget"

**Issue**: Custom widgets aren't recognized.

**Solution**: MirrorSkeleton works by analyzing render objects. If your custom widget doesn't produce standard render objects (Text, Image, Container), wrap it:

```dart
// ❌ Won't be detected
MyCustomWidget()

// ✅ Will be detected as container
Container(
  child: MyCustomWidget(),
)
```

---

## Comparison with Skeletonizer

| Feature | MirrorSkeleton | Skeletonizer |
|---------|---|---|
| Configuration needed | ❌ None | ✅ Yes (Bone widgets) |
| Auto-detection | ✅ Full tree | ❌ Limited |
| Circular support | ✅ Auto | ❌ Manual |
| ListTile support | ✅ Auto | ❌ Manual |
| API simplicity | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| Customization | ⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## Example Project

Check the `/example` folder for a complete working demo with:
- User profile skeleton
- ListView skeleton
- Product detail skeleton
- Network image handling

---

## Contributing

Found a bug? Have a feature request?

1. Open an issue on [GitHub](https://github.com/yourname/mirror_skeleton)
2. Fork and submit a PR
3. Follow the code style (dartfmt, dart analyze)

---

## License

MIT License - See LICENSE file for details

---

## Roadmap

🔜 **v0.1.0** - Beta release with core features  
🔜 **v0.2.0** - Fluid shimmer physics (shape-aware gradients)  
🔜 **v0.3.0** - CustomPaint detection  
🔜 **v1.0.0** - Stable production release  

---

## Made with ❤️

Built to make Flutter loading states beautiful without the boilerplate.

**Got questions?** Create an issue or reach out on GitHub!
