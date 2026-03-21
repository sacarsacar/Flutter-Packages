import 'package:flutter/material.dart';
import 'package:flutter_easy_messages/flutter_easy_messages.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Easy Messages Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MessageDemoPage(),
    );
  }
}

class MessageDemoPage extends StatelessWidget {
  const MessageDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Easy Messages Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                showAppSnackBar(
                  context,
                  'Success snackbar shown',
                  messageType: MessageType.success,
                );
              },
              child: const Text('Show Success SnackBar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showAppSnackBar(
                  context,
                  'Error snackbar shown',
                  messageType: MessageType.error,
                );
              },
              child: const Text('Show Error SnackBar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showAppToast(
                  context,
                  'Info toast shown',
                  messageType: MessageType.info,
                );
              },
              child: const Text('Show Info Toast'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showAppToast(
                  context,
                  'Warning toast shown',
                  messageType: MessageType.warning,
                );
              },
              child: const Text('Show Warning Toast'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                showAppToast(
                  context,
                  'Custom toast shown',
                  icon: const Icon(Icons.favorite, color: Colors.white),
                  backgroundColor: Colors.purple,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('Show Custom Toast'),
            ),
          ],
        ),
      ),
    );
  }
}
