import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import '../data/mock_repository.dart';
import '../models/message.dart';
import '../widgets/message_tile.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  static const _placeholderCount = 7;
  bool _loading = true;
  List<Message> _messages = List.generate(
    _placeholderCount,
    (_) => Message.placeholder(),
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _messages = List.generate(_placeholderCount, (_) => Message.placeholder());
    });
    final messages = await MockRepository.fetchMessages();
    if (!mounted) return;
    setState(() {
      _messages = messages;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: MirrorSkeleton(
        isLoading: _loading,
        child: ListView.separated(
          itemCount: _messages.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 76),
          itemBuilder: (_, i) => MessageTile(message: _messages[i]),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
