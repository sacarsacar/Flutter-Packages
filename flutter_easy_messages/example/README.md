# Flutter Easy Messages Example

A comprehensive example app demonstrating all features of the `flutter_easy_messages` package.

## Overview

This example application shows how to use `flutter_easy_messages` to display toast notifications and snackbars with rich customization options and smooth animations. The app is fully responsive and works on mobile, tablet, and desktop.

## Features Demonstrated

- **Toast Notifications**: Display non-blocking messages at various screen positions
  - Different positions: top, center, bottom (left, center, right)
  - Custom animations and durations
  - Automatic dismissal
  
- **Snackbars**: Material Design compliant notifications
  - Responsive sizing
  - Custom styling
  - Integration with Scaffold

- **Message Types**: Pre-configured styles for different message categories
  - Success (green with checkmark)
  - Error (red with error icon)
  - Info (blue with info icon)
  - Warning (orange with warning icon)

- **Customization**: 
  - Global configuration via `EasyMessageConfig`
  - Per-message customization
  - Custom animations and timings
  - Custom icons and colors
  - Responsive behavior across device sizes

- **Animation Presets**: Pre-configured animation speeds
  - Fast, normal, slow, extra slow, instant

## Getting Started

### Prerequisites
- Flutter SDK 1.17.0 or higher
- Dart 3.11.1 or higher

### Running the Example

1. Navigate to this example directory:
   ```bash
   cd flutter_easy_messages/example
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Usage Examples

### Basic Toast
```dart
showAppToast(context, 'Hello, World!');
```

### Toast with Type
```dart
showAppToast(
  context,
  'Operation successful!',
  messageType: MessageType.success,
);
```

### Toast with Custom Position
```dart
showAppToast(
  context,
  'Custom position toast',
  position: MessagePosition.topCenter,
  duration: Duration(seconds: 3),
);
```

### Global Configuration
```dart
EasyMessageConfig.configure(
  toastDuration: Duration(seconds: 3),
  borderRadius: 16.0,
  toastPosition: MessagePosition.topCenter,
  enablePulse: true,
);
```

## App Structure

The example app includes:
- `main.dart`: App entry point with configuration and demo page
- `lib/`: Application source code
- Responsive UI that adapts to mobile, tablet, and desktop screens
- Interactive buttons to demonstrate various toast configurations
- Queue counter to show multiple toasts behavior

## Features in Action

The app demonstrates:
1. Different message types with their default styles
2. Toast positioning at all 9 available positions
3. Custom animation durations
4. Behavior modes (replace vs queue)
5. Responsive layout adjustments
6. Custom styling and animations

## Customization Guide

You can customize:
- Message appearance (color, border radius, icons)
- Animation timing and effects
- Display duration and position
- Behavior when multiple messages overlap
- Global defaults applied to all messages

For complete API documentation, visit [pub.dev](https://pub.dev/packages/flutter_easy_messages).
