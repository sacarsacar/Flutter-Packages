import 'package:flutter/material.dart';
import 'message_style.dart';
import 'message_type.dart';

SnackBar buildAppSnackBar({
  required String message,
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
  Duration? duration,
}) {
  final style = resolveMessageStyle(
    messageType: messageType,
    icon: icon,
    backgroundColor: backgroundColor,
  );

  return SnackBar(
    padding: const EdgeInsets.all(10),
    behavior: SnackBarBehavior.floating,
    backgroundColor: style.backgroundColor,
    duration: duration ?? const Duration(seconds: 3),
    content: Row(
      children: [
        if (style.icon != null) style.icon!,
        if (style.icon != null) const SizedBox(width: 8),
        Expanded(
          child: Text(message, style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
  Duration? duration,
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    buildAppSnackBar(
      message: message,
      messageType: messageType,
      icon: icon,
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}
