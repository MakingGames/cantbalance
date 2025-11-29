import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cant/main.dart';
import 'package:cant/services/dev_mode_service.dart';
import 'package:cant/services/orientation_service.dart';
import 'package:cant/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Set up mock SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Initialize all required services for MainMenuScreen
    final themeService = await ThemeService.getInstance();
    await DevModeService.getInstance();
    await OrientationService.getInstance();

    await tester.pumpWidget(CantApp(themeService: themeService));
    await tester.pump();

    // Verify the app launches without crashing
    expect(find.byType(CantApp), findsOneWidget);
  });
}
