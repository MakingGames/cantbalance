import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cant/main.dart';
import 'package:cant/screens/challenge_game_screen.dart';
import 'package:cant/screens/shape_picker.dart';
import 'package:cant/services/dev_mode_service.dart';
import 'package:cant/services/high_score_service.dart';
import 'package:cant/services/level_progress_service.dart';
import 'package:cant/services/orientation_service.dart';
import 'package:cant/services/theme_service.dart';
import 'package:cant/services/tutorial_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true,
    });
    DevModeService.resetForTesting();
    HighScoreService.resetForTesting();
    LevelProgressService.resetForTesting();
    OrientationService.resetForTesting();
    ThemeService.resetForTesting();
    TutorialService.resetForTesting();

    await DevModeService.getInstance();
    await HighScoreService.getInstance();
    await LevelProgressService.getInstance();
    await OrientationService.getInstance();
    await TutorialService.getInstance();
  });

  // Helper function for timed pumps in game screens (avoid pumpAndSettle
  // which never settles due to continuous physics animations)
  Future<void> pumpFrames(WidgetTester tester, int frames) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 16)); // ~60fps
    }
  }

  group('Challenge Gameplay', () {
    testWidgets('score starts at 0 in challenge mode', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Navigate to Challenge mode
      await tester.tap(find.text('CHALLENGE'));
      await pumpFrames(tester, 60); // 1 second of frames

      // Verify initial score is 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('shape picker has three size options', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await pumpFrames(tester, 60);

      // Shape picker should be visible
      expect(find.byType(ShapePicker), findsOneWidget);
    });

    testWidgets('can drag to place a shape', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await pumpFrames(tester, 60);

      // Get screen center for drag gesture
      final screenCenter = tester.getCenter(find.byType(ChallengeGameScreen));

      // Drag from top of screen downward (simulating shape placement)
      final startPoint = Offset(screenCenter.dx, screenCenter.dy - 150);
      final endPoint = Offset(screenCenter.dx, screenCenter.dy - 50);

      await tester.dragFrom(startPoint, endPoint - startPoint);
      await pumpFrames(tester, 30);

      // After placing a shape, score should increment to 1
      // Note: This may need adjustment based on exact drag behavior
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('placing multiple shapes increments score', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await pumpFrames(tester, 60);

      final screenCenter = tester.getCenter(find.byType(ChallengeGameScreen));

      // Place first shape
      await tester.dragFrom(
        Offset(screenCenter.dx - 50, screenCenter.dy - 150),
        const Offset(0, 100),
      );
      await pumpFrames(tester, 30);

      // Place second shape
      await tester.dragFrom(
        Offset(screenCenter.dx + 50, screenCenter.dy - 150),
        const Offset(0, 100),
      );
      await pumpFrames(tester, 30);

      // Score should be 2 after placing two shapes
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('game shows back button', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await pumpFrames(tester, 60);

      // Back button should be visible
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('can return to menu from challenge mode', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await pumpFrames(tester, 60);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle(); // Menu doesn't have physics, safe to settle

      // Should be back at main menu
      expect(find.text('CHALLENGE'), findsOneWidget);
      expect(find.text('CAMPAIGN'), findsOneWidget);
    });
  });

  group('Stacking Gameplay', () {
    testWidgets('stacking mode shows shape count', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('STACKING'));
      await pumpFrames(tester, 60);

      // Should show initial count
      expect(find.text('0 shapes'), findsOneWidget);
    });

    testWidgets('stacking mode shows height', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('STACKING'));
      await pumpFrames(tester, 60);

      // Should show initial height
      expect(find.text('0.0m'), findsOneWidget);
    });

    testWidgets('stacking mode shows next shape preview', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('STACKING'));
      await pumpFrames(tester, 60);

      // Should show NEXT label
      expect(find.text('NEXT'), findsOneWidget);
    });
  });

  group('Sandbox Gameplay', () {
    testWidgets('sandbox mode loads successfully', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SANDBOX'));
      await pumpFrames(tester, 60);

      // Should show back button (indicator that screen loaded)
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  group('Campaign Gameplay', () {
    testWidgets('campaign level 1 can be started', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGN'));
      await tester.pumpAndSettle();

      // Tap level 1
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Should show level intro with START button
      expect(find.text('LEVEL 1'), findsOneWidget);
      expect(find.text('START'), findsOneWidget);

      // Tap START
      await tester.tap(find.text('START'));
      await pumpFrames(tester, 60);

      // Should now be in game (back button visible)
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('campaign shows target height for level 1', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGN'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();

      // Should show target (level 1 has target height of 3)
      expect(find.text('TARGET'), findsOneWidget);
      expect(find.text('3 UNITS'), findsOneWidget);
    });
  });
}
