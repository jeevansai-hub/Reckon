import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:reckon/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(const ReckonApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('RECKON'), findsOneWidget);
  });
}
