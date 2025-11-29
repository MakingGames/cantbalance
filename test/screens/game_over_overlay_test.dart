import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cant/screens/game_over_overlay.dart';

void main() {
  group('GameOverOverlay', () {
    Widget buildWidget({
      double finalAngle = 45.0,
      int score = 5,
      int highScore = 10,
      bool isNewHighScore = false,
      VoidCallback? onRestart,
      VoidCallback? onMenu,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: GameOverOverlay(
            finalAngle: finalAngle,
            score: score,
            highScore: highScore,
            isNewHighScore: isNewHighScore,
            onRestart: onRestart ?? () {},
            onMenu: onMenu ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays COLLAPSED title', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('COLLAPSED'), findsOneWidget);
    });

    testWidgets('displays score', (tester) async {
      await tester.pumpWidget(buildWidget(score: 7));

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('shows singular text for 1 shape', (tester) async {
      await tester.pumpWidget(buildWidget(score: 1));

      expect(find.text('SHAPE PLACED'), findsOneWidget);
      expect(find.text('SHAPES PLACED'), findsNothing);
    });

    testWidgets('shows plural text for multiple shapes', (tester) async {
      await tester.pumpWidget(buildWidget(score: 5));

      expect(find.text('SHAPES PLACED'), findsOneWidget);
      expect(find.text('SHAPE PLACED'), findsNothing);
    });

    testWidgets('shows NEW BEST when isNewHighScore is true', (tester) async {
      await tester.pumpWidget(buildWidget(isNewHighScore: true));

      expect(find.text('NEW BEST'), findsOneWidget);
    });

    testWidgets('shows high score when not new best', (tester) async {
      await tester.pumpWidget(buildWidget(
        isNewHighScore: false,
        highScore: 15,
      ));

      expect(find.text('BEST: 15'), findsOneWidget);
      expect(find.text('NEW BEST'), findsNothing);
    });

    testWidgets('has TRY AGAIN button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('TRY AGAIN'), findsOneWidget);
    });

    testWidgets('has MENU button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('MENU'), findsOneWidget);
    });

    testWidgets('TRY AGAIN button calls onRestart', (tester) async {
      var restartCalled = false;
      await tester.pumpWidget(buildWidget(
        onRestart: () => restartCalled = true,
      ));

      await tester.tap(find.text('TRY AGAIN'));
      await tester.pump();

      expect(restartCalled, isTrue);
    });

    testWidgets('MENU button calls onMenu', (tester) async {
      var menuCalled = false;
      await tester.pumpWidget(buildWidget(
        onMenu: () => menuCalled = true,
      ));

      await tester.tap(find.text('MENU'));
      await tester.pump();

      expect(menuCalled, isTrue);
    });
  });
}
