import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';

void main() {
  // Create navigator key for context-free toasts
  final navigatorKey = GlobalKey<NavigatorState>();

  // Set the navigator key BEFORE configuring
  EasyMessageConfig.setNavigatorKey(navigatorKey);

  // Configure global message settings
  EasyMessageConfig.configure(
    toastDuration: Duration(seconds: 2),
    borderRadius: 12,
    toastPosition: MessagePosition.bottomCenter,
    enablePulse: true,
  );

  runApp(ExampleApp(navigatorKey: navigatorKey));
}

class ExampleApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const ExampleApp({required this.navigatorKey, super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Easy Messages Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MessageDemoPage(),
    );
  }
}

class MessageDemoPage extends StatefulWidget {
  const MessageDemoPage({super.key});

  @override
  State<MessageDemoPage> createState() => _MessageDemoPageState();
}

class _MessageDemoPageState extends State<MessageDemoPage> {
  int messageQueueCount = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isDesktop = screenWidth > 1024;

    final horizontalPadding = isDesktop ? 32.0 : (isTablet ? 24.0 : 16.0);
    final verticalSpacing = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final sectionHeight = isDesktop ? 16.0 : (isTablet ? 14.0 : 12.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Easy Messages Demo'),
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: isTablet ? 24 : 16,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 900 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Message Types', sectionHeight),
                _buildResponsiveButtonRow([
                  (
                    'Success',
                    () => _showMessageType(
                      MessageType.success,
                      'Operation completed successfully',
                    ),
                  ),
                  (
                    'Error',
                    () => _showMessageType(
                      MessageType.error,
                      'An error occurred',
                    ),
                  ),
                ], isTablet),
                _buildResponsiveButtonRow([
                  (
                    'Info',
                    () => _showMessageType(
                      MessageType.info,
                      'Here is some information',
                    ),
                  ),
                  (
                    'Warning',
                    () => showAppToast(
                      'Please be cautious',
                      context: context,
                      messageType: MessageType.warning,
                      duration: const Duration(seconds: 2),
                    ),
                  ),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Snackbars', sectionHeight),
                _buildResponsiveButtonRow([
                  (
                    'Success SnackBar',
                    () => _showSnackBar(
                      MessageType.success,
                      'Success message as snackbar',
                    ),
                  ),
                  (
                    'Error SnackBar',
                    () => _showSnackBar(
                      MessageType.error,
                      'Error message as snackbar',
                    ),
                  ),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Toast Positions', sectionHeight),
                _buildResponsivePositionGrid(screenWidth),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Behavior Modes', sectionHeight),
                _buildResponsiveButtonRow([
                  ('Queue Messages', _showQueuedMessages),
                  ('Replace Messages', _showReplacedMessages),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Custom Styling', sectionHeight),
                _buildResponsiveButtonRow([
                  ('Purple Toast', _showPurpleToast),
                  ('Teal Toast', _showTealToast),
                ], isTablet),
                _buildResponsiveButtonRow([
                  ('With Icon', _showToastWithIcon),
                  ('Multi-line', _showMultiLineToast),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Animation Presets', sectionHeight),
                _buildResponsiveButtonRow([
                  ('Fast', _showFastAnimation),
                  ('Normal', _showNormalAnimation),
                ], isTablet),
                _buildResponsiveButtonRow([
                  ('Slow', _showSlowAnimation),
                  ('Instant', _showInstantAnimation),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Offset & Duration', sectionHeight),
                _buildResponsiveButtonRow([
                  ('Offset Toast', _showOffsetToast),
                  ('Long Duration', _showLongDurationToast),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('API Error Handling', sectionHeight),
                _buildResponsiveButtonRow([
                  ('With Retry', _showErrorWithRetry),
                  ('With Details', _showErrorWithDetails),
                ], isTablet),
                _buildResponsiveButtonRow([
                  ('Persistent Toast', _showPersistentToast),
                  ('Dismissible', _showDismissibleToast),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Advanced Features', sectionHeight),
                _buildResponsiveButtonRow([
                  ('No Context Toast', _showContextFreeToast),
                  ('No Context Custom', _showContextFreeCustom),
                ], isTablet),
                SizedBox(height: verticalSpacing),
                _buildSectionHeader('Custom Font & Size', sectionHeight),
                _buildResponsiveButtonRow([
                  ('Custom Font', _showCustomFontToast),
                  ('Large Bold', _showLargeTextToast),
                ], isTablet),
                _buildResponsiveButtonRow([
                  ('Custom SnackBar', _showCustomSnackBar),
                ], isTablet),
                SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double fontSize) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: fontSize * 1.2),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: fontSize + 4,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildResponsiveButtonRow(
    List<(String, VoidCallback)> buttons,
    bool isTablet,
  ) {
    final buttonHeight = isTablet ? 56.0 : 48.0;
    final fontSize = isTablet ? 14.0 : 13.0;

    if (buttons.length == 1) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: SizedBox(
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: buttons[0].$2,
            child: Text(buttons[0].$1, style: TextStyle(fontSize: fontSize)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: buttonHeight,
        child: Row(
          children: [
            for (var (label, onPressed) in buttons) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: onPressed,
                  child: Text(
                    label,
                    style: TextStyle(fontSize: fontSize),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (buttons.indexOf((label, onPressed)) < buttons.length - 1)
                const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResponsivePositionGrid(double screenWidth) {
    final positions = [
      ('Top Left', MessagePosition.topLeft),
      ('Top Center', MessagePosition.topCenter),
      ('Top Right', MessagePosition.topRight),
      ('Center Left', MessagePosition.centerLeft),
      ('Center', MessagePosition.center),
      ('Center Right', MessagePosition.centerRight),
      ('Bottom Left', MessagePosition.bottomLeft),
      ('Bottom Center', MessagePosition.bottomCenter),
      ('Bottom Right', MessagePosition.bottomRight),
    ];

    // Responsive column count
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth > 1024) {
      crossAxisCount = 4;
      childAspectRatio = 2.2;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
      childAspectRatio = 2.0;
    } else {
      crossAxisCount = 3;
      childAspectRatio = 1.8;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: screenWidth > 600 ? 12 : 8,
        mainAxisSpacing: screenWidth > 600 ? 12 : 8,
        childAspectRatio: childAspectRatio,
        children: [
          for (var (label, position) in positions)
            ElevatedButton(
              onPressed: () => _showToastAtPosition(position, label),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth > 600 ? 13 : 11,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  void _showMessageType(MessageType type, String message) {
    showAppToast(message, context: context, messageType: type);
  }

  void _showSnackBar(MessageType type, String message) {
    final snackBar = buildAppSnackBar(
      message,
      context: context,
      messageType: type,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showToastAtPosition(MessagePosition position, String label) {
    showAppToast(
      label,
      context: context,
      messageType: MessageType.info,
      position: position,
    );
  }

  void _showQueuedMessages() {
    messageQueueCount = 0;
    for (int i = 1; i <= 3; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          showAppToast(
            'Queued message $i',
            context: context,
            messageType: MessageType.info,
            behavior: MessageBehavior.queue,
          );
        }
      });
    }
  }

  void _showReplacedMessages() {
    messageQueueCount = 0;
    for (int i = 1; i <= 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          showAppToast(
            'Message $i (previous replaced)',
            context: context,
            messageType: MessageType.warning,
            behavior: MessageBehavior.replace,
          );
        }
      });
    }
  }

  void _showPurpleToast() {
    showAppToast(
      'Custom purple toast',
      context: context,
      backgroundColor: Colors.purple,
    );
  }

  void _showTealToast() {
    showAppToast(
      'Custom teal toast',
      context: context,
      backgroundColor: Colors.teal,
      borderRadius: 20,
    );
  }

  void _showToastWithIcon() {
    showAppToast(
      'Message with custom icon',
      context: context,
      icon: const Icon(Icons.favorite, color: Colors.white),
      backgroundColor: Colors.pink,
    );
  }

  void _showMultiLineToast() {
    showAppToast(
      'This is a longer message that wraps to multiple lines for demonstration purposes',
      context: context,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      backgroundColor: Colors.indigo,
    );
  }

  void _showFastAnimation() {
    EasyMessageConfig.configure(
      toastEntryAnimationDuration: AnimationPresets.fast.entry,
      toastExitAnimationDuration: AnimationPresets.fast.exit,
    );
    showAppToast(
      'Fast animation (200ms)',
      context: context,
      messageType: MessageType.success,
    );
    EasyMessageConfig.reset();
  }

  void _showNormalAnimation() {
    showAppToast(
      'Normal animation (400ms)',
      context: context,
      messageType: MessageType.info,
    );
  }

  void _showSlowAnimation() {
    EasyMessageConfig.configure(
      toastEntryAnimationDuration: AnimationPresets.slow.entry,
      toastExitAnimationDuration: AnimationPresets.slow.exit,
    );
    showAppToast(
      'Slow animation (600ms)',
      context: context,
      messageType: MessageType.info,
    );
    EasyMessageConfig.reset();
  }

  void _showInstantAnimation() {
    EasyMessageConfig.configure(
      toastEntryAnimationDuration: AnimationPresets.instant.entry,
      toastExitAnimationDuration: AnimationPresets.instant.exit,
    );
    showAppToast(
      'Instant animation',
      context: context,
      messageType: MessageType.warning,
    );
    EasyMessageConfig.reset();
  }

  void _showOffsetToast() {
    showAppToast(
      'Offset toast',
      context: context,
      backgroundColor: Colors.deepOrange,
      position: MessagePosition.bottomCenter,
      offset: const Offset(0, -50),
    );
  }

  void _showLongDurationToast() {
    showAppToast(
      'This message stays for 5 seconds',
      context: context,
      messageType: MessageType.success,
      duration: const Duration(seconds: 5),
    );
  }

  void _showCustomFontToast() {
    showAppToast(
      'Custom Font & Size',
      context: context,
      messageType: MessageType.info,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
    );
  }

  void _showLargeTextToast() {
    showAppToast(
      'Large bold text',
      messageType: MessageType.success,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  void _showCustomSnackBar() {
    final snackBar = buildAppSnackBar(
      'Snackbar with custom font',
      context: context,
      messageType: MessageType.info,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// API Error with Retry Button
  /// Demonstrates action buttons for error recovery
  void _showErrorWithRetry() {
    showAppToast(
      'Failed to upload document.pdf',
      messageType: MessageType.error,
      duration: Duration(seconds: 10),
      actions: [
        ToastAction(
          label: 'Retry',
          color: Colors.green,
          textColor: Colors.white,
          onPressed: () {
            showAppToast(
              'Retrying upload...',
              messageType: MessageType.info,
              isPersistent: true,
              dismissible: true,
              position: MessagePosition.bottomCenter,
            );
          },
        ),
        ToastAction(
          label: 'Cancel',
          color: Colors.orangeAccent,
          textColor: Colors.white,
          onPressed: () {
            showAppToast('Upload cancelled', messageType: MessageType.warning);
          },
        ),
      ],
    );
  }

  /// Error with Expanded Details
  /// Show detailed error information that user can expand
  void _showErrorWithDetails() {
    final now = DateTime.now();
    showAppToast(
      '❌ API Request Failed',
      messageType: MessageType.error,
      duration: Duration(seconds: 8),
      errorDetails:
          'Status Code: 500\nEndpoint: /api/v1/upload\nError: Internal Server Error\nTime: ${now.toIso8601String()}\nRequest ID: REQ-${now.millisecondsSinceEpoch}',
    );
  }

  /// Long-running Operation Toast
  /// Persistent message for async operations like uploads/downloads
  void _showPersistentToast() {
    showAppToast(
      '⏳ Processing PDF file...',
      messageType: MessageType.info,
      isPersistent: true,
      dismissible: true,
      duration: Duration(seconds: 999),
      requestId: 'processing_pdf_001',
      onShown: () {
        // Simulate async operation
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            ToastManager.clearByRequestId('processing_pdf_001');
            showAppToast(
              '✅ PDF processing complete!',
              messageType: MessageType.success,
            );
          }
        });
      },
      onDismissed: () {
        // Cleanup operation if needed
      },
    );
  }

  /// User-Dismissible Toast
  /// Let user close notification anytime
  void _showDismissibleToast() {
    showAppToast(
      '👆 Tap anywhere on this toast to close it',
      messageType: MessageType.warning,
      dismissible: true,
      duration: Duration(seconds: 5),
    );
  }

  /// Context-Free Toast with Request Tracking
  /// Works anywhere without BuildContext
  void _showContextFreeToast() {
    showAppToast(
      '🎉 No BuildContext required!',
      messageType: MessageType.success,
      duration: const Duration(seconds: 3),
      requestId: 'context_free_demo_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// Advanced Context-Free with Custom Styling
  /// Demonstrates all customization without context
  void _showContextFreeCustom() {
    showAppToast(
      '🚀 Advanced Styling - No Context!',
      messageType: MessageType.info,
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto',
      duration: const Duration(seconds: 3),
      borderRadius: 16,
      position: MessagePosition.bottomCenter,
    );
  }
}
