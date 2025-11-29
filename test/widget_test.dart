import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cant/main.dart';
import 'package:cant/services/dev_mode_service.dart';
import 'package:cant/services/high_score_service.dart';
import 'package:cant/services/level_progress_service.dart';
import 'package:cant/services/orientation_service.dart';
import 'package:cant/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset all singletons to ensure clean state
    ThemeService.resetForTesting();
    DevModeService.resetForTesting();
    OrientationService.resetForTesting();
    HighScoreService.resetForTesting();
    LevelProgressService.resetForTesting();

    // Set up mock SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Initialize all services that MainMenuScreen uses
    final themeService = await ThemeService.getInstance();
    await DevModeService.getInstance();
    await OrientationService.getInstance();
    await HighScoreService.getInstance();
    await LevelProgressService.getInstance();

    await tester.pumpWidget(CantApp(themeService: themeService));
    await tester.pumpAndSettle();

    // Verify the app launches without crashing
    expect(find.byType(CantApp), findsOneWidget);
  });
}
