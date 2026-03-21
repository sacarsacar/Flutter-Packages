import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';

void main() {
  // Configure global message settings
  EasyMessageConfig.configure(
    toastDuration: Duration(seconds: 2),
    borderRadius: 12,
    toastPosition: MessagePosition.bottomCenter,
    enablePulse: true,
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
                      context,
                      'Please be cautious',
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
    showAppToast(context, message, messageType: type);
  }

  void _showSnackBar(MessageType type, String message) {
    showAppSnackBar(context, message, messageType: type);
  }

  void _showToastAtPosition(MessagePosition position, String label) {
    showAppToast(
      context,
      label,
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
            context,
            'Queued message $i',
            messageType: MessageType.info,
            behavior: MessageBehavior.queue,
          );
        }
      });
    }
  }

  void _showReplacedMessages() {
    for (int i = 1; i <= 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          showAppToast(
            context,
            'Message $i (previous replaced)',
            messageType: MessageType.warning,
            behavior: MessageBehavior.replace,
          );
        }
      });
    }
  }

  void _showPurpleToast() {
    showAppToast(
      context,
      'Custom purple toast',
      backgroundColor: Colors.purple,
    );
  }

  void _showTealToast() {
    showAppToast(
      context,
      'Custom teal toast',
      backgroundColor: Colors.teal,
      borderRadius: 20,
    );
  }

  void _showToastWithIcon() {
    showAppToast(
      context,
      'Message with custom icon',
      icon: const Icon(Icons.favorite, color: Colors.white),
      backgroundColor: Colors.pink,
    );
  }

  void _showMultiLineToast() {
    showAppToast(
      context,
      'This is a longer message that wraps to multiple lines for demonstration purposes',
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
      context,
      'Fast animation (200ms)',
      messageType: MessageType.success,
    );
    EasyMessageConfig.reset();
  }

  void _showNormalAnimation() {
    showAppToast(
      context,
      'Normal animation (400ms)',
      messageType: MessageType.info,
    );
  }

  void _showSlowAnimation() {
    EasyMessageConfig.configure(
      toastEntryAnimationDuration: AnimationPresets.slow.entry,
      toastExitAnimationDuration: AnimationPresets.slow.exit,
    );
    showAppToast(
      context,
      'Slow animation (600ms)',
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
      context,
      'Instant animation',
      messageType: MessageType.warning,
    );
    EasyMessageConfig.reset();
  }

  void _showOffsetToast() {
    showAppToast(
      context,
      'Offset toast',
      backgroundColor: Colors.deepOrange,
      position: MessagePosition.bottomCenter,
      offset: const Offset(0, -50),
    );
  }

  void _showLongDurationToast() {
    showAppToast(
      context,
      'This message stays for 5 seconds',
      messageType: MessageType.success,
      duration: const Duration(seconds: 5),
    );
  }
}
