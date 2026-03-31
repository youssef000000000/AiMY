import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aimy/main.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const AiMYApp());
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
