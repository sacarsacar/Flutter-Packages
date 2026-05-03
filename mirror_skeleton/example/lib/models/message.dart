import 'package:flutter/material.dart';

class Message {
  final String sender;
  final String preview;
  final String time;
  final Color avatarColor;
  final int unread;

  const Message({
    required this.sender,
    required this.preview,
    required this.time,
    required this.avatarColor,
    required this.unread,
  });

  factory Message.placeholder() => const Message(
    sender: 'Loading sender',
    preview: 'Latest message preview text in the conversation list',
    time: '00:00',
    avatarColor: Color(0xFFB0BEC5),
    unread: 0,
  );
}
