import 'package:flutter/material.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';

/// Stress test for buttons, chips, form controls, progress indicators,
/// text fields, dividers, and custom paint. All of these are now
/// auto-detected by MirrorSkeleton.
class ControlsPage extends StatefulWidget {
  const ControlsPage({super.key});

  @override
  State<ControlsPage> createState() => _ControlsPageState();
}

class _ControlsPageState extends State<ControlsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controls Gallery')),
      body: MirrorSkeleton(isLoading: _loading, child: const _ControlsBody()),
      floatingActionButton: FloatingActionButton(
        onPressed: _load,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class _ControlsBody extends StatefulWidget {
  const _ControlsBody();

  @override
  State<_ControlsBody> createState() => _ControlsBodyState();
}

class _ControlsBodyState extends State<_ControlsBody> {
  bool _switchOn = true;
  bool _checkboxOn = true;
  int _radio = 0;
  double _slider = 0.4;
  final _textController = TextEditingController(text: 'Sample text');

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buttons', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              TextButton(onPressed: () {}, child: const Text('Text')),
              IconButton(onPressed: () {}, icon: const Icon(Icons.favorite)),
            ],
          ),
          const Divider(height: 32),
          Text('Chips', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: const Text('Flutter'),
                avatar: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: const Icon(Icons.star, size: 14, color: Colors.white),
                ),
              ),
              const Chip(label: Text('Dart')),
              ActionChip(label: const Text('Action'), onPressed: () {}),
            ],
          ),
          const Divider(height: 32),
          Text('Form controls', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Switch'),
              const Spacer(),
              Switch(
                value: _switchOn,
                onChanged: (v) => setState(() => _switchOn = v),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Checkbox'),
              const Spacer(),
              Checkbox(
                value: _checkboxOn,
                onChanged: (v) => setState(() => _checkboxOn = v ?? false),
              ),
            ],
          ),
          RadioGroup<int>(
            groupValue: _radio,
            onChanged: (v) => setState(() => _radio = v ?? 0),
            child: const Row(
              children: [
                Text('Radio'),
                Spacer(),
                Radio<int>(value: 0),
                Radio<int>(value: 1),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Slider(value: _slider, onChanged: (v) => setState(() => _slider = v)),
          const SizedBox(height: 12),
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const Divider(height: 32),
          Text('Progress', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          const LinearProgressIndicator(value: 0.6),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const Divider(height: 32),
          Text('Custom paint', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _SparklinePainter(theme.colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color color;
  _SparklinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path();
    final pts = [0.1, 0.4, 0.2, 0.6, 0.3, 0.8, 0.5, 0.9];
    for (var i = 0; i < pts.length; i++) {
      final x = (i / (pts.length - 1)) * size.width;
      final y = size.height - pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color;
}
