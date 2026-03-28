# Flutter Easy Messages - Example App

A fully-featured, interactive demonstration of the `flutter_easy_messages` package showing all capabilities from basic toasts to enterprise-grade error handling and persistent notifications.

[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-1.17%2B-blue)](https://flutter.dev)
[![MIT License](https://img.shields.io/badge/License-MIT-yellow.svg)](../LICENSE)

---

## 📱 What's Inside

This example app demonstrates **25+ interactive features**:

### Core Features
- 🎨 **All 4 Message Types** - Success, Error, Info, Warning with pre-styled colors
- 📍 **9 Position Options** - Top, center, bottom with left/center/right variants
- 🔄 **Behavior Modes** - Queue vs Replace handling of multiple messages
- 📋 **Snackbars** - Material Design snackbars with custom styling

### Advanced Features
- ⚡ **Animation Presets** - Fast, Normal, Slow, Instant animation speeds
- 🎨 **Custom Styling** - Full control over colors, borders, icons, fonts
- 📝 **Custom Text** - Font family, size, weight, and alignment options
- ⏳ **Persistent Toasts** - Messages that don't auto-dismiss
- 👆 **Dismissible Toasts** - User-controlled dismissal with tap gesture
- 🔘 **Action Buttons** - Retry, cancel, and custom action buttons
- 📋 **Error Details** - Expandable error information display
- 🆔 **Request Tracking** - Track toasts with unique request IDs
- 🌐 **Context-Free Toasts** - Show toasts without BuildContext
- 🎯 **Responsive Design** - Adapts to mobile, tablet, and desktop
- 📊 **Full Accessibility** - Screen reader support and semantic labels

---

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 1.17.0 or higher
- Dart 3.11.1 or higher
- A connected device or emulator

### Installation & Run

```bash
# Clone the repository
git clone https://github.com/sacarsacar/Flutter-Packages.git
cd Flutter-Packages/flutter_easy_messages/example

# Get dependencies
flutter pub get

# Run the app
flutter run

# Or run in release mode for better performance
flutter run --release
```

---

## 📚 Complete Feature Guide

### 1. Message Types

**Screen Section**: Message Types

Demonstrates all 4 pre-styled message types with automatic colors and icons:

| Type | Color | Use Case |
|------|-------|----------|
| **Success** | Green ✓ | Completed operations, confirmations |
| **Error** | Red ✗ | Failures, exceptions, validation errors |
| **Info** | Blue ℹ️ | Information, notifications, updates |
| **Warning** | Orange ⚠️ | Cautions, warnings, important notices |

**Try it**:
```dart
showAppToast('Operation successful!', messageType: MessageType.success);
showAppToast('Something failed', messageType: MessageType.error);
showAppToast('Just so you know', messageType: MessageType.info);
showAppToast('Be careful!', messageType: MessageType.warning);
```

---

### 2. Snackbars

**Screen Section**: Snackbars

Traditional Material Design snackbars with full `flutter_easy_messages` support:

**Try it**:
```dart
showAppSnackBar(
  'Snackbar message',
  context: context,
  messageType: MessageType.success,
  duration: Duration(seconds: 3),
);
```

Perfect for:
- Page-level feedback messages
- Form submission responses
- Undo/action confirmations

---

### 3. Toast Positions (9 Options)

**Screen Section**: Toast Positions (3×3 Grid)

Position your toasts at any of 9 locations on screen:

```
┌─────────────────────────────┐
│ ↖️ Top-Left    ⬆️ Top-Center    ↗️ Top-Right   │
│                             │
│ ⬅️ Center-Left  ⭕ Center      ➡️ Center-Right│
│                             │
│ ↙️ Bottom-Left ⬇️ Bottom-Center ↘️ Bottom-Right│
└─────────────────────────────┘
```

**Try it**:
```dart
showAppToast(
  'Top right notification',
  context: context,
  messageType: MessageType.info,
  position: MessagePosition.topRight,
);
```

---

### 4. Behavior Modes

**Screen Section**: Behavior Modes

Control how multiple toasts interact:

#### Queue Mode
Shows 3 messages **one after another**, each waiting for the previous to dismiss.

```dart
showAppToast(
  'Message 1',
  context: context,
  behavior: MessageBehavior.queue,
);
// Wait 2 seconds, then:
showAppToast(
  'Message 2 (appears after Message 1 closes)',
  context: context,
  behavior: MessageBehavior.queue,
);
```

**Use Cases**: Sequential notifications, task lists, step-by-step feedback

#### Replace Mode (Default)
Shows only **one toast at a time**. New messages replace the current one.

```dart
showAppToast('Message 1', behavior: MessageBehavior.replace);
// Immediately replaced with:
showAppToast('Message 2 (Message 1 is gone)', behavior: MessageBehavior.replace);
```

**Use Cases**: Status updates, form validation, real-time feedback

---

### 5. Custom Styling

**Screen Section**: Custom Styling

Full control over toast appearance:

**Custom Color**:
```dart
showAppToast(
  'Purple notification',
  context: context,
  backgroundColor: Colors.purple,
);
```

**Custom Border**:
```dart
showAppToast(
  'Rounded corners',
  context: context,
  borderRadius: 20,
);
```

**Custom Icon**:
```dart
showAppToast(
  'With custom icon',
  context: context,
  icon: Icon(Icons.favorite, color: Colors.white),
  backgroundColor: Colors.pink,
);
```

**Multi-line Text**:
```dart
showAppToast(
  'This is a longer message that wraps to multiple lines for demonstration',
  context: context,
  maxLines: 3,
  overflow: TextOverflow.ellipsis,
);
```

---

### 6. Animation Presets

**Screen Section**: Animation Presets

Pre-configured animation speeds for consistent UX:

| Preset | Entry | Exit | Best For |
|--------|-------|------|----------|
| **Instant** | Immediate | Immediate | No animation desired |
| **Fast** | 200ms | 200ms | Snappy, responsive feel |
| **Normal** | 400ms | 300ms | Default, balanced feel |
| **Slow** | 600ms | 600ms | Subtle, elegant feel |
| **Extra Slow** | 800ms | 800ms | Slow, careful animations |

**Try it**:
```dart
// Fast animations for snappy feel
EasyMessageConfig.configure(
  toastEntryAnimationDuration: AnimationPresets.fast.entry,
  toastExitAnimationDuration: AnimationPresets.fast.exit,
);

showAppToast('Quick animation!');
```

---

### 7. Custom Text Styling

**Screen Section**: Custom Font & Size

Complete control over text appearance:

**Custom Font Family**:
```dart
showAppToast(
  'Custom Font',
  context: context,
  fontFamily: 'Roboto', // or any system font
);
```

**Large & Bold**:
```dart
showAppToast(
  'Big Message',
  context: context,
  fontSize: 20,
  fontWeight: FontWeight.bold,
);
```

**Custom Snackbar**:
```dart
showAppSnackBar(
  'Styled snackbar',
  context: context,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
```

---

### 8. Offset & Duration

**Screen Section**: Offset & Duration

Fine-tune positioning and visibility duration:

**Custom Offset** (move away from edge):
```dart
showAppToast(
  'Offset from bottom',
  context: context,
  position: MessagePosition.bottomCenter,
  offset: Offset(0, -50), // 50 pixels up from bottom center
);
```

**Long Duration** (stays longer):
```dart
showAppToast(
  'This message stays for 5 seconds',
  context: context,
  messageType: MessageType.success,
  duration: Duration(seconds: 5), // vs default 2 seconds
);
```

---

### 9. API Error Handling (Enterprise-Grade)

**Screen Section**: API Error Handling

Real-world error handling patterns:

#### A. Error with Retry Button

Perfect for recoverable errors:

```dart
showAppToast(
  'Failed to upload document.pdf',
  context: context,
  messageType: MessageType.error,
  duration: Duration(seconds: 10), // Stay longer for user action
  actions: [
    ToastAction(
      label: 'Retry',
      color: Colors.green,
      textColor: Colors.white,
      onPressed: () {
        uploadFile(); // Retry the operation
      },
    ),
    ToastAction(
      label: 'Cancel',
      color: Colors.red,
      textColor: Colors.white,
      onPressed: () {
        cancelOperation();
      },
    ),
  ],
);
```

#### B. Error with Expandable Details

Show technical details for debugging:

```dart
final now = DateTime.now();
showAppToast(
  '❌ API Request Failed',
  context: context,
  messageType: MessageType.error,
  duration: Duration(seconds: 8),
  errorDetails:
      'Status Code: 500\n'
      'Endpoint: /api/v1/upload\n'
      'Error: Internal Server Error\n'
      'Time: ${now.toIso8601String()}\n'
      'Request ID: REQ-${now.millisecondsSinceEpoch}',
);
```

User sees: `❌ API Request Failed [Show details]`  
Tap to expand and see full error info.

#### C. Persistent Processing Toast

For long-running operations (uploads, downloads):

```dart
showAppToast(
  '⏳ Processing PDF file...',
  context: context,
  messageType: MessageType.info,
  isPersistent: true,        // Won't auto-dismiss
  dismissible: true,          // User can tap to close
  duration: Duration(seconds: 999),
  requestId: 'processing_pdf_001',
  onShown: () {
    startPDFProcessing(); // Begin operation
  },
);

// Later, when done:
ToastManager.clearByRequestId('processing_pdf_001');
showAppToast(
  '✅ PDF processing complete!',
  context: context,
  messageType: MessageType.success,
);
```

#### D. Dismissible Toast

Let users close notifications on their schedule:

```dart
showAppToast(
  '👆 Tap anywhere on this toast to close it',
  context: context,
  messageType: MessageType.warning,
  dismissible: true,
  duration: Duration(seconds: 5),
);
```

---

### 10. Context-Free Toasts

**Screen Section**: Advanced Features

Show toasts **without BuildContext** from services, utilities, anywhere:

**Setup (in `main.dart`)** - do this once:
```dart
void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  EasyMessageConfig.setNavigatorKey(navigatorKey);
  
  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: HomeScreen(),
    );
  }
}
```

**Usage** - use anywhere, no context needed:
```dart
// In services, utilities, anywhere!
showAppToast('No BuildContext needed!', messageType: MessageType.success);

// With custom styling
showAppToast(
  'Advanced Styling - No Context!',
  fontSize: 18,
  fontWeight: FontWeight.bold,
);
```



---

## 🎨 Responsive Design

The app automatically adapts to any screen size:

### Mobile (< 600px)
- Single column button layout
- Full-width buttons
- Optimized touch targets (48-56px height)
- Compact spacing

### Tablet (600-1024px)
- Two column button layout
- 3×3 grid for position buttons
- Larger fonts and buttons
- Medium spacing

### Desktop (> 1024px)
- Three+ column button layout
- Maximum 900px width constraint
- Spacious layout with large fonts
- Generous spacing

Test responsiveness by:
```bash
# Run on different device sizes
flutter run -d ios      # iPhone
flutter run -d ipad     # iPad
flutter run -d windows  # Large desktop
```

---

## 💻 Implementation Architecture

### Global Configuration (main.dart)

```dart
void main() {
  final navigatorKey = GlobalKey<NavigatorState>();
  
  // Set navigator key FIRST
  EasyMessageConfig.setNavigatorKey(navigatorKey);
  
  // Configure global defaults
  EasyMessageConfig.configure(
    toastDuration: Duration(seconds: 2),
    borderRadius: 12,
    toastPosition: MessagePosition.bottomCenter,
    enablePulse: true,
  );
  
  runApp(ExampleApp(navigatorKey: navigatorKey));
}
```

### UI Architecture

The example uses modern Flutter patterns:

- **StatefulWidget** for state management
- **MediaQuery** for responsive design
- **responsive builder methods** for UI adaptation
- **Named parameters** for clean code
- **Helper methods** for demo logic

### Helper Methods

The example organizes feature demos into clean helper methods:

```dart
// Message demonstration
void _showMessageType(MessageType type, String message) { ... }

// Toast positioning
void _showToastAtPosition(MessagePosition position, String label) { ... }

// Behavior modes
void _showQueuedMessages() { ... }
void _showReplacedMessages() { ... }

// Styling
void _showPurpleToast() { ... }
void _showCustomFontToast() { ... }

// Advanced features
void _showErrorWithRetry() { ... }
void _showPersistentToast() { ... }
void _showContextFreeToast() { ... }
```

---

## 🧪 Testing Guide

### Quick Verification Checklist

#### ✓ Basic Functionality
- [ ] Tap "Success" - See green toast at bottom-center
- [ ] Tap "Error" - See red toast
- [ ] Tap "Info" - See blue toast
- [ ] Tap "Warning" - See orange toast
- [ ] Each toast disappears after ~2 seconds

#### ✓ Positioning
- [ ] Tap "Top Center" - Toast appears at top
- [ ] Tap "Center" - Toast centered on screen
- [ ] Tap "Bottom Left" - Toast at bottom-left corner
- [ ] All 9 positions work correctly

#### ✓ Behavior Modes
- [ ] Queue: 3 messages appear sequentially
- [ ] Replace: New messages replace previous ones

#### ✓ Advanced Features
- [ ] "With Retry" - Has action buttons that work
- [ ] "With Details" - Tap to expand error details
- [ ] "Persistent" - Toast stays until tapped
- [ ] "Dismissible" - Tap anywhere to close
- [ ] "No Context" - Works without BuildContext

#### ✓ Responsiveness
- [ ] Rotate device - Layout adapts correctly
- [ ] Desktop/tablet - Buttons arrange in multi-columns
- [ ] Mobile - Single column full-width buttons

---

## 📱 Device Testing

Run on different devices to test responsiveness:

```bash
# iPhone (mobile)
flutter run -d ios

# Android phone
flutter run -d emulator-5554

# iPad (tablet)
flutter run -d ipad

# Windows/macOS (desktop)
flutter run -d windows
flutter run -d macos
```

Or use AVD Manager / Xcode Simulator controls to adjust screen size dynamically.

---

## 📊 Feature Coverage

| Feature | Demo Button | Status |
|---------|------------|--------|
| Message Types | ✓ 4 buttons | ✅ Complete |
| Snackbars | ✓ 2 buttons | ✅ Complete |
| Toast Positions | ✓ 9×9 grid | ✅ Complete |
| Queue Mode | ✓ Queue Messages | ✅ Complete |
| Replace Mode | ✓ Replace Messages | ✅ Complete |
| Custom Colors | ✓ Purple, Teal | ✅ Complete |
| Custom Icon | ✓ With Icon | ✅ Complete |
| Multi-line | ✓ Multi-line | ✅ Complete |
| Fast Animation | ✓ Fast | ✅ Complete |
| Slow Animation | ✓ Slow | ✅ Complete |
| Custom Offset | ✓ Offset Toast | ✅ Complete |
| Long Duration | ✓ Long Duration | ✅ Complete |
| Retry Button | ✓ With Retry | ✅ Complete |
| Error Details | ✓ With Details | ✅ Complete |
| Persistent | ✓ Persistent Toast | ✅ Complete |
| Dismissible | ✓ Dismissible | ✅ Complete |
| No Context | ✓ No Context Toast | ✅ Complete |
| Custom Font | ✓ Custom Font | ✅ Complete |
| Custom Size | ✓ Large Bold | ✅ Complete |

---

## 💡 Learning Path

### Beginner
Start with these to understand basics:
1. Message Types - See all 4 pre-styled types
2. Toast Positions - Find the best placement
3. Snackbars - Understand UI patterns

### Intermediate
Build on basics:
4. Behavior Modes - Control multiple messages
5. Custom Styling - Customize appearance
6. Animation Presets - Choose animation speed

### Advanced
Explore enterprise features:
7. API Error Handling - Real-world error patterns
8. Persistent Toasts - Long operations
9. Request Tracking - Message management
10. Context-Free Toasts - Cross-layer usage

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| Toasts not appearing | Verify navigator key is set in main.dart |
| Choppy animations | Run in release mode: `flutter run --release` |
| Buttons not responsive | Check device orientation/screen size |
| Text not visible | Check font size and contrast, try smaller message |
| Context error | Ensure navigator key is configured before app start |
| Nothing happens on tap | Check that gestures are enabled (not disabled globally) |

---

## 📚 Next Steps

### 1. Read the Full Documentation
- [Main Package README](../README.md) - Complete feature reference
- [Package Changelog](../CHANGELOG.md) - Version history

### 2. Integrate into Your App
Copy patterns from this example into your own app:
- Use the global configuration setup
- Copy demo methods as templates
- Implement error handling patterns

### 3. Customize for Your Needs
- Adjust colors to match your brand
- Choose appropriate message types
- Select optimal toast positions
- Define notification behavior

### 4. Explore Advanced Features
After understanding basics:
- Implement request ID tracking
- Add lifecycle callbacks for analytics
- Create custom error handling flows
- Build service-level toast handlers

---

## 🎯 Key Takeaways

From this example app, you'll learn:

✅ **All 11 core features** of flutter_easy_messages  
✅ **Real-world error handling** patterns  
✅ **Responsive design** for multiple screen sizes  
✅ **Context-free architecture** for clean code  
✅ **Animation customization** techniques  
✅ **Enterprise-grade notifications** system  

---

## 🤝 Contribute

Have improvements for this example?

1. [Report Issues](https://github.com/sacarsacar/Flutter-Packages/issues) - Found a bug?
2. [Suggest Features](https://github.com/sacarsacar/Flutter-Packages/discussions) - Want more demos?
3. [Submit PRs](https://github.com/sacarsacar/Flutter-Packages/pulls) - Have enhancements?

---

<div align="center">

**Explore. Learn. Master. 🍞**

Start with "Message Types" section and work your way through all features!

[⬆ Back to Top](#flutter-easy-messages---example-app)

</div>
