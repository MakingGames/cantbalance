import 'package:flutter_test/flutter_test.dart';

import 'package:cant/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CantApp());
    await tester.pump();

    // Verify the app launches without crashing
    expect(find.byType(CantApp), findsOneWidget);
  });
}
