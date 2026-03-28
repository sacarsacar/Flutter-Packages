import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';

void main() {
  group('MessageType', () {
    test('MessageType enum has all required values', () {
      expect(MessageType.error, isNotNull);
      expect(MessageType.success, isNotNull);
      expect(MessageType.info, isNotNull);
      expect(MessageType.warning, isNotNull);
    });
  });

  group('MessagePosition', () {
    test('MessagePosition enum has all required positions', () {
      expect(MessagePosition.topLeft, isNotNull);
      expect(MessagePosition.topCenter, isNotNull);
      expect(MessagePosition.topRight, isNotNull);
      expect(MessagePosition.centerLeft, isNotNull);
      expect(MessagePosition.center, isNotNull);
      expect(MessagePosition.centerRight, isNotNull);
      expect(MessagePosition.bottomLeft, isNotNull);
      expect(MessagePosition.bottomCenter, isNotNull);
      expect(MessagePosition.bottomRight, isNotNull);
    });
  });

  group('MessageBehavior', () {
    test('MessageBehavior enum has replace and queue', () {
      expect(MessageBehavior.replace, isNotNull);
      expect(MessageBehavior.queue, isNotNull);
    });
  });

  group('EasyMessageConfig', () {
    tearDown(() {
      EasyMessageConfig.reset();
    });

    test('Default configuration values are correct', () {
      expect(EasyMessageConfig.defaultToastDuration, Duration(seconds: 2));
      expect(EasyMessageConfig.defaultSnackBarDuration, Duration(seconds: 3));
      expect(EasyMessageConfig.defaultBorderRadius, 12);
      expect(
        EasyMessageConfig.defaultToastPosition,
        MessagePosition.bottomCenter,
      );
      expect(EasyMessageConfig.defaultToastOffset, Offset.zero);
      expect(EasyMessageConfig.defaultToastBehavior, MessageBehavior.replace);
    });

    test('Animation configuration has proper defaults', () {
      expect(
        EasyMessageConfig.defaultToastEntryAnimationDuration,
        Duration(milliseconds: 400),
      );
      expect(
        EasyMessageConfig.defaultToastExitAnimationDuration,
        Duration(milliseconds: 300),
      );
      expect(
        EasyMessageConfig.defaultToastPulseAnimationDuration,
        Duration(milliseconds: 600),
      );
      expect(
        EasyMessageConfig.defaultToastPulseReverseAnimationDuration,
        Duration(milliseconds: 600),
      );
      expect(EasyMessageConfig.defaultToastPulseScale, 1.05);
      expect(EasyMessageConfig.enableToastPulse, true);
    });

    test('Configuration can be updated', () {
      final customDuration = Duration(seconds: 5);
      const customBorderRadius = 20.0;
      const customPosition = MessagePosition.topCenter;

      EasyMessageConfig.configure(
        toastDuration: customDuration,
        borderRadius: customBorderRadius,
        toastPosition: customPosition,
      );

      expect(EasyMessageConfig.defaultToastDuration, customDuration);
      expect(EasyMessageConfig.defaultBorderRadius, customBorderRadius);
      expect(EasyMessageConfig.defaultToastPosition, customPosition);
    });

    test('Animation configuration can be updated', () {
      final customEntryDuration = Duration(milliseconds: 500);
      final customPulseScale = 1.1;

      EasyMessageConfig.configure(
        toastEntryAnimationDuration: customEntryDuration,
        toastPulseScale: customPulseScale,
        enablePulse: false,
      );

      expect(
        EasyMessageConfig.defaultToastEntryAnimationDuration,
        customEntryDuration,
      );
      expect(EasyMessageConfig.defaultToastPulseScale, customPulseScale);
      expect(EasyMessageConfig.enableToastPulse, false);
    });

    test('Configuration reset restores defaults', () {
      EasyMessageConfig.configure(
        toastDuration: Duration(seconds: 10),
        borderRadius: 30,
        enablePulse: false,
      );

      EasyMessageConfig.reset();

      expect(EasyMessageConfig.defaultToastDuration, Duration(seconds: 2));
      expect(EasyMessageConfig.defaultBorderRadius, 12);
      expect(EasyMessageConfig.enableToastPulse, true);
    });
  });

  group('MessageStyle', () {
    test('resolveMessageStyle returns correct style for error type', () {
      final style = resolveMessageStyle(messageType: MessageType.error);
      expect(style.backgroundColor, Colors.red);
      expect(style.icon, isNotNull);
    });

    test('resolveMessageStyle returns correct style for success type', () {
      final style = resolveMessageStyle(messageType: MessageType.success);
      expect(style.backgroundColor, Colors.green);
      expect(style.icon, isNotNull);
    });

    test('resolveMessageStyle returns correct style for info type', () {
      final style = resolveMessageStyle(messageType: MessageType.info);
      expect(style.backgroundColor, Colors.blue);
      expect(style.icon, isNotNull);
    });

    test('resolveMessageStyle returns correct style for warning type', () {
      final style = resolveMessageStyle(messageType: MessageType.warning);
      expect(style.backgroundColor, Colors.orange);
      expect(style.icon, isNotNull);
    });

    test('resolveMessageStyle uses custom color when provided', () {
      const customColor = Color(0xFFFF00FF);
      final style = resolveMessageStyle(backgroundColor: customColor);
      expect(style.backgroundColor, customColor);
    });

    test('resolveMessageStyle uses custom icon when provided', () {
      const customIcon = Icon(Icons.favorite);
      final style = resolveMessageStyle(icon: customIcon);
      expect(style.icon, customIcon);
    });

    test('resolveMessageStyle prioritizes custom color over message type', () {
      const customColor = Color(0xFFFF00FF);
      final style = resolveMessageStyle(
        messageType: MessageType.error,
        backgroundColor: customColor,
      );
      expect(style.backgroundColor, customColor);
    });
  });

  group('AnimationPresets', () {
    test('Fast preset has correct durations', () {
      expect(AnimationPresets.fast.entry, Duration(milliseconds: 200));
      expect(AnimationPresets.fast.exit, Duration(milliseconds: 150));
      expect(AnimationPresets.fast.pulse, Duration(milliseconds: 300));
    });

    test('Normal preset has correct durations', () {
      expect(AnimationPresets.normal.entry, Duration(milliseconds: 400));
      expect(AnimationPresets.normal.exit, Duration(milliseconds: 300));
      expect(AnimationPresets.normal.pulse, Duration(milliseconds: 600));
    });

    test('Slow preset has correct durations', () {
      expect(AnimationPresets.slow.entry, Duration(milliseconds: 600));
      expect(AnimationPresets.slow.exit, Duration(milliseconds: 450));
      expect(AnimationPresets.slow.pulse, Duration(milliseconds: 900));
    });
  });

  group('ScalePresets', () {
    test('Scale presets have valid values', () {
      expect(ScalePresets.subtle, 1.02);
      expect(ScalePresets.normal, 1.05);
      expect(ScalePresets.medium, 1.08);
      expect(ScalePresets.large, 1.15);
      expect(ScalePresets.extraLarge, 1.25);
    });

    test('Scale values are in ascending order', () {
      expect(ScalePresets.subtle < ScalePresets.normal, true);
      expect(ScalePresets.normal < ScalePresets.medium, true);
      expect(ScalePresets.medium < ScalePresets.large, true);
      expect(ScalePresets.large < ScalePresets.extraLarge, true);
    });
  });

  group('ResponsiveUtils', () {
    test('calculateResponsiveSize returns mobile margin for small screens', () {
      final size = ResponsiveUtils.calculateResponsiveSize(
        screenWidth: 400,
        mobileBreakpoint: 600,
      );
      expect(size.width, isNull);
      expect(size.margin, isNotNull);
    });

    test('calculateResponsiveSize returns tablet width for medium screens', () {
      final size = ResponsiveUtils.calculateResponsiveSize(
        screenWidth: 800,
        mobileBreakpoint: 600,
        tabletBreakpoint: 1024,
        tabletWidth: 520,
      );
      expect(size.width, 520);
      expect(size.margin, isNull);
    });

    test('calculateResponsiveSize returns desktop width for large screens', () {
      final size = ResponsiveUtils.calculateResponsiveSize(
        screenWidth: 1300,
        tabletBreakpoint: 1024,
        desktopWidth: 600,
      );
      expect(size.width, 600);
      expect(size.margin, isNull);
    });

    test('isMobile returns true for small screen widths', () {
      expect(ResponsiveUtils.isMobile(400, breakpoint: 600), true);
      expect(ResponsiveUtils.isMobile(700, breakpoint: 600), false);
    });

    test('isTablet returns true for medium screen widths', () {
      expect(
        ResponsiveUtils.isTablet(
          800,
          mobileBreakpoint: 600,
          tabletBreakpoint: 1024,
        ),
        true,
      );
      expect(
        ResponsiveUtils.isTablet(
          400,
          mobileBreakpoint: 600,
          tabletBreakpoint: 1024,
        ),
        false,
      );
    });

    test('isDesktop returns true for large screen widths', () {
      expect(ResponsiveUtils.isDesktop(1300, breakpoint: 1024), true);
      expect(ResponsiveUtils.isDesktop(900, breakpoint: 1024), false);
    });

    test('getScreenSizeCategory returns correct categories', () {
      expect(
        ResponsiveUtils.getScreenSizeCategory(
          400,
          mobileBreakpoint: 600,
          tabletBreakpoint: 1024,
        ),
        ScreenSizeCategory.mobile,
      );
      expect(
        ResponsiveUtils.getScreenSizeCategory(
          800,
          mobileBreakpoint: 600,
          tabletBreakpoint: 1024,
        ),
        ScreenSizeCategory.tablet,
      );
      expect(
        ResponsiveUtils.getScreenSizeCategory(
          1300,
          mobileBreakpoint: 600,
          tabletBreakpoint: 1024,
        ),
        ScreenSizeCategory.desktop,
      );
    });
  });

  group('ToastRequest', () {
    test('ToastRequest creates instance with all properties', () {
      final context = MockBuildContext();
      const message = 'Test message';

      final request = ToastRequest(
        context: context,
        message: message,
        icon: null,
        backgroundColor: Colors.black,
        duration: Duration(seconds: 2),
        borderRadius: 12,
        position: MessagePosition.bottomCenter,
        offset: Offset.zero,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

      expect(request.message, message);
      expect(request.backgroundColor, Colors.black);
      expect(request.position, MessagePosition.bottomCenter);
    });

    test('ToastRequest dedupKey is unique for different messages', () {
      final context = MockBuildContext();

      final request1 = ToastRequest(
        context: context,
        message: 'Message 1',
        icon: null,
        backgroundColor: Colors.black,
        duration: Duration(seconds: 2),
        borderRadius: 12,
        position: MessagePosition.bottomCenter,
        offset: Offset.zero,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

      final request2 = ToastRequest(
        context: context,
        message: 'Message 2',
        icon: null,
        backgroundColor: Colors.black,
        duration: Duration(seconds: 2),
        borderRadius: 12,
        position: MessagePosition.bottomCenter,
        offset: Offset.zero,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

      expect(request1.dedupKey != request2.dedupKey, true);
    });

    test('ToastRequest dedupKey is same for identical requests', () {
      final context = MockBuildContext();
      const message = 'Test message';

      final request1 = ToastRequest(
        context: context,
        message: message,
        icon: null,
        backgroundColor: Colors.black,
        duration: Duration(seconds: 2),
        borderRadius: 12,
        position: MessagePosition.bottomCenter,
        offset: Offset.zero,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

      final request2 = ToastRequest(
        context: context,
        message: message,
        icon: null,
        backgroundColor: Colors.black,
        duration: Duration(seconds: 2),
        borderRadius: 12,
        position: MessagePosition.bottomCenter,
        offset: Offset.zero,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      );

      expect(request1.dedupKey == request2.dedupKey, true);
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
