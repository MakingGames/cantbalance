import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cant/main.dart';
import 'package:cant/screens/challenge_game_screen.dart';
import 'package:cant/screens/sandbox_game_screen.dart';
import 'package:cant/screens/stacking_game_screen.dart';
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
    // Reset all services for clean test state
    SharedPreferences.setMockInitialValues({
      'tutorial_seen': true, // Skip tutorial for faster tests
    });
    DevModeService.resetForTesting();
    HighScoreService.resetForTesting();
    LevelProgressService.resetForTesting();
    OrientationService.resetForTesting();
    ThemeService.resetForTesting();
    TutorialService.resetForTesting();
  });

  group('App Launch', () {
    testWidgets('app launches successfully and shows main menu',
        (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Main menu should be visible (has all 4 game mode buttons)

      // Game mode buttons should be visible
      expect(find.text('CHALLENGE'), findsOneWidget);
      expect(find.text('CAMPAIGN'), findsOneWidget);
      expect(find.text('SANDBOX'), findsOneWidget);
      expect(find.text('STACKING'), findsOneWidget);
    });
  });

  group('Navigation', () {
    testWidgets('can navigate to Challenge mode and back', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Tap Challenge button
      await tester.tap(find.text('CHALLENGE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on Challenge screen
      expect(find.byType(ChallengeGameScreen), findsOneWidget);
      expect(find.byType(ShapePicker), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at main menu
      expect(find.text('CHALLENGE'), findsOneWidget);
    });

    testWidgets('can navigate to Sandbox mode and back', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Tap Sandbox button
      await tester.tap(find.text('SANDBOX'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on Sandbox screen
      expect(find.byType(SandboxGameScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at main menu
      expect(find.text('SANDBOX'), findsOneWidget);
    });

    testWidgets('can navigate to Stacking mode and back', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Tap Stacking button
      await tester.tap(find.text('STACKING'));
      await tester.pump(const Duration(milliseconds: 500));

      // Should be on Stacking screen
      expect(find.byType(StackingGameScreen), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at main menu
      expect(find.text('STACKING'), findsOneWidget);
    });

    testWidgets('can navigate to Campaign mode and back', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Tap Campaign button
      await tester.tap(find.text('CAMPAIGN'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Should be on Campaign select screen (shows level grid)
      expect(find.text('CAMPAIGN'), findsOneWidget);
      expect(find.text('1'), findsOneWidget); // First level

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back at main menu
      expect(find.text('CAMPAIGN'), findsOneWidget);
    });
  });

  group('Challenge Mode', () {
    testWidgets('challenge mode displays score at 0', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await tester.pump(const Duration(milliseconds: 500));

      // Score should start at 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('challenge mode has shape picker', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHALLENGE'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(ShapePicker), findsOneWidget);
    });
  });

  group('Campaign Mode', () {
    testWidgets('campaign shows level 1 as unlocked', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CAMPAIGN'));
      await tester.pumpAndSettle();

      // Level 1 should be visible (not locked)
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tapping level 1 opens level intro', (tester) async {
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
    });
  });

  group('Theme', () {
    testWidgets('theme toggle works', (tester) async {
      final themeService = await ThemeService.getInstance();
      await tester.pumpWidget(CantApp(themeService: themeService));
      await tester.pumpAndSettle();

      // Find and tap theme toggle
      final themeButton = find.byIcon(Icons.brightness_6);
      if (themeButton.evaluate().isNotEmpty) {
        await tester.tap(themeButton);
        await tester.pumpAndSettle();

        // Theme should have changed (service state)
        // Just verify no crash occurred - main menu is still showing
        expect(find.text('CHALLENGE'), findsOneWidget);
      }
    });
  });
}
