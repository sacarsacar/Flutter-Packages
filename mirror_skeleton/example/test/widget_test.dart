import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('MirrorSkeleton example app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MirrorSkeletonExampleApp());

    // The home page renders the index of demos. Items further down the
    // list (Login, Wallet, etc.) are off-screen by default, so just check
    // the top of the list.
    expect(find.text('MirrorSkeleton'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Feed'), findsOneWidget);
  });
}
