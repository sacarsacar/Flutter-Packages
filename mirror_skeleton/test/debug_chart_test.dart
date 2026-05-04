import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mirror_skeleton/mirror_skeleton.dart';
import 'package:mirror_skeleton/render_mirror_skeleton.dart';

class _NoopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {}
  @override
  bool shouldRepaint(_) => false;
}

void main() {
  testWidgets('analytics-style Card+CustomPaint produces bones', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MirrorSkeleton(
            isLoading: true,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Revenue · last 14 days'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 140,
                          child: CustomPaint(
                            size: const Size(double.infinity, 140),
                            painter: _NoopPainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CustomPaint(painter: _NoopPainter()),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: Text('Legend text here')),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final element = tester.element(find.byType(MirrorSkeleton));
    final ro = element.findRenderObject()! as RenderMirrorSkeleton;

    // ignore: avoid_print
    print('--- BONES (${ro.bones.length}) ---');
    for (final b in ro.bones) {
      // ignore: avoid_print
      print('  type=${b.type}  '
          'size=${b.size}  '
          'offset=${b.offset}  '
          'opacity=${b.opacityScale}  '
          'radius=${b.cornerRadius}  '
          'stroke=${b.strokeWidth}');
    }

    void walk(RenderObject r, [int depth = 0]) {
      final size = r is RenderBox ? r.size : null;
      // ignore: avoid_print
      print('${'  ' * depth}${r.runtimeType}${size != null ? '  $size' : ''}');
      r.visitChildren((c) => walk(c, depth + 1));
    }
    // ignore: avoid_print
    print('--- RENDER TREE ---');
    walk(element.findRenderObject()!);
  });
}
