# 🍞 Flutter Easy Messages

A powerful, elegant, and highly customizable Flutter package for displaying toast notifications and snackbars. Built for both simple notifications and complex enterprise scenarios like API error handling, file operations, and request tracking.

[![Pub](https://img.shields.io/pub/v/flutter_easy_messages.svg)](https://pub.dev/packages/flutter_easy_messages)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://img.shields.io/badge/Tests-30%2F30%20Passing-brightgreen)](https://github.com/sacarsacar/Flutter-Packages)
[![Analysis](https://img.shields.io/badge/Analysis-0%20Issues-brightgreen)](https://pub.dev/packages/flutter_easy_messages)
[![Dart](https://img.shields.io/badge/Dart-3.11%2B-blue)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-1.17%2B-blue)](https://flutter.dev)

---

## ✨ Features Overview

### 🎯 Core Features
- **🍞 Toast Notifications** - Overlay-based notifications with smooth animations and multiple styling options
- **📱 Responsive Snackbars** - Automatic sizing that adapts to mobile, tablet, and desktop screens
- **🎨 Message Types** - 4 pre-styled message types: Error, Success, Info, Warning
- **📍 9 Position Options** - Complete positioning flexibility: top/center/bottom with left/center/right alignment
- **⚡ Smooth Animations** - Customizable entry, exit, and pulse animations with preset speeds
- **🔄 Queue & Replace Modes** - Control how multiple messages are handled (queue sequentially or replace)
- **📲 Full Responsiveness** - Automatic layout adjustments for all screen sizes and orientations
- **♿ Accessibility** - Screen reader integration with semantic labels for inclusive apps
- **🎯 Smart Config** - Global defaults with per-message overrides for maximum flexibility

### 🚀 Advanced Features (Enterprise-Ready)
- **🔘 Action Buttons** - Add interactive retry, cancel, or custom buttons to toasts
- **📋 Expandable Error Details** - Display detailed error information that users can expand on demand
- **⏳ Persistent Toasts** - Long-running operation toasts that don't auto-dismiss
- **👆 Dismissible Toasts** - User-controlled dismissal with intuitive tap-to-close gesture
- **🆔 Request ID Tracking** - Track and manage toasts by request ID for API correlation
- **📞 Lifecycle Callbacks** - React to toast lifecycle events (onShown, onDismissed)
- **📝 Custom Text Styling** - Full control over font size, weight, family, and alignment
- **🌐 Context-Free Toasts** - Show toasts anywhere in your app without BuildContext
- **🎯 Deduplication** - Built-in prevention of duplicate messages

---

## 🎬 Demo

<table>
  <tr>
    <td align="center" width="50%">
      <b>Message Types & Colors</b><br>
      <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/flutter_easy_messages/demo/message_types.gif" width="250" alt="Message Types">
    </td>
    <td align="center" width="50%">
      <b>Snackbars</b><br>
      <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/flutter_easy_messages/demo/snackbar.gif" width="250" alt="Snackbars">
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <b>Toast Positions (9 Options)</b><br>
      <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/flutter_easy_messages/demo/positions.gif" width="250" alt="Toast Positions">
    </td>
    <td align="center" width="50%">
      <b>Custom Styling & Icons</b><br>
      <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/flutter_easy_messages/demo/styles.gif" width="250" alt="Custom Styling">
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <b>Animations & Durations</b><br>
      <img src="https://raw.githubusercontent.com/sacarsacar/Flutter-Packages/main/flutter_easy_messages/demo/animations_and_durations.gif" width="250" alt="Animations & Durations">
    </td>
  </tr>
</table>

---

## 🚀 Quick Start (2 Steps!)

### Step 1: Add to Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter_easy_messages: ^0.1.0
```

Then run:
```bash
flutter pub get
```

### Step 2: Use It!

```dart
import 'package:flutter_easy_messages/flutter_easy_messages.dart';

// Inside a widget with BuildContext
showAppToast(
  'Success!',
  context: context,
  messageType: MessageType.success,
);
```

That's it! 🎉 No complex setup or configuration needed to get started.

---

## 📖 Complete Usage Guide

### 🍞 Basic Toast Notifications

#### Using Message Types

```dart
// Success Toast - Green with checkmark
showAppToast(
  'Operation completed successfully!',
  context: context,
  messageType: MessageType.success,
);

// Error Toast - Red with error icon
showAppToast(
  'Something went wrong',
  context: context,
  messageType: MessageType.error,
);

// Info Toast - Blue with info icon
showAppToast(
  'Here is some useful information',
  context: context,
  messageType: MessageType.info,
);

// Warning Toast - Orange with warning icon
showAppToast(
  'Please be careful with this action',
  context: context,
  messageType: MessageType.warning,
);
```

#### Custom Styling

```dart
showAppToast(
  'Custom styled notification',
  context: context,
  backgroundColor: Colors.purple,
  duration: Duration(seconds: 3),
  position: MessagePosition.topCenter,
  borderRadius: 20,
  icon: Icon(Icons.favorite, color: Colors.white),
  fontSize: 16,
  fontWeight: FontWeight.bold,
  fontFamily: 'Roboto',
  maxLines: 2,
  offset: Offset(0, 10),
);
```

#### Position Your Toasts (9 Options)

```dart
// Top positions
MessagePosition.topLeft        // ↖️  Top-left corner
MessagePosition.topCenter      // ⬆️  Top center
MessagePosition.topRight       // ↗️  Top-right corner

// Center positions (vertically centered)
MessagePosition.centerLeft     // ⬅️  Center-left
MessagePosition.center         // ⭕ Center screen
MessagePosition.centerRight    // ➡️  Center-right

// Bottom positions
MessagePosition.bottomLeft     // ↙️  Bottom-left corner
MessagePosition.bottomCenter   // ⬇️  Bottom center (default)
MessagePosition.bottomRight    // ↘️  Bottom-right corner
```

Real example:
```dart
showAppToast(
  'Important notification',
  context: context,
  messageType: MessageType.info,
  position: MessagePosition.topRight,
  duration: Duration(seconds: 4),
);
```

#### Managing Multiple Messages

```dart
// Replace Mode (default) - Only one toast visible at a time
for (int i = 1; i <= 3; i++) {
  showAppToast(
    'Message $i',
    context: context,
    behavior: MessageBehavior.replace,
  );
}
// Result: Only 'Message 3' is shown

// Queue Mode - Messages shown sequentially
for (int i = 1; i <= 3; i++) {
  showAppToast(
    'Message $i',
    context: context,
    behavior: MessageBehavior.queue,
  );
}
// Result: All 3 messages shown in order
```

### 📋 Snackbars

```dart
// Simple snackbar notification
showAppSnackBar(
  'This is a snackbar message',
  context: context,
  messageType: MessageType.success,
);

// Snackbar with custom styling
showAppSnackBar(
  'Customized snackbar',
  context: context,
  messageType: MessageType.info,
  duration: Duration(seconds: 4),
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
```

### 🌐 Context-Free Toasts (No BuildContext Needed!)

Perfect for showing toasts from services, utilities, and API calls without needing a BuildContext.

#### Setup (One-Time in `main.dart`)

```dart
import 'package:flutter_easy_messages/flutter_easy_messages.dart';

void main() {
  // Create a navigator key
  final navigatorKey = GlobalKey<NavigatorState>();

  // Set the navigator key FIRST
  EasyMessageConfig.setNavigatorKey(navigatorKey);

  // Optional: Configure global defaults
  EasyMessageConfig.configure(
    toastDuration: Duration(seconds: 2),
    borderRadius: 12,
    toastPosition: MessagePosition.bottomCenter,
    enablePulse: true,
  );

  runApp(MyApp(navigatorKey: navigatorKey));
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const MyApp({required this.navigatorKey, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,  // ← Pass the same key
      home: HomeScreen(),
    );
  }
}
```

#### Usage (Show Toasts Anywhere!)

```dart
// No context required!
showAppToast('Welcome back!', messageType: MessageType.success);

// In services
class AuthService {
  void logout() {
    showAppToast('Logged out successfully', messageType: MessageType.info);
  }
}

// In utility functions
void handleError(String error) {
  showAppToast(error, messageType: MessageType.error);
}

// In API calls
Future<void> fetchData() async {
  try {
    final data = await api.getData();
  } catch (e) {
    showAppToast('Failed to load data', messageType: MessageType.error);
  }
}
```

---

## 🎯 Advanced Features (Enterprise-Grade)

### 🔘 Action Buttons - Add Interactivity

Add retry, cancel, or custom action buttons to your toasts.

```dart
showAppToast(
  'Failed to upload document.pdf',
  context: context,
  messageType: MessageType.error,
  duration: Duration(seconds: 10),
  actions: [
    ToastAction(
      label: 'Retry',
      color: Colors.green,
      textColor: Colors.white,
      onPressed: () {
        retryUpload();
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

### 📋 Error Details - Expandable Information

Display detailed error information that users can expand when needed.

```dart
showAppToast(
  '❌ API Request Failed',
  context: context,
  messageType: MessageType.error,
  duration: Duration(seconds: 8),
  errorDetails:
      'Status Code: 500\n'
      'Endpoint: /api/v1/upload\n'
      'Error: Internal Server Error\n'
      'Request ID: REQ-123456789\n'
      'Timestamp: 2024-03-28 14:30:45 UTC',
);
```

User sees: `❌ API Request Failed [Show details]`  
Tapping reveals full error information.

### ⏳ Persistent Toasts - For Long Operations

Perfect for upload, download, or processing notifications that shouldn't auto-dismiss.

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
    // Called when toast appears
    startProcessing();
  },
  onDismissed: () {
    // Called when dismissed
    cleanup();
  },
);

// Later: Programmatically clear the toast
ToastManager.clearByRequestId('processing_pdf_001');
```

### 👆 Dismissible Toasts

Enable users to close notifications with a tap.

```dart
showAppToast(
  '👆 Tap anywhere on this toast to close it',
  context: context,
  messageType: MessageType.warning,
  dismissible: true,
  duration: Duration(seconds: 5),
);
```

### 🆔 Request ID Tracking

Track and manage toasts by request ID—ideal for API request correlation and preventing duplicates.

```dart
// Show toast for a specific request
showAppToast(
  'Processing order...',
  context: context,
  messageType: MessageType.info,
  isPersistent: true,
  requestId: 'order_checkout_001',
);

// Check how many toasts exist for this request
int count = ToastManager.getToastCountByRequestId('order_checkout_001');

// Clear all toasts for this request
await ToastManager.clearByRequestId('order_checkout_001');

// Clear everything
await ToastManager.clearAll();
```

### 📞 Lifecycle Callbacks

React to toast events—perfect for analytics, logging, and state management.

```dart
showAppToast(
  'Processing...',
  context: context,
  messageType: MessageType.info,
  isPersistent: true,
  onShown: () {
    // Called when toast appears on screen
    analytics.logEvent('notification_shown', {'message': 'Processing'});
    startTimer();
  },
  onDismissed: () {
    // Called when toast is dismissed
    analytics.logEvent('notification_dismissed', {'message': 'Processing'});
    stopTimer();
    refreshUI();
  },
);
```

---

## ⚙️ Global Configuration

Configure default behavior once in your `main()` function:

```dart
void main() {
  EasyMessageConfig.configure(
    // Duration settings
    toastDuration: Duration(seconds: 2),
    snackBarDuration: Duration(seconds: 3),
    
    // Animation timing
    toastEntryAnimationDuration: Duration(milliseconds: 400),
    toastExitAnimationDuration: Duration(milliseconds: 300),
    toastPulseAnimationDuration: Duration(milliseconds: 600),
    toastPulseReverseAnimationDuration: Duration(milliseconds: 600),
    
    // Styling
    borderRadius: 12,
    toastPulseScale: 1.05,
    
    // Positioning
    toastPosition: MessagePosition.bottomCenter,
    toastOffset: Offset(0, -20),
    
    // Behavior
    toastBehavior: MessageBehavior.replace,
    enablePulse: true,
  );
  
  runApp(MyApp());
}
```

### Available Configuration Properties

```dart
// Duration properties
toastDuration                        // Default: 2 seconds
snackBarDuration                     // Default: 3 seconds
toastEntryAnimationDuration          // Default: 400ms
toastExitAnimationDuration           // Default: 300ms
toastPulseAnimationDuration          // Default: 600ms
toastPulseReverseAnimationDuration   // Default: 600ms

// Style properties
borderRadius                         // Default: 12
toastPulseScale                      // Default: 1.05

// Position properties
toastPosition                        // Default: bottomCenter
toastOffset                          // Default: Offset.zero

// Behavior properties
toastBehavior                        // Default: replace
enablePulse                          // Default: true

// Text properties
toastFontSize                        // Default: 14
toastFontWeight                      // Default: normal
toastFontFamily                      // Default: system font
```

### Animation Presets

Use built-in animation speed presets for consistent animations:

```dart
// Instant (no animation)
EasyMessageConfig.configure(
  toastEntryAnimationDuration: AnimationPresets.instant.entry,
  toastExitAnimationDuration: AnimationPresets.instant.exit,
);

// Fast animations (200ms)
EasyMessageConfig.configure(
  toastEntryAnimationDuration: AnimationPresets.fast.entry,
  toastExitAnimationDuration: AnimationPresets.fast.exit,
);

// Normal animations (400ms) - default
EasyMessageConfig.configure(
  toastEntryAnimationDuration: AnimationPresets.normal.entry,
  toastExitAnimationDuration: AnimationPresets.normal.exit,
);

// Slow animations (600ms)
EasyMessageConfig.configure(
  toastEntryAnimationDuration: AnimationPresets.slow.entry,
  toastExitAnimationDuration: AnimationPresets.slow.exit,
);

// Extra slow animations (800ms)
EasyMessageConfig.configure(
  toastEntryAnimationDuration: AnimationPresets.extraSlow.entry,
  toastExitAnimationDuration: AnimationPresets.extraSlow.exit,
);
```

### Reset to Defaults

```dart
// Reset all configuration to defaults
EasyMessageConfig.reset();
```

---

## 💡 Real-World Examples

### API Error Handling with Retry

```dart
Future<void> uploadFile(File file) async {
  try {
    // Show progress toast
    showAppToast(
      '⏳ Uploading ${file.name}...',
      context: context,
      messageType: MessageType.info,
      isPersistent: true,
      requestId: 'upload_${file.hashCode}',
    );
    
    // Perform upload
    await api.uploadFile(file);
    
    // Clear progress toast
    await ToastManager.clearByRequestId('upload_${file.hashCode}');
    
    // Show success
    showAppToast(
      '✅ Upload complete!',
      context: context,
      messageType: MessageType.success,
    );
  } catch (e) {
    // Show error with retry button
    showAppToast(
      '❌ Upload failed: ${e.toString()}',
      context: context,
      messageType: MessageType.error,
      duration: Duration(seconds: 10),
      actions: [
        ToastAction(
          label: 'Retry',
          color: Colors.green,
          onPressed: () => uploadFile(file),
        ),
      ],
    );
  }
}
```

### Form Validation Feedback

```dart
void validateAndSubmitForm(Map<String, String> formData) {
  // Validate email
  if (formData['email']?.isEmpty ?? true) {
    showAppToast(
      'Email is required',
      context: context,
      messageType: MessageType.error,
      actions: [
        ToastAction(
          label: 'Fix',
          onPressed: () => _focusEmailField(),
        ),
      ],
    );
    return;
  }
  
  // Validate password
  if (formData['password']?.isEmpty ?? true) {
    showAppToast(
      'Password is required',
      context: context,
      messageType: MessageType.error,
    );
    return;
  }
  
  // All valid, submit
  submitForm(formData);
}
```

### Analytics & User Tracking

```dart
void trackUserAction(String actionName) {
  showAppToast(
    'Action tracked: $actionName',
    context: context,
    messageType: MessageType.info,
    onShown: () {
      // Log when notification is shown
      analytics.logEvent(
        'notification_shown',
        {
          'action': actionName,
          'timestamp': DateTime.now().toString(),
        },
      );
    },
    onDismissed: () {
      // Log when notification is dismissed
      analytics.logEvent(
        'notification_dismissed',
        {
          'action': actionName,
          'timestamp': DateTime.now().toString(),
        },
      );
    },
  );
}
```

### Network Status Monitoring

```dart
void monitorNetworkStatus() {
  // Show persistent notification while offline
  if (!isNetworkConnected) {
    showAppToast(
      '📡 No internet connection',
      context: context,
      messageType: MessageType.warning,
      isPersistent: true,
      dismissible: true,
      requestId: 'network_status',
    );
  } else {
    // Clear when connection restored
    ToastManager.clearByRequestId('network_status');
    showAppToast(
      '✅ Connection restored',
      context: context,
      messageType: MessageType.success,
    );
  }
}
```

---

## 🧠 Best Practices

### ✅ Do's
- ✓ **Keep messages short** - 1-2 lines maximum for better readability
- ✓ **Use appropriate types** - Match message type to severity level
- ✓ **Test responsiveness** - Verify appearance on multiple screen sizes
- ✓ **Use context-free for services** - Keep toasts in services/utilities without BuildContext
- ✓ **Provide clear actions** - Make action buttons clear and helpful
- ✓ **Use request IDs** - Track long operations with unique request IDs
- ✓ **Leverage callbacks** - Use lifecycle callbacks for analytics and state management

### ❌ Don'ts
- ✗ Don't spam users - Avoid showing multiple toasts unnecessarily
- ✗ Don't repeat messages - Use request ID tracking to prevent duplicates
- ✗ Don't keep toasts visible too long - 2-3 seconds is typically ideal
- ✗ Don't use complex layouts - Keep toast content simple and text-focused
- ✗ Don't reconfigure globally - Configure once in main(), not repeatedly
- ✗ Don't ignore responsive design - Always test on different screen sizes

---

## 🆘 Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Toasts not displaying | Missing BuildContext or no navigator key | Set navigator key via `EasyMessageConfig.setNavigatorKey()` or provide BuildContext |
| Choppy animations | Running in debug mode on slow device | Try `AnimationPresets.fast` or use release mode (`flutter run --release`) |
| Multiple toasts stacking | Using `MessageBehavior.queue` | Switch to `MessageBehavior.replace` (default) for single toast display |
| Custom icons not showing | Icon widget not configured properly | Verify icon widget is valid and has correct color settings |
| Context-free toast fails with error | Navigator key not set before use | Call `EasyMessageConfig.setNavigatorKey()` in `main()` BEFORE `runApp()` |
| Toasts appear too fast/slow | Global duration too short/long | Adjust `toastDuration` in `EasyMessageConfig.configure()` |

---

## 📊 Quality & Testing

| Metric | Status |
|--------|--------|
| Test Coverage | ✅ 30/30 tests passing (100%) |
| Code Analysis | ✅ 0 issues |
| Null Safety | ✅ Complete |
| Documentation | ✅ 90%+ coverage |
| Flutter Version | ✅ 1.17.0+ |
| Dart Version | ✅ 3.11.1+ |

### Test Areas Covered
- ✅ Message types and styling
- ✅ Toast positioning and animations
- ✅ Queue and replace behavior modes
- ✅ Context-free toast functionality
- ✅ Request ID tracking and management
- ✅ Action buttons
- ✅ Lifecycle callbacks (onShown, onDismissed)
- ✅ Configuration management
- ✅ Animation presets
- ✅ Responsive design

---

## 📱 Responsive Design


All toasts automatically adjust to:
- Screen width and height
- Safe area insets (notches, etc.)
- Keyboard visibility
- Device orientation (portrait/landscape)

Automatic layout adaptation for all screen sizes

---

## 📁 Project Architecture

```
flutter_easy_messages/
├── lib/
│   ├── flutter_easy_messages.dart          # Public API exports
│   └── src/
│       ├── toast_helper.dart               # Main toast function
│       ├── snackbar_helper.dart            # Snackbar function
│       ├── toast_manager.dart              # Toast orchestration & tracking
│       ├── toast_widget.dart               # UI rendering widget
│       ├── toast_action.dart               # Action button model
│       ├── message_config.dart             # Global configuration
│       ├── message_type.dart               # Message type enum
│       ├── message_style.dart              # Styling logic
│       ├── message_position.dart           # Position enum
│       ├── message_behavior.dart           # Behavior enum
│       ├── animation_presets.dart          # Animation presets
│       ├── responsive_utils.dart           # Responsive helpers
│       └── scale_presets.dart              # Scale presets
├── test/
│   └── flutter_easy_messages_test.dart     # 30 comprehensive unit tests
├── example/
│   ├── lib/
│   │   └── main.dart                       # Full demo app with 25+ examples
│   └── pubspec.yaml
├── pubspec.yaml                            # Package configuration
├── README.md                               # This file
└── CHANGELOG.md                            # Version history
```

---

## 🤝 Contributing

We welcome contributions from the community!

### How to Contribute

1. **Report Issues** - Found a bug? [Open an issue on GitHub](https://github.com/sacarsacar/Flutter-Packages/issues)
2. **Submit PRs** - Have improvements? Fork the repo and submit a pull request
3. **Improve Docs** - Help enhance documentation, examples, or translations
4. **Share Feedback** - Tell us how you're using the package

### Development Setup

```bash
# Clone the repository
git clone https://github.com/sacarsacar/Flutter-Packages.git
cd Flutter-Packages/flutter_easy_messages

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run the example app
cd example
flutter run
```

---

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](flutter_easy_messages/LICENSE) file for details.

---

## 📚 Resources

- **[Example App Source](flutter_easy_messages/example/)** - Running demo with 25+ examples
- **[GitHub Repository](https://github.com/sacarsacar/Flutter-Packages)** - Source code and issues
- **[Pub.dev Package](https://pub.dev/packages/flutter_easy_messages)** - View on package registry
- **[CHANGELOG](flutter_easy_messages/CHANGELOG.md)** - Version history and updates

---

## 🎓 Version History

### v0.1.0 - Current Release
- ✨ Comprehensive documentation with 90%+ coverage
- ✨ Full dartdoc comments on all public APIs
- ✨ Enhanced example app with comprehensive guide
- ✨ Improved pub.dev quality scoring
- ✅ 30/30 tests passing
- ✅ Zero analysis warnings

### Key Features Included
- 4 message types (Error, Success, Info, Warning)
- 9 positioning options
- Smooth animations with presets
- Queue/Replace behavior modes
- Responsive snackbars
- Full accessibility support
- Action buttons
- Error details with expansion
- Persistent toasts
- Dismissible toasts
- Request ID tracking
- Lifecycle callbacks (onShown, onDismissed)
- Context-free toasts (no BuildContext needed)
- Custom styling (font, size, color, etc.)
- 30/30 tests passing (100% coverage)
- Zero null safety issues

---

<div align="center">

**Made with ❤️ for the Flutter community**

⭐ If you find this package useful, please consider [giving it a star on GitHub](https://github.com/sacarsacar/Flutter-Packages)!

[GitHub](https://github.com/sacarsacar/Flutter-Packages) • [Pub.dev](https://pub.dev/packages/flutter_easy_messages) • [Report Issue](https://github.com/sacarsacar/Flutter-Packages/issues)

</div>
