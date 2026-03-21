import 'package:flutter/material.dart';
import 'message_config.dart';
import 'message_position.dart';

class ToastWidget extends StatefulWidget {
  final String message;
  final Widget? icon;
  final Color backgroundColor;
  final double borderRadius;
  final MessagePosition position;
  final Offset offset;
  final VoidCallback? onDismissed;

  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextAlign? textAlign;

  const ToastWidget({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.borderRadius,
    required this.position,
    required this.offset,
    this.icon,
    this.onDismissed,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textAlign,
  });

  @override
  State<ToastWidget> createState() => ToastWidgetState();
}

class ToastWidgetState extends State<ToastWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entryExitController;
  late final AnimationController _pulseController;

  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;

  bool _isDismissing = false;

  Alignment _resolveAlignment(MessagePosition position) {
    switch (position) {
      case MessagePosition.topLeft:
        return Alignment.topLeft;
      case MessagePosition.topCenter:
        return Alignment.topCenter;
      case MessagePosition.topRight:
        return Alignment.topRight;
      case MessagePosition.centerLeft:
        return Alignment.centerLeft;
      case MessagePosition.center:
        return Alignment.center;
      case MessagePosition.centerRight:
        return Alignment.centerRight;
      case MessagePosition.bottomLeft:
        return Alignment.bottomLeft;
      case MessagePosition.bottomCenter:
        return Alignment.bottomCenter;
      case MessagePosition.bottomRight:
        return Alignment.bottomRight;
    }
  }

  EdgeInsets _resolvePadding(MessagePosition position) {
    switch (position) {
      case MessagePosition.topLeft:
      case MessagePosition.topCenter:
      case MessagePosition.topRight:
        return const EdgeInsets.fromLTRB(24, 24, 24, 0);

      case MessagePosition.centerLeft:
      case MessagePosition.center:
      case MessagePosition.centerRight:
        return const EdgeInsets.symmetric(horizontal: 24);

      case MessagePosition.bottomLeft:
      case MessagePosition.bottomCenter:
      case MessagePosition.bottomRight:
        return const EdgeInsets.fromLTRB(24, 0, 24, 100);
    }
  }

  Offset _initialSlideOffset(MessagePosition position) {
    switch (position) {
      case MessagePosition.topLeft:
      case MessagePosition.topCenter:
      case MessagePosition.topRight:
        return const Offset(0, -0.18);

      case MessagePosition.centerLeft:
        return const Offset(-0.18, 0);
      case MessagePosition.center:
        return const Offset(0, 0.08);
      case MessagePosition.centerRight:
        return const Offset(0.18, 0);

      case MessagePosition.bottomLeft:
      case MessagePosition.bottomCenter:
      case MessagePosition.bottomRight:
        return const Offset(0, 0.18);
    }
  }

  @override
  void initState() {
    super.initState();

    _entryExitController = AnimationController(
      vsync: this,
      duration: EasyMessageConfig.defaultToastEntryAnimationDuration,
      reverseDuration: EasyMessageConfig.defaultToastExitAnimationDuration,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: EasyMessageConfig.defaultToastPulseAnimationDuration,
      reverseDuration:
          EasyMessageConfig.defaultToastPulseReverseAnimationDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryExitController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(
          begin: _initialSlideOffset(widget.position),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _entryExitController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _scaleAnimation =
        Tween<double>(
          begin: 1.0,
          end: EasyMessageConfig.defaultToastPulseScale,
        ).animate(
          CurvedAnimation(
            parent: _pulseController,
            curve: Curves.easeOut,
            reverseCurve: Curves.easeIn,
          ),
        );

    _entryExitController.forward();
  }

  Future<void> dismiss() async {
    if (!mounted || _isDismissing) return;

    _isDismissing = true;

    if (EasyMessageConfig.enableToastPulse) {
      await _pulseController.forward();
      await _pulseController.reverse();
    }

    if (!mounted) return;

    await _entryExitController.reverse();

    if (mounted) {
      widget.onDismissed?.call();
    }
  }

  @override
  void dispose() {
    _entryExitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alignment = _resolveAlignment(widget.position);
    final padding = _resolvePadding(widget.position);

    return Positioned.fill(
      child: SafeArea(
        child: Align(
          alignment: alignment,
          child: Padding(
            padding: padding,
            child: Transform.translate(
              offset: widget.offset,
              child: Material(
                color: Colors.transparent,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Semantics(
                        label: widget.message,
                        enabled: true,
                        onDismiss: dismiss,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: widget.backgroundColor,
                            borderRadius: BorderRadius.circular(
                              widget.borderRadius,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) widget.icon!,
                              if (widget.icon != null) const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  widget.message,
                                  maxLines: widget.maxLines,
                                  overflow: widget.overflow,
                                  softWrap: widget.softWrap,
                                  textAlign: widget.textAlign,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
