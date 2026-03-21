import 'package:flutter/material.dart';
import 'message_behavior.dart';
import 'message_config.dart';
import 'message_position.dart';
import 'message_style.dart';
import 'message_type.dart';
import 'toast_manager.dart';

void showAppToast(
  BuildContext context,
  String message, {
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
    ),
    queue: toastBehavior == MessageBehavior.queue,
  );
}
