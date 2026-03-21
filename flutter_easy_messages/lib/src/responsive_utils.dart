import 'package:flutter/material.dart';

/// ResponsiveSize contains sizing information for responsive layouts
class ResponsiveSize {
  final double? width;
  final EdgeInsetsGeometry? margin;

  const ResponsiveSize({this.width, this.margin});
}

/// Utility class for responsive design calculations
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Calculates responsive sizing based on screen width
  ///
  /// Parameters:
  /// - [screenWidth] The current screen width
  /// - [mobileBreakpoint] Breakpoint below which mobile layout is used (default: 600)
  /// - [tabletBreakpoint] Breakpoint below which tablet layout is used (default: 1024)
  /// - [tabletWidth] Width to use for tablet screens (default: 520)
  /// - [desktopWidth] Width to use for desktop screens (default: 600)
  /// - [mobileMargin] Margin to use for mobile screens
  ///
  /// Returns a [ResponsiveSize] with appropriate width and margin
  static ResponsiveSize calculateResponsiveSize({
    required double screenWidth,
    double mobileBreakpoint = 600,
    double tabletBreakpoint = 1024,
    double tabletWidth = 520,
    double desktopWidth = 600,
    EdgeInsetsGeometry mobileMargin = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 12,
    ),
  }) {
    if (screenWidth < mobileBreakpoint) {
      return ResponsiveSize(margin: mobileMargin);
    } else if (screenWidth < tabletBreakpoint) {
      return ResponsiveSize(width: tabletWidth);
    } else {
      return ResponsiveSize(width: desktopWidth);
    }
  }

  /// Returns true if the device is in portrait mode
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Returns true if the device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Returns true if screen width is considered mobile
  static bool isMobile(double screenWidth, {double breakpoint = 600}) {
    return screenWidth < breakpoint;
  }

  /// Returns true if screen width is considered tablet
  static bool isTablet(
    double screenWidth, {
    double mobileBreakpoint = 600,
    double tabletBreakpoint = 1024,
  }) {
    return screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
  }

  /// Returns true if screen width is considered desktop
  static bool isDesktop(double screenWidth, {double breakpoint = 1024}) {
    return screenWidth >= breakpoint;
  }

  /// Gets the screen size category
  static ScreenSizeCategory getScreenSizeCategory(
    double screenWidth, {
    double mobileBreakpoint = 600,
    double tabletBreakpoint = 1024,
  }) {
    if (screenWidth < mobileBreakpoint) {
      return ScreenSizeCategory.mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return ScreenSizeCategory.tablet;
    } else {
      return ScreenSizeCategory.desktop;
    }
  }
}

/// Enum for screen size categories
enum ScreenSizeCategory { mobile, tablet, desktop }
