import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'message_config.dart';
import 'message_position.dart';
import 'toast_action.dart';
import 'toast_widget.dart';

/// Represents a request to display a toast notification.
///
/// Contains all the configuration needed to display a toast message,
/// including content, styling, positioning, animation parameters, actions, and callbacks.
class ToastRequest {
  final BuildContext? context;
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
  final double fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final List<ToastAction>? actions;
  final String? errorDetails;
  final bool isPersistent;
  final bool dismissible;
  final String? requestId;
  final VoidCallback? onShown;
  final VoidCallback? onDismissed;

  ToastRequest({
    this.context,
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
    required this.fontSize,
    required this.fontWeight,
    this.fontFamily,
    this.actions,
    this.errorDetails,
    this.isPersistent = false,
    this.dismissible = false,
    this.requestId,
    this.onShown,
    this.onDismissed,
  });

  String get dedupKey =>
      '$message|$backgroundColor|$position|${offset.dx}|${offset.dy}|${duration.inMilliseconds}|$borderRadius';
}

/// Manages the display and queue of toast notifications.
///
/// This class is responsible for showing, queuing, and dismissing toasts.
/// It maintains a queue of pending toasts and handles the orchestration
/// of toast display based on the configured behavior (replace or queue).
class ToastManager {
  ToastManager._();

  static final Queue<ToastRequest> _queue = Queue<ToastRequest>();
  static final Map<String, List<OverlayEntry>> _entriesByRequestId = {};

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
          fontSize: request.fontSize,
          fontWeight: request.fontWeight,
          fontFamily: request.fontFamily,
          actions: request.actions,
          errorDetails: request.errorDetails,
          isPersistent: request.isPersistent,
          dismissible: request.dismissible,
          onDismissed: () {
            _removeEntrySafely(overlayEntry);
            request.onDismissed?.call();
            _showNext();
          },
        );
      },
    );

    _currentEntry = overlayEntry;
    _currentToastKey = toastKey;
    _currentRequest = request;
    _isShowing = true;

    // Track by request ID if provided
    if (request.requestId != null) {
      _entriesByRequestId.putIfAbsent(request.requestId!, () => []);
      _entriesByRequestId[request.requestId]!.add(overlayEntry);
    }

    // Get overlay from context or navigator key
    final overlayState = request.context != null
        ? Overlay.of(request.context!)
        : EasyMessageConfig.navigatorKey?.currentState?.overlay;

    assert(
      overlayState != null,
      'Could not find overlay. Either provide BuildContext or ensure navigator key is set',
    );

    if (overlayState != null) {
      overlayState.insert(overlayEntry);
    } else {
      throw Exception(
        'No overlay found. Please ensure either: '
        '(1) You provided a BuildContext, or '
        '(2) You called EasyMessageConfig.setNavigatorKey() in main() and passed the key to MaterialApp',
      );
    }

    // Invoke onShown callback
    request.onShown?.call();

    // Cancel and reset previous timer
    _currentTimer?.cancel();
    _currentTimer = null;

    // Set new timer for dismissal (skip if persistent)
    if (!request.isPersistent) {
      _currentTimer = Timer(request.duration, () async {
        // Only dismiss if this is still the current toast
        if (_currentRequest == request) {
          await dismissCurrent();
        }
      });
    }
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

    // Clean up request ID tracking
    if (_currentRequest?.requestId != null) {
      _entriesByRequestId[_currentRequest!.requestId]?.remove(entry);
      if (_entriesByRequestId[_currentRequest!.requestId]?.isEmpty ?? false) {
        _entriesByRequestId.remove(_currentRequest!.requestId);
      }
    }

    _currentEntry = null;
    _currentToastKey = null;
    _currentTimer = null;
    _currentRequest = null;
    _isShowing = false;
  }

  /// Clear all toasts associated with a specific request ID
  static Future<void> clearByRequestId(String requestId) async {
    final entries = _entriesByRequestId[requestId];
    if (entries == null) return;

    for (final entry in entries.toList()) {
      try {
        entry.remove();
      } catch (_) {
        // Already removed
      }
    }

    _entriesByRequestId.remove(requestId);
  }

  /// Get the count of toasts for a specific request ID
  static int getToastCountByRequestId(String requestId) {
    return _entriesByRequestId[requestId]?.length ?? 0;
  }

  static Future<void> _showNext() async {
    if (_queue.isEmpty || _isShowing) return;

    final next = _queue.removeFirst();
    await _showNow(next);
  }

  /// Clear all queued and displayed toasts
  static Future<void> clearAll() async {
    _queue.clear();
    _entriesByRequestId.clear();
    await dismissCurrent();
  }
}
