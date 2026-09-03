import 'package:flutter_test/flutter_test.dart';
import 'package:reckon/main.dart';

void main() {
  testWidgets('ReckonApp basic smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ReckonApp());

    // Verify bottom navigation items exist
    expect(find.text('Navigate'), findsOneWidget);
    expect(find.text('Telemetry'), findsOneWidget);
    expect(find.text('Benchmark'), findsOneWidget);
  });
}
