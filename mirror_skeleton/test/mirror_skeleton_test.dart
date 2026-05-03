import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mirror_skeleton/mirror_skeleton.dart';

void main() {
  testWidgets('MirrorSkeleton renders without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MirrorSkeleton(isLoading: false, child: Text('Hello')),
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('MirrorSkeleton shows loading state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MirrorSkeleton(isLoading: true, child: Text('Hello')),
        ),
      ),
    );

    // Pump a few frames to let animation start
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(MirrorSkeleton), findsOneWidget);
  });
}
