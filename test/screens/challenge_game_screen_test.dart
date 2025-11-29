import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/screens/challenge_game_screen.dart';
import 'package:cant/services/high_score_service.dart';
import 'package:cant/services/tutorial_service.dart';
import 'package:cant/screens/game_over_overlay.dart';
import 'package:cant/screens/tutorial_overlay.dart';
import 'package:cant/screens/shape_picker.dart';
import 'package:cant/screens/tilt_indicator.dart';

void main() {
  group('ChallengeGameScreen', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      HighScoreService.resetForTesting();
      TutorialService.resetForTesting();
    });

    testWidgets('renders game screen with HUD elements', (tester) async {
      // Mark tutorial as seen to avoid overlay blocking
      SharedPreferences.setMockInitialValues({
        'tutorial_seen': true,
      });
      TutorialService.resetForTesting();

      await tester.pumpWidget(
        const MaterialApp(home: ChallengeGameScreen()),
      );

      // Allow async initialization
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Should show shape picker
      expect(find.byType(ShapePicker), findsOneWidget);
    });

    testWidgets('shows tutorial overlay for new users', (tester) async {
      // Don't set tutorial_seen - should show tutorial
      SharedPreferences.setMockInitialValues({});
      TutorialService.resetForTesting();

      await tester.pumpWidget(
        const MaterialApp(home: ChallengeGameScreen()),
      );

      // Allow async initialization (avoid pumpAndSettle - game has continuous animations)
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should show tutorial overlay
      expect(find.byType(TutorialOverlay), findsOneWidget);
    });

    testWidgets('hides tutorial overlay for returning users', (tester) async {
      SharedPreferences.setMockInitialValues({
        'tutorial_seen': true,
      });
      TutorialService.resetForTesting();

      await tester.pumpWidget(
        const MaterialApp(home: ChallengeGameScreen()),
      );

      // Allow async initialization
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should NOT show tutorial overlay
      expect(find.byType(TutorialOverlay), findsNothing);
    });

    testWidgets('displays score starting at 0', (tester) async {
      SharedPreferences.setMockInitialValues({
        'tutorial_seen': true,
      });
      TutorialService.resetForTesting();

      await tester.pumpWidget(
        const MaterialApp(home: ChallengeGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Score should start at 0
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('back button is tappable', (tester) async {
      SharedPreferences.setMockInitialValues({
        'tutorial_seen': true,
      });
      TutorialService.resetForTesting();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChallengeGameScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      // Use pump with duration instead of pumpAndSettle - game has continuous animations
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Now on ChallengeGameScreen
      await tester.pump(const Duration(milliseconds: 100));

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be back at original screen
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('tilt indicator can be toggled', (tester) async {
      SharedPreferences.setMockInitialValues({
        'tutorial_seen': true,
      });
      TutorialService.resetForTesting();

      await tester.pumpWidget(
        const MaterialApp(home: ChallengeGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show tilt indicator initially
      expect(find.byType(TiltIndicator), findsOneWidget);

      // Tap to toggle off (find by GestureDetector containing TiltIndicator)
      final tiltIndicator = find.byType(TiltIndicator);
      await tester.tap(tiltIndicator);
      await tester.pump();

      // Should now show the placeholder icon instead
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      // Tap again to toggle back on
      await tester.tap(find.byIcon(Icons.radio_button_unchecked));
      await tester.pump();

      // Should show tilt indicator again
      expect(find.byType(TiltIndicator), findsOneWidget);
    });
  });

  group('GameOverOverlay', () {
    testWidgets('displays score and high score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(
              finalAngle: 45.0,
              score: 25,
              highScore: 50,
              isNewHighScore: false,
              onRestart: () {},
              onMenu: () {},
            ),
          ),
        ),
      );

      expect(find.text('25'), findsOneWidget);
      expect(find.text('BEST: 50'), findsOneWidget);
      expect(find.text('COLLAPSED'), findsOneWidget);
    });

    testWidgets('shows new high score celebration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(
              finalAngle: 45.0,
              score: 100,
              highScore: 100,
              isNewHighScore: true,
              onRestart: () {},
              onMenu: () {},
            ),
          ),
        ),
      );

      expect(find.text('NEW BEST'), findsOneWidget);
    });

    testWidgets('restart button triggers callback', (tester) async {
      bool restartCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(
              finalAngle: 45.0,
              score: 10,
              highScore: 50,
              isNewHighScore: false,
              onRestart: () => restartCalled = true,
              onMenu: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.text('TRY AGAIN'));
      await tester.pumpAndSettle();

      expect(restartCalled, isTrue);
    });

    testWidgets('menu button triggers callback', (tester) async {
      bool menuCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(
              finalAngle: 45.0,
              score: 10,
              highScore: 50,
              isNewHighScore: false,
              onRestart: () {},
              onMenu: () => menuCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('MENU'));
      await tester.pumpAndSettle();

      expect(menuCalled, isTrue);
    });

    testWidgets('shows singular text for score of 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(
              finalAngle: 45.0,
              score: 1,
              highScore: 50,
              isNewHighScore: false,
              onRestart: () {},
              onMenu: () {},
            ),
          ),
        ),
      );

      expect(find.text('SHAPE PLACED'), findsOneWidget);
    });

    testWidgets('shows plural text for score > 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameOverOverlay(
              finalAngle: 45.0,
              score: 5,
              highScore: 50,
              isNewHighScore: false,
              onRestart: () {},
              onMenu: () {},
            ),
          ),
        ),
      );

      expect(find.text('SHAPES PLACED'), findsOneWidget);
    });
  });

  group('TutorialOverlay', () {
    testWidgets('displays tutorial content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialOverlay(onDismiss: () {}),
          ),
        ),
      );

      // Should show tutorial instructions
      expect(find.text('DRAG ABOVE THE BEAM'), findsOneWidget);
      expect(find.text('TO DROP SHAPES'), findsOneWidget);
      expect(find.text('KEEP THE BALANCE'), findsOneWidget);
      expect(find.text('TAP TO START'), findsOneWidget);
    });

    testWidgets('tapping anywhere dismisses overlay', (tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialOverlay(onDismiss: () => dismissed = true),
          ),
        ),
      );

      // Tap anywhere on the overlay
      await tester.tap(find.byType(TutorialOverlay));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('shows touch icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TutorialOverlay(onDismiss: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });
  });
}
