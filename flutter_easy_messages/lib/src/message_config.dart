import 'package:flutter/material.dart';
import 'message_behavior.dart';
import 'message_position.dart';

class EasyMessageConfig {
  static Duration defaultToastDuration = const Duration(seconds: 2);
  static Duration defaultSnackBarDuration = const Duration(seconds: 3);
  static double defaultBorderRadius = 12;
  static MessagePosition defaultToastPosition = MessagePosition.bottomCenter;
  static Offset defaultToastOffset = Offset.zero;
  static MessageBehavior defaultToastBehavior = MessageBehavior.replace;
  static MessageBehavior defaultSnackBarBehavior = MessageBehavior.replace;
  static Duration defaultToastEntryAnimationDuration = const Duration(
    milliseconds: 400,
  );
  static Duration defaultToastExitAnimationDuration = const Duration(
    milliseconds: 300,
  );
  static Duration defaultToastPulseAnimationDuration = const Duration(
    milliseconds: 600,
  );
  static Duration defaultToastPulseReverseAnimationDuration = const Duration(
    milliseconds: 600,
  );
  static double defaultToastPulseScale = 1.05;
  static bool enableToastPulse = true;

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
