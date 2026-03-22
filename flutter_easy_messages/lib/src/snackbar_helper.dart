import 'package:flutter/material.dart';
import 'message_behavior.dart';
import 'message_config.dart';
import 'message_style.dart';
import 'message_type.dart';
import 'responsive_utils.dart';

String? _lastSnackBarKey;

/// Builds a customizable snackbar widget.
///
/// Creates a [SnackBar] with styling, animation, and responsive behavior.
/// Use with [ScaffoldMessenger.of(context).showSnackBar()] to display.
///
/// Parameters:
/// - [context]: The build context for layout calculations
/// - [message]: Required text content to display
/// - [messageType]: Visual style of the snackbar (error, success, info, warning)
/// - [icon]: Optional custom icon widget
/// - [backgroundColor]: Optional custom background color
/// - [duration]: How long the snackbar remains visible
/// - [borderRadius]: Border radius of the snackbar container
/// - [maxLines]: Maximum lines before text wrapping
/// - [overflow]: Text overflow behavior
/// - [softWrap]: Whether text should wrap
/// - [textAlign]: Text alignment within the snackbar
/// - [responsive]: Whether to adapt size based on screen dimensions
/// - [mobileBreakpoint]: Screen width threshold for mobile layout
/// - [tabletBreakpoint]: Screen width threshold for tablet layout
/// - [tabletWidth]: Snackbar width on tablet devices
/// - [desktopWidth]: Snackbar width on desktop devices
/// - [mobileMargin]: Margin spacing on mobile devices
SnackBar buildAppSnackBar(
  BuildContext context, {
  required String message,
  MessageType? messageType,
  Widget? icon,
  Color? backgroundColor,
  Duration? duration,
  double? borderRadius,
  int? maxLines,
  TextOverflow? overflow,
  bool? softWrap,
  TextAlign? textAlign,
  bool responsive = true,
  double mobileBreakpoint = 600,
  double tabletBreakpoint = 1024,
  double tabletWidth = 520,
  double desktopWidth = 600,
  EdgeInsetsGeometry mobileMargin = const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  ),
}) {
  final style = resolveMessageStyle(
    messageType: messageType,
    icon: icon,
    backgroundColor: backgroundColor,
  );

  final screenWidth = MediaQuery.of(context).size.width;

  double? snackBarWidth;
  EdgeInsetsGeometry? snackBarMargin;

  if (responsive) {
    final responsiveSize = ResponsiveUtils.calculateResponsiveSize(
      screenWidth: screenWidth,
      mobileBreakpoint: mobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint,
      tabletWidth: tabletWidth,
      desktopWidth: desktopWidth,
      mobileMargin: mobileMargin,
    );
    snackBarWidth = responsiveSize.width;
    snackBarMargin = responsiveSize.margin;
  } else {
    snackBarMargin = mobileMargin;
  }

  return SnackBar(
    padding: const EdgeInsets.all(10),
    behavior: SnackBarBehavior.floating,
    width: snackBarWidth,
    margin: snackBarWidth == null ? snackBarMargin : null,
    backgroundColor: style.backgroundColor,
    duration: duration ?? EasyMessageConfig.defaultSnackBarDuration,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        borderRadius ?? EasyMessageConfig.defaultBorderRadius,
      ),
    ),
    content: Row(
      children: [
        if (style.icon != null) style.icon!,
        if (style.icon != null) const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            maxLines: maxLines,
            overflow: overflow,
            softWrap: softWrap,
            textAlign: textAlign,
            style: const TextStyle(color: Colors.white),
          ),
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
  double? borderRadius,
  MessageBehavior? behavior,
  bool preventDuplicate = true,
  int? maxLines,
  TextOverflow? overflow,
  bool? softWrap,
  TextAlign? textAlign,
  bool responsive = true,
  double mobileBreakpoint = 600,
  double tabletBreakpoint = 1024,
  double tabletWidth = 520,
  double desktopWidth = 600,
  EdgeInsetsGeometry mobileMargin = const EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  ),
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
  assert(
    mobileBreakpoint > 0 && tabletBreakpoint > mobileBreakpoint,
    'Breakpoints must be positive and in order',
  );
  assert(tabletWidth > 0 && desktopWidth > 0, 'Width values must be positive');

  final snackBarBehavior =
      behavior ?? EasyMessageConfig.defaultSnackBarBehavior;

  final dedupKey = [
    message,
    messageType,
    backgroundColor,
    duration?.inMilliseconds,
    borderRadius,
    maxLines,
    overflow,
    softWrap,
    textAlign,
    responsive,
    mobileBreakpoint,
    tabletBreakpoint,
    tabletWidth,
    desktopWidth,
    mobileMargin.toString(),
  ].join('|');

  if (preventDuplicate && _lastSnackBarKey == dedupKey) {
    return;
  }

  _lastSnackBarKey = dedupKey;

  final messenger = ScaffoldMessenger.of(context);

  if (snackBarBehavior == MessageBehavior.replace) {
    messenger.hideCurrentSnackBar();
    messenger.clearSnackBars();
  }

  messenger
      .showSnackBar(
        buildAppSnackBar(
          context,
          message: message,
          messageType: messageType,
          icon: icon,
          backgroundColor: backgroundColor,
          duration: duration,
          borderRadius: borderRadius,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          textAlign: textAlign,
          responsive: responsive,
          mobileBreakpoint: mobileBreakpoint,
          tabletBreakpoint: tabletBreakpoint,
          tabletWidth: tabletWidth,
          desktopWidth: desktopWidth,
          mobileMargin: mobileMargin,
        ),
      )
      .closed
      .then((_) {
        if (_lastSnackBarKey == dedupKey) {
          _lastSnackBarKey = null;
        }
      });
}
