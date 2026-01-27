import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic Flutter test', (WidgetTester tester) async {
    // Create a simple widget to test basic Flutter functionality
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Test'),
        ),
      ),
    ));

    // Verify the widget renders
    expect(find.text('Test'), findsOneWidget);
  });
}
