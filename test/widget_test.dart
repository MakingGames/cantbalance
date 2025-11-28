import 'package:flutter_test/flutter_test.dart';

import 'package:cant/main.dart';
import 'package:cant/services/theme_service.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Initialize theme service for tests
    final themeService = await ThemeService.getInstance();

    await tester.pumpWidget(CantApp(themeService: themeService));
    await tester.pump();

    // Verify the app launches without crashing
    expect(find.byType(CantApp), findsOneWidget);
  });
}
