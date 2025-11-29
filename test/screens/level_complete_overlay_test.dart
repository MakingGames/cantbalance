import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cant/game/campaign_level.dart';
import 'package:cant/screens/level_complete_overlay.dart';

void main() {
  final testLevel = CampaignLevel(
    number: 5,
    name: 'Test Level',
    description: 'A test level',
    targetHeight: 10.0,
  );

  group('LevelCompleteOverlay', () {
    Widget buildWidget({
      CampaignLevel? level,
      int score = 5,
      bool hasNextLevel = true,
      VoidCallback? onNextLevel,
      VoidCallback? onRetry,
      VoidCallback? onLevelSelect,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: LevelCompleteOverlay(
            level: level ?? testLevel,
            score: score,
            hasNextLevel: hasNextLevel,
            onNextLevel: onNextLevel ?? () {},
            onRetry: onRetry ?? () {},
            onLevelSelect: onLevelSelect ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays star icon', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('displays LEVEL number', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('LEVEL 5'), findsOneWidget);
    });

    testWidgets('displays COMPLETE text', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('COMPLETE'), findsOneWidget);
    });

    testWidgets('displays level name', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Test Level'), findsOneWidget);
    });

    testWidgets('displays target height', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Reached 10 units'), findsOneWidget);
    });

    testWidgets('shows NEXT button when hasNextLevel is true', (tester) async {
      await tester.pumpWidget(buildWidget(hasNextLevel: true));

      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('hides NEXT button when hasNextLevel is false', (tester) async {
      await tester.pumpWidget(buildWidget(hasNextLevel: false));

      expect(find.text('NEXT'), findsNothing);
    });

    testWidgets('has LEVELS button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('LEVELS'), findsOneWidget);
    });

    testWidgets('has RETRY button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('RETRY'), findsOneWidget);
    });

    testWidgets('LEVELS button calls onLevelSelect', (tester) async {
      var levelSelectCalled = false;
      await tester.pumpWidget(buildWidget(
        onLevelSelect: () => levelSelectCalled = true,
      ));

      await tester.tap(find.text('LEVELS'));
      await tester.pump();

      expect(levelSelectCalled, isTrue);
    });

    testWidgets('RETRY button calls onRetry', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(buildWidget(
        onRetry: () => retryCalled = true,
      ));

      await tester.tap(find.text('RETRY'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('NEXT button calls onNextLevel', (tester) async {
      var nextLevelCalled = false;
      await tester.pumpWidget(buildWidget(
        hasNextLevel: true,
        onNextLevel: () => nextLevelCalled = true,
      ));

      await tester.tap(find.text('NEXT'));
      await tester.pump();

      expect(nextLevelCalled, isTrue);
    });
  });

  group('LevelFailedOverlay', () {
    Widget buildWidget({
      CampaignLevel? level,
      int score = 3,
      VoidCallback? onRetry,
      VoidCallback? onLevelSelect,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: LevelFailedOverlay(
            level: level ?? testLevel,
            score: score,
            onRetry: onRetry ?? () {},
            onLevelSelect: onLevelSelect ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays X icon', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('displays LEVEL number', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('LEVEL 5'), findsOneWidget);
    });

    testWidgets('displays FAILED text', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('FAILED'), findsOneWidget);
    });

    testWidgets('displays target height', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('Target: 10 units'), findsOneWidget);
    });

    testWidgets('has LEVELS button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('LEVELS'), findsOneWidget);
    });

    testWidgets('has RETRY button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('RETRY'), findsOneWidget);
    });

    testWidgets('LEVELS button calls onLevelSelect', (tester) async {
      var levelSelectCalled = false;
      await tester.pumpWidget(buildWidget(
        onLevelSelect: () => levelSelectCalled = true,
      ));

      await tester.tap(find.text('LEVELS'));
      await tester.pump();

      expect(levelSelectCalled, isTrue);
    });

    testWidgets('RETRY button calls onRetry', (tester) async {
      var retryCalled = false;
      await tester.pumpWidget(buildWidget(
        onRetry: () => retryCalled = true,
      ));

      await tester.tap(find.text('RETRY'));
      await tester.pump();

      expect(retryCalled, isTrue);
    });
  });
}
