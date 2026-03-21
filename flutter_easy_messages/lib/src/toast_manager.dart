import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'message_position.dart';
import 'toast_widget.dart';

class ToastRequest {
  final BuildContext context;
  final String message;
  final Widget? icon;
  final Color backgroundColor;
  final Duration duration;
  final double borderRadius;
  final MessagePosition position;
  final Offset offset;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextAlign? textAlign;

  ToastRequest({
    required this.context,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.duration,
    required this.borderRadius,
    required this.position,
    required this.offset,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textAlign,
  });

  String get dedupKey =>
      '$message|$backgroundColor|$position|${offset.dx}|${offset.dy}|${duration.inMilliseconds}|$borderRadius';
}

class ToastManager {
  ToastManager._();

  static final Queue<ToastRequest> _queue = Queue<ToastRequest>();

  static OverlayEntry? _currentEntry;
  static GlobalKey<ToastWidgetState>? _currentToastKey;
  static Timer? _currentTimer;
  static ToastRequest? _currentRequest;
  static bool _isShowing = false;

  static Future<void> show({
    required ToastRequest request,
    bool queue = false,
  }) async {
    if (!queue) {
      _queue.clear();
      await dismissCurrent();
      await _showNow(request);
      return;
    }

    if (_currentRequest != null &&
        _currentRequest!.dedupKey == request.dedupKey) {
      return;
    }

    final alreadyQueued = _queue.any(
      (item) => item.dedupKey == request.dedupKey,
    );

    if (alreadyQueued) {
      return;
    }

    if (_isShowing) {
      _queue.add(request);
    } else {
      await _showNow(request);
    }
  }

  static Future<void> _showNow(ToastRequest request) async {
    final toastKey = GlobalKey<ToastWidgetState>();

    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        return ToastWidget(
          key: toastKey,
          message: request.message,
          icon: request.icon,
          backgroundColor: request.backgroundColor,
          borderRadius: request.borderRadius,
          position: request.position,
          offset: request.offset,
          maxLines: request.maxLines,
          overflow: request.overflow,
          softWrap: request.softWrap,
          textAlign: request.textAlign,
          onDismissed: () {
            _removeEntrySafely(overlayEntry);
            _showNext();
          },
        );
      },
    );

    _currentEntry = overlayEntry;
    _currentToastKey = toastKey;
    _currentRequest = request;
    _isShowing = true;

    final overlay = Overlay.of(request.context);
    overlay.insert(overlayEntry);

    // Cancel and reset previous timer
    _currentTimer?.cancel();
    _currentTimer = null;

    // Set new timer for dismissal
    _currentTimer = Timer(request.duration, () async {
      // Only dismiss if this is still the current toast
      if (_currentRequest == request) {
        await dismissCurrent();
      }
    });
  }

  static Future<void> dismissCurrent() async {
    _currentTimer?.cancel();
    _currentTimer = null;

    final toastState = _currentToastKey?.currentState;
    final currentEntry = _currentEntry;

    if (currentEntry == null) return;

    if (toastState != null && toastState.mounted) {
      try {
        await toastState.dismiss();
      } catch (e) {
        // Silently catch dismiss errors
      }
    }

    // Always explicitly remove the entry after dismissal attempt
    // This ensures cleanup happens even if onDismissed callback doesn't fire
    _removeEntrySafely(currentEntry);
    _showNext();
  }

  static void _removeEntrySafely(OverlayEntry entry) {
    if (_currentEntry != entry) return;

    try {
      entry.remove();
    } catch (_) {
      // Already removed.
    }

    _currentEntry = null;
    _currentToastKey = null;
    _currentTimer = null;
    _currentRequest = null;
    _isShowing = false;
  }

  static Future<void> _showNext() async {
    if (_queue.isEmpty || _isShowing) return;

    final next = _queue.removeFirst();
    await _showNow(next);
  }
}
