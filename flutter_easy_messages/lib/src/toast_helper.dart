import 'package:flutter/material.dart';
import 'message_behavior.dart';
import 'message_config.dart';
import 'message_position.dart';
import 'message_style.dart';
import 'message_type.dart';
import 'toast_action.dart';
import 'toast_manager.dart';

/// Shows a customizable toast notification on the screen.
///
/// Displays a non-blocking message that automatically disappears after a set duration.
/// By default, toasts appear at the bottom center of the screen and can be configured
/// globally via [EasyMessageConfig].
///
/// Parameters:
/// - [message]: The text content to display
/// - [context]: Optional build context for navigation/rendering (if not provided, uses global navigator key)
/// - [messageType]: Visual style of the message (error, success, info, warning)
/// - [icon]: Optional custom icon widget
/// - [backgroundColor]: Optional custom background color
/// - [duration]: How long the toast remains visible
/// - [borderRadius]: Border radius of the toast container
/// - [position]: Where the toast appears on screen
/// - [offset]: Fine-tuning adjustment from the position
/// - [behavior]: How to handle if another toast is showing
/// - [maxLines]: Maximum lines before text wrapping
/// - [overflow]: Text overflow behavior
/// - [softWrap]: Whether text should wrap
/// - [textAlign]: Text alignment within the toast
/// - [fontSize]: Font size for toast text
/// - [fontWeight]: Font weight for toast text
/// - [fontFamily]: Font family for toast text
/// - [actions]: List of action buttons to display in the toast
/// - [errorDetails]: Additional error details that can be expanded
/// - [isPersistent]: If true, toast won't auto-dismiss
/// - [dismissible]: If true, user can tap to dismiss the toast
/// - [requestId]: Optional ID to track toasts for specific API requests
/// - [onShown]: Callback when toast is displayed
/// - [onDismissed]: Callback when toast is dismissed
void showAppToast(
  String message, {
  BuildContext? context,
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
  Duration? duration,
  double? borderRadius,
  MessagePosition? position,
  Offset? offset,
  MessageBehavior? behavior,
  int? maxLines,
  TextOverflow? overflow,
  bool? softWrap,
  TextAlign? textAlign,
  double? fontSize,
  FontWeight? fontWeight,
  String? fontFamily,
  List<ToastAction>? actions,
  String? errorDetails,
  bool isPersistent = false,
  bool dismissible = false,
  String? requestId,
  VoidCallback? onShown,
  VoidCallback? onDismissed,
}) {
  // Input validation
  assert(message.isNotEmpty, 'Message cannot be empty');
  assert(
    duration == null || duration.inMilliseconds > 0,
    'Duration must be positive',
  );
  assert(
    borderRadius == null || borderRadius >= 0,
    'Border radius cannot be negative',
  );
  assert(maxLines == null || maxLines > 0, 'Max lines must be positive');
  assert(
    context != null || EasyMessageConfig.navigatorKey != null,
    'Either provide BuildContext or call EasyMessageConfig.setNavigatorKey() first',
  );

  final style = resolveMessageStyle(
    messageType: messageType,
    icon: icon,
    backgroundColor: backgroundColor,
  );

  final toastDuration = duration ?? EasyMessageConfig.defaultToastDuration;
  final toastBorderRadius =
      borderRadius ?? EasyMessageConfig.defaultBorderRadius;
  final toastPosition = position ?? EasyMessageConfig.defaultToastPosition;
  final toastOffset = offset ?? EasyMessageConfig.defaultToastOffset;
  final toastBehavior = behavior ?? EasyMessageConfig.defaultToastBehavior;
  final toastFontSize = fontSize ?? EasyMessageConfig.defaultToastFontSize;
  final toastFontWeight =
      fontWeight ?? EasyMessageConfig.defaultToastFontWeight;
  final toastFontFamily =
      fontFamily ?? EasyMessageConfig.defaultToastFontFamily;

  ToastManager.show(
    request: ToastRequest(
      context: context,
      message: message,
      icon: style.icon,
      backgroundColor: style.backgroundColor,
      duration: toastDuration,
      borderRadius: toastBorderRadius,
      position: toastPosition,
      offset: toastOffset,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
      textAlign: textAlign,
      fontSize: toastFontSize,
      fontWeight: toastFontWeight,
      fontFamily: toastFontFamily,
      actions: actions,
      errorDetails: errorDetails,
      isPersistent: isPersistent,
      dismissible: dismissible,
      requestId: requestId,
      onShown: onShown,
      onDismissed: onDismissed,
    ),
    queue: toastBehavior == MessageBehavior.queue,
  );
}
