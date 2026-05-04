import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mirror_skeleton/mirror_skeleton.dart';
import 'package:mirror_skeleton/render_mirror_skeleton.dart';

/// Helper that returns the [RenderMirrorSkeleton] mounted under the
/// [MirrorSkeleton] widget so individual tests can inspect bone state.
RenderMirrorSkeleton _renderOf(WidgetTester tester) {
  final element = tester.element(find.byType(MirrorSkeleton));
  return element.findRenderObject()! as RenderMirrorSkeleton;
}

/// Pump the bone-detection pass by forcing a paint. Bones are computed
/// during paint, so the list is populated as soon as a frame is laid down.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 16));
}

void main() {
  group('rendering basics', () {
    testWidgets('shows real child when not loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(isLoading: false, child: Text('Hello')),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('paints skeleton while loading', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Text('Placeholder text'),
            ),
          ),
        ),
      );
      await _settle(tester);

      expect(_renderOf(tester).bones, isNotEmpty);
    });
  });

  group('widget detection', () {
    testWidgets('Text becomes a text bone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Text('Hello world'),
            ),
          ),
        ),
      );
      await _settle(tester);

      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(greaterThan(0)));
      expect(bones.any((b) => b.type == BoneType.text), isTrue);
    });

    testWidgets('Container with color becomes a bone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Container(
                width: 200,
                height: 80,
                color: Colors.red,
              ),
            ),
          ),
        ),
      );
      await _settle(tester);

      expect(_renderOf(tester).bones, hasLength(1));
    });

    testWidgets('Container with BoxDecoration becomes a bone', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);

      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.roundedRect);
    });

    testWidgets('CircleAvatar becomes a circle bone', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: CircleAvatar(radius: 30),
            ),
          ),
        ),
      );
      await _settle(tester);

      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.circle);
    });

    testWidgets('FilledButton becomes a single pill bone, not just text', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: FilledButton(onPressed: () {}, child: const Text('Go')),
            ),
          ),
        ),
      );
      await _settle(tester);

      final bones = _renderOf(tester).bones;
      // Button is short and is treated as a leaf — no inner text bone.
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.roundedRect);
    });

    testWidgets('Sliver children get correct positions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: ListView(
                children: List.generate(
                  5,
                  (i) => Container(
                    height: 60,
                    margin: const EdgeInsets.all(4),
                    color: Colors.indigo,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);

      final bones = _renderOf(tester).bones;
      // Five children → five bones, each at distinct vertical offsets.
      expect(bones, hasLength(5));
      final ys = bones.map((b) => b.offset.dy).toList()..sort();
      for (var i = 1; i < ys.length; i++) {
        expect(ys[i], greaterThan(ys[i - 1]));
      }
    });
  });

  group('SkeletonIgnore', () {
    testWidgets('preserves child during loading', (tester) async {
      const ignoredKey = Key('ignored');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Column(
                children: [
                  const SkeletonIgnore(
                    child: SizedBox(
                      key: ignoredKey,
                      width: 100,
                      height: 100,
                      child: Text('Brand'),
                    ),
                  ),
                  Container(width: 200, height: 50, color: Colors.red),
                ],
              ),
            ),
          ),
        ),
      );
      await _settle(tester);

      final render = _renderOf(tester);
      // Container under the ignored region still gets a bone.
      expect(render.bones.any((b) => b.size.height == 50), isTrue);
      // And SkeletonIgnore subtree is recorded so it can be painted on top.
      expect(find.byKey(ignoredKey), findsOneWidget);
    });
  });

  group('interaction blocking', () {
    testWidgets('absorbs taps while loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => pressed = true,
                  child: const Text('Tap'),
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);

      // Tap directly on where the button would be.
      await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('passes taps when not loading', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: false,
              child: Center(
                child: ElevatedButton(
                  onPressed: () => pressed = true,
                  child: const Text('Tap'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isTrue);
    });
  });

  group('semantics', () {
    testWidgets('exposes "Loading" label and hides children', (tester) async {
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Text('Sensitive content'),
            ),
          ),
        ),
      );
      await _settle(tester);

      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
      expect(find.bySemanticsLabel('Sensitive content'), findsNothing);

      handle.dispose();
    });
  });

  group('reduced motion', () {
    testWidgets('does not animate shimmer when disableAnimations is on', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(
              body: MirrorSkeleton(
                isLoading: true,
                child: Text('Static skeleton'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // No exception about pending timers means the shimmer ticker isn't
      // running. tester.pumpAndSettle would hang if shimmer were repeating.
      await tester.pumpAndSettle();
      expect(_renderOf(tester).bones, isNotEmpty);
    });
  });

  group('fade transition', () {
    testWidgets('fades skeleton out when loading flips off', (tester) async {
      Widget build(bool loading) => MaterialApp(
        home: Scaffold(
          body: MirrorSkeleton(
            isLoading: loading,
            transitionDuration: const Duration(milliseconds: 200),
            child: Container(width: 200, height: 100, color: Colors.green),
          ),
        ),
      );

      await tester.pumpWidget(build(true));
      await _settle(tester);
      // Skeleton fully opaque while loading.
      expect(_renderOf(tester).fadeValue, 1.0);

      await tester.pumpWidget(build(false));
      // Mid-fade.
      await tester.pump(const Duration(milliseconds: 100));
      final mid = _renderOf(tester).fadeValue;
      expect(mid, greaterThan(0.0));
      expect(mid, lessThan(1.0));

      // Settled at zero.
      await tester.pumpAndSettle();
      expect(_renderOf(tester).fadeValue, 0.0);
    });
  });

  group('progress indicators', () {
    testWidgets('CircularProgressIndicator does not produce a bone', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: SizedBox(
                width: 80,
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(_renderOf(tester).bones, isEmpty);
    });

    testWidgets('LinearProgressIndicator does not produce a bone', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(value: 0.5),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      expect(_renderOf(tester).bones, isEmpty);
    });

    testWidgets(
      'progress nested inside a Container does not block the container bone',
      (tester) async {
        // The container itself should still bone-ify; the spinner inside
        // is invisible during loading.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MirrorSkeleton(
                isLoading: true,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.amber,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
          ),
        );
        await _settle(tester);
        final bones = _renderOf(tester).bones;
        expect(bones, hasLength(1));
        expect(bones.first.size, const Size(100, 100));
      },
    );
  });

  group('icon detection', () {
    testWidgets('Icon becomes a small rounded bone, not a text bone', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Center(child: Icon(Icons.favorite, size: 32)),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.roundedRect);
      // Square within tolerance.
      expect(
        (bones.first.size.width - bones.first.size.height).abs(),
        lessThanOrEqualTo(2),
      );
    });
  });

  group('ambient clip context', () {
    testWidgets('ClipRRect imprints its radius onto a child container bone', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.cornerRadius, 20.0);
    });

    testWidgets('ClipOval turns a child container bone into a circle', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: ClipOval(
                child: Container(
                  width: 80,
                  height: 80,
                  color: Colors.green,
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.circle);
    });
  });

  group('form-control shapes', () {
    testWidgets('Switch produces a track + thumb pair', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Switch(value: true, onChanged: (_) {}),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(2));
      // One pill (track), one circle (thumb).
      expect(
        bones.where((b) => b.type == BoneType.roundedRect).length,
        1,
      );
      expect(bones.where((b) => b.type == BoneType.circle).length, 1);
      // Track is dimmer than the thumb.
      final track = bones.firstWhere((b) => b.type == BoneType.roundedRect);
      final thumb = bones.firstWhere((b) => b.type == BoneType.circle);
      expect(track.opacityScale, lessThan(thumb.opacityScale));
    });

    testWidgets('Slider produces a thin track + thumb pair', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Slider(value: 0.4, onChanged: (_) {}),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(2));
      final track = bones.firstWhere((b) => b.type == BoneType.roundedRect);
      // Track height collapses to ~4 even though the slider's render box
      // is much taller; that's what makes it look like a slider.
      expect(track.size.height, lessThanOrEqualTo(6));
    });

    testWidgets('Radio renders as a stroked ring, not a filled disc', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RadioGroup<int>(
              groupValue: 0,
              onChanged: (_) {},
              child: MirrorSkeleton(
                isLoading: true,
                child: const Radio<int>(value: 0),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.circle);
      expect(bones.first.strokeWidth, isNotNull);
    });

    testWidgets('Checkbox renders as a stroked rounded square', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Checkbox(value: false, onChanged: (_) {}),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(bones.first.type, BoneType.roundedRect);
      expect(bones.first.strokeWidth, isNotNull);
    });
  });

  group('memory hygiene', () {
    testWidgets('bones are cleared after fade-out completes', (tester) async {
      Widget build(bool loading) => MaterialApp(
        home: Scaffold(
          body: MirrorSkeleton(
            isLoading: loading,
            transitionDuration: const Duration(milliseconds: 100),
            child: Container(width: 200, height: 100, color: Colors.green),
          ),
        ),
      );

      await tester.pumpWidget(build(true));
      await _settle(tester);
      expect(_renderOf(tester).bones, isNotEmpty);

      await tester.pumpWidget(build(false));
      await tester.pumpAndSettle();
      // Once fade reaches 0 the render object releases its bone state so it
      // doesn't pin descendant render objects in memory.
      expect(_renderOf(tester).bones, isEmpty);
    });
  });

  group('backdrop bones', () {
    testWidgets(
      'filled container with content emits a dim backdrop AND inner bones',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MirrorSkeleton(
                isLoading: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: const Text('Hello world'),
                ),
              ),
            ),
          ),
        );
        await _settle(tester);
        final bones = _renderOf(tester).bones;
        // Backdrop bone for the container + text bone inside.
        expect(bones.length, greaterThanOrEqualTo(2));
        // The backdrop must use the container's borderRadius (responsive,
        // matches the real card's silhouette).
        final backdrop = bones.firstWhere(
          (b) => b.type == BoneType.roundedRect && b.cornerRadius == 20.0,
        );
        expect(
          backdrop.opacityScale,
          lessThan(1.0),
          reason: 'card silhouette should be dimmer than its content bones',
        );
        // At least one bone (the text) should be at full opacity.
        expect(bones.any((b) => b.opacityScale == 1.0), isTrue);
      },
    );

    testWidgets('Card with content emits a backdrop, not just inner bones', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: SizedBox(
                height: 200,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Card content'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      // The Card produces a backdrop bone in addition to the text bone.
      expect(bones.any((b) => b.opacityScale < 1.0), isTrue);
      expect(bones.any((b) => b.type == BoneType.text), isTrue);
    });

    testWidgets('leaf container (no content) is still a solid bone', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MirrorSkeleton(
              isLoading: true,
              child: Container(
                width: 100,
                height: 80,
                color: Colors.amber,
              ),
            ),
          ),
        ),
      );
      await _settle(tester);
      final bones = _renderOf(tester).bones;
      expect(bones, hasLength(1));
      expect(
        bones.first.opacityScale,
        1.0,
        reason: 'a leaf container has nothing layered on top, so it should '
            'render at full opacity instead of as a dim backdrop',
      );
    });
  });
}
