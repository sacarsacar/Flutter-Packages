import 'package:flutter/material.dart';

/// Represents an action button that can be displayed in a toast notification.
///
/// Actions allow users to interact with toasts, such as retrying failed operations
/// or dismissing messages.
///
/// Example:
/// ```dart
/// showAppToast(
///   'Failed to upload',
///   messageType: MessageType.error,
///   actions: [
///     ToastAction(
///       label: 'Retry',
///       onPressed: () => retryUpload(),
///     ),
///     ToastAction(
///       label: 'Dismiss',
///       onPressed: () => ToastManager.dismissCurrent(),
///     ),
///   ],
/// );
/// ```
class ToastAction {
  /// The label text displayed on the action button
  final String label;

  /// Called when the action button is pressed
  final VoidCallback onPressed;

  /// Optional custom button color (defaults to white)
  final Color? color;

  /// Optional custom text color for the button label
  final Color? textColor;

  const ToastAction({
    required this.label,
    required this.onPressed,
    this.color,
    this.textColor,
  });
}
