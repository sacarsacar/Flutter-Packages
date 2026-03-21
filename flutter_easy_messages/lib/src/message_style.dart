import 'package:flutter/material.dart';
import 'message_type.dart';

class MessageStyle {
  final Widget? icon;
  final Color backgroundColor;

  const MessageStyle({required this.icon, required this.backgroundColor});
}

MessageStyle resolveMessageStyle({
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
}) {
  if (messageType != null) {
    switch (messageType) {
      case MessageType.error:
        return const MessageStyle(
          icon: Icon(Icons.error, color: Colors.white),
          backgroundColor: Colors.red,
        );
      case MessageType.success:
        return const MessageStyle(
          icon: Icon(Icons.check_circle, color: Colors.white),
          backgroundColor: Colors.green,
        );
      case MessageType.info:
        return const MessageStyle(
          icon: Icon(Icons.info, color: Colors.white),
          backgroundColor: Colors.blue,
        );
      case MessageType.warning:
        return const MessageStyle(
          icon: Icon(Icons.warning, color: Colors.white),
          backgroundColor: Colors.orange,
        );
    }
  }

  return MessageStyle(
    icon: icon,
    backgroundColor: backgroundColor ?? Colors.black87,
  );
}
