import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tesoro_regional/app/app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: TesoroRegionalApp(),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('Tesoro Regional'), findsOneWidget);
  });
}
