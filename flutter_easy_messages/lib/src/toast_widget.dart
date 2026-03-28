import 'package:flutter/material.dart';
import 'message_config.dart';
import 'message_position.dart';
import 'toast_action.dart';

/// Internal widget for displaying an animated toast notification.
///
/// This widget handles the visual presentation and animations for toast messages.
/// It supports entry/exit animations, optional pulse animations, action buttons, and error details.
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
  final double fontSize;
  final FontWeight fontWeight;
  final String? fontFamily;
  final List<ToastAction>? actions;
  final String? errorDetails;
  final bool isPersistent;
  final bool dismissible;

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
    required this.fontSize,
    required this.fontWeight,
    this.fontFamily,
    this.actions,
    this.errorDetails,
    this.isPersistent = false,
    this.dismissible = false,
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
  bool _detailsExpanded = false;

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
                          child: GestureDetector(
                            onTap: widget.dismissible ? dismiss : null,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.icon != null) widget.icon!,
                                    if (widget.icon != null)
                                      const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        widget.message,
                                        maxLines: widget.maxLines,
                                        overflow: widget.overflow,
                                        softWrap: widget.softWrap,
                                        textAlign: widget.textAlign,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: widget.fontSize,
                                          fontWeight: widget.fontWeight,
                                          fontFamily: widget.fontFamily,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (widget.errorDetails != null) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => setState(
                                      () =>
                                          _detailsExpanded = !_detailsExpanded,
                                    ),
                                    child: Text(
                                      _detailsExpanded
                                          ? 'Hide details'
                                          : 'Show details',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  if (_detailsExpanded) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      widget.errorDetails!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11,
                                      ),
                                      maxLines: 5,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                                if (widget.actions != null &&
                                    widget.actions!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: widget.actions!
                                        .map(
                                          (action) => SizedBox(
                                            height: 28,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                action.onPressed();
                                                if (widget.dismissible) {
                                                  dismiss();
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color:
                                                      action.color ??
                                                      Colors.white54,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 4,
                                                    ),
                                              ),
                                              child: Text(
                                                action.label,
                                                style: TextStyle(
                                                  color:
                                                      action.textColor ??
                                                      Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ],
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
      ),
    );
  }
}
