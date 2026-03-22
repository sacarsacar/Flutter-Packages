import 'package:flutter/material.dart';
import 'message_type.dart';

/// Represents the visual styling for a message (color and icon).
class MessageStyle {
  /// Background color of the message
  final Color backgroundColor;

  /// Icon widget displayed in the message
  final Widget? icon;

  const MessageStyle({required this.backgroundColor, this.icon});
}

MessageStyle resolveMessageStyle({
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
}) {
  // Prioritize custom backgroundColor over message type
  if (backgroundColor != null) {
    return MessageStyle(icon: icon, backgroundColor: backgroundColor);
  }

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

  return MessageStyle(icon: icon, backgroundColor: Colors.black87);
}
