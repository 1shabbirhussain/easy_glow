import 'package:easy_glow/easy_glow.dart';
import 'package:easy_glow_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('playground renders tabs, glows and the code dialog', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const EasyGlowPlaygroundApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Contour'), findsOneWidget);
    expect(find.byType(EasyGlow), findsWidgets);

    // Switch to the border tab (glows animate forever, so no pumpAndSettle).
    await tester.tap(find.text('Border'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Ask AI'), findsWidgets);

    // The Code button shows a copy-paste snippet for the current tab.
    await tester.tap(find.text('Code'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Copy-paste snippet'), findsOneWidget);
    expect(find.textContaining('.borderGlow('), findsOneWidget);
  });
}
