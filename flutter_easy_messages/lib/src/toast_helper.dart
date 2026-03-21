import 'package:flutter/material.dart';
import 'message_style.dart';
import 'message_type.dart';

void showAppToast(
  BuildContext context,
  String message, {
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

  final overlayState = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        bottom: 100,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (style.icon != null) style.icon!,
                    if (style.icon != null) const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlayState.insert(overlayEntry);

  Future.delayed(duration ?? const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
}
