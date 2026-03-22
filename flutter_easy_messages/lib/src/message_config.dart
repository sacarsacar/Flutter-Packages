import 'package:flutter/material.dart';
import 'message_behavior.dart';
import 'message_position.dart';

/// Configuration class for customizing default behavior of toast and snackbar messages.
///
/// This class provides static properties and methods to configure global defaults
/// for all toast notifications and snackbars throughout the application.
/// Use the [configure] method to update default settings, or modify individual
/// static properties directly.
///
/// Example:
/// ```dart
/// EasyMessageConfig.configure(
///   toastDuration: Duration(seconds: 3),
///   borderRadius: 16.0,
///   toastPosition: MessagePosition.topCenter,
///   enablePulse: true,
/// );
/// ```
class EasyMessageConfig {
  /// Default duration for displaying toast messages.
  ///
  /// Defaults to 2 seconds. Can be overridden per message or globally.
  static Duration defaultToastDuration = const Duration(seconds: 2);

  /// Default duration for displaying snackbar messages.
  ///
  /// Defaults to 3 seconds. Can be overridden per message or globally.
  static Duration defaultSnackBarDuration = const Duration(seconds: 3);

  /// Default border radius for message containers (in logical pixels).
  ///
  /// Defaults to 12. Controls the roundedness of toast and snackbar corners.
  static double defaultBorderRadius = 12;

  /// Default position where toast messages appear on the screen.
  ///
  /// Defaults to [MessagePosition.bottomCenter]. See [MessagePosition] for all
  /// available positions.
  static MessagePosition defaultToastPosition = MessagePosition.bottomCenter;

  /// Default offset from the default position for toast messages.
  ///
  /// Defaults to [Offset.zero]. Use to fine-tune the exact position of toasts.
  static Offset defaultToastOffset = Offset.zero;

  /// Default behavior when toast is shown while another is displayed.
  ///
  /// See [MessageBehavior] for available options. Defaults to [MessageBehavior.replace].
  static MessageBehavior defaultToastBehavior = MessageBehavior.replace;

  /// Default behavior when snackbar is shown while another is displayed.
  ///
  /// See [MessageBehavior] for available options. Defaults to [MessageBehavior.replace].
  static MessageBehavior defaultSnackBarBehavior = MessageBehavior.replace;

  /// Duration of the toast entry (show) animation.
  ///
  /// Defaults to 400 milliseconds. Controls how quickly toasts fade/slide into view.
  static Duration defaultToastEntryAnimationDuration = const Duration(
    milliseconds: 400,
  );

  /// Duration of the toast exit (hide) animation.
  ///
  /// Defaults to 300 milliseconds. Controls how quickly toasts fade/slide out of view.
  static Duration defaultToastExitAnimationDuration = const Duration(
    milliseconds: 300,
  );

  /// Duration of the toast pulse (scale up) animation.
  ///
  /// Defaults to 600 milliseconds. Only used when [enableToastPulse] is true.
  static Duration defaultToastPulseAnimationDuration = const Duration(
    milliseconds: 600,
  );

  /// Duration of the toast pulse reverse (scale down) animation.
  ///
  /// Defaults to 600 milliseconds. Only used when [enableToastPulse] is true.
  static Duration defaultToastPulseReverseAnimationDuration = const Duration(
    milliseconds: 600,
  );

  /// Scale factor for the pulse animation on toasts.
  ///
  /// Defaults to 1.05 (5% larger). Only used when [enableToastPulse] is true.
  static double defaultToastPulseScale = 1.05;

  /// Whether pulse animation is enabled for toasts.
  ///
  /// Defaults to true. When enabled, toasts will have a subtle scale animation.
  static bool enableToastPulse = true;

  /// Configures global default settings for all toast and snackbar messages.
  ///
  /// Call this method during app initialization to set up your preferred defaults.
  /// All parameters are optional.
  ///
  /// Parameters:
  /// - [toastDuration]: How long toasts remain visible
  /// - [snackBarDuration]: How long snackbars remain visible
  /// - [borderRadius]: Border radius of message containers
  /// - [toastPosition]: Where toasts appear on screen
  /// - [toastOffset]: Offset adjustment from the position
  /// - [toastBehavior]: How to handle multiple toasts
  /// - [snackBarBehavior]: How to handle multiple snackbars
  /// - [toastEntryAnimationDuration]: Animation duration when showing
  /// - [toastExitAnimationDuration]: Animation duration when hiding
  /// - [toastPulseAnimationDuration]: Duration of scale-up animation
  /// - [toastPulseReverseAnimationDuration]: Duration of scale-down animation
  /// - [toastPulseScale]: Scale factor for pulse animation
  /// - [enablePulse]: Enable/disable pulse animation
  static void configure({
    Duration? toastDuration,
    Duration? snackBarDuration,
    double? borderRadius,
    MessagePosition? toastPosition,
    Offset? toastOffset,
    MessageBehavior? toastBehavior,
    MessageBehavior? snackBarBehavior,
    Duration? toastEntryAnimationDuration,
    Duration? toastExitAnimationDuration,
    Duration? toastPulseAnimationDuration,
    Duration? toastPulseReverseAnimationDuration,
    double? toastPulseScale,
    bool? enablePulse,
  }) {
    if (toastDuration != null) {
      defaultToastDuration = toastDuration;
    }

    if (snackBarDuration != null) {
      defaultSnackBarDuration = snackBarDuration;
    }

    if (borderRadius != null) {
      defaultBorderRadius = borderRadius;
    }

    if (toastPosition != null) {
      defaultToastPosition = toastPosition;
    }

    if (toastOffset != null) {
      defaultToastOffset = toastOffset;
    }

    if (toastBehavior != null) {
      defaultToastBehavior = toastBehavior;
    }

    if (snackBarBehavior != null) {
      defaultSnackBarBehavior = snackBarBehavior;
    }

    if (toastEntryAnimationDuration != null) {
      defaultToastEntryAnimationDuration = toastEntryAnimationDuration;
    }

    if (toastExitAnimationDuration != null) {
      defaultToastExitAnimationDuration = toastExitAnimationDuration;
    }

    if (toastPulseAnimationDuration != null) {
      defaultToastPulseAnimationDuration = toastPulseAnimationDuration;
    }

    if (toastPulseReverseAnimationDuration != null) {
      defaultToastPulseReverseAnimationDuration =
          toastPulseReverseAnimationDuration;
    }

    if (toastPulseScale != null) {
      defaultToastPulseScale = toastPulseScale;
    }

    if (enablePulse != null) {
      enableToastPulse = enablePulse;
    }
  }

  /// Resets all configuration to default values.
  ///
  /// Use this method to restore the package's default settings.
  static void reset() {
    defaultToastDuration = const Duration(seconds: 2);
    defaultSnackBarDuration = const Duration(seconds: 3);
    defaultBorderRadius = 12;
    defaultToastPosition = MessagePosition.bottomCenter;
    defaultToastOffset = Offset.zero;
    defaultToastBehavior = MessageBehavior.replace;
    defaultSnackBarBehavior = MessageBehavior.replace;
    defaultToastEntryAnimationDuration = const Duration(milliseconds: 400);
    defaultToastExitAnimationDuration = const Duration(milliseconds: 300);
    defaultToastPulseAnimationDuration = const Duration(milliseconds: 600);
    defaultToastPulseReverseAnimationDuration = const Duration(
      milliseconds: 600,
    );
    defaultToastPulseScale = 1.05;
    enableToastPulse = true;
  }
}
