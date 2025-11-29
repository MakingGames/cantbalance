import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/game/campaign_level.dart';
import 'package:cant/screens/level_select.dart';
import 'package:cant/screens/level_intro_card.dart';
import 'package:cant/services/level_progress_service.dart';

void main() {
  group('LevelSelectScreen', () {
    late LevelProgressService progressService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      LevelProgressService.resetForTesting();
      progressService = await LevelProgressService.getInstance();
    });

    Widget buildWidget({
      void Function(CampaignLevel)? onLevelSelected,
      VoidCallback? onBack,
    }) {
      return MaterialApp(
        home: LevelSelectScreen(
          progressService: progressService,
          onLevelSelected: onLevelSelected ?? (_) {},
          onBack: onBack ?? () {},
        ),
      );
    }

    testWidgets('displays CAMPAIGN header', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('CAMPAIGN'), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button calls onBack', (tester) async {
      var backCalled = false;
      await tester.pumpWidget(buildWidget(onBack: () => backCalled = true));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('displays star counter', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.star), findsOneWidget);
      // Should show "0/N" where N is number of levels
      expect(find.textContaining('/'), findsOneWidget);
    });

    testWidgets('displays level tiles', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Should show at least level 1
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('first level is unlocked', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Level 1 should be shown as number (not locked icon)
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('locked levels show lock icon', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Should have lock icons for locked levels
      expect(find.byIcon(Icons.lock_outline), findsWidgets);
    });

    testWidgets('tapping unlocked level calls onLevelSelected', (tester) async {
      CampaignLevel? selectedLevel;
      await tester.pumpWidget(buildWidget(
        onLevelSelected: (level) => selectedLevel = level,
      ));

      // Tap level 1
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(selectedLevel?.number, equals(1));
    });

    testWidgets('completed level shows filled star', (tester) async {
      // Complete level 1
      await progressService.completeLevel(1, 5);
      await tester.pumpWidget(buildWidget());

      // Should show filled star for completed level (+ the one in header = 2)
      expect(find.byIcon(Icons.star), findsAtLeast(2));
    });

    testWidgets('completing level unlocks next level', (tester) async {
      // Complete level 1
      await progressService.completeLevel(1, 5);
      await tester.pumpWidget(buildWidget());
      await tester.pump();

      // Level 2 should now be visible as a number (unlocked)
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows level names', (tester) async {
      await tester.pumpWidget(buildWidget());

      // First level name should be visible
      final firstLevel = CampaignLevel.all.first;
      expect(find.text(firstLevel.name), findsOneWidget);
    });

    testWidgets('displays correct star count', (tester) async {
      // Complete 2 levels
      await progressService.completeLevel(1, 5);
      await progressService.completeLevel(2, 5);
      await tester.pumpWidget(buildWidget());

      // Should show 2/N in the star counter
      expect(find.text('2/${CampaignLevel.all.length}'), findsOneWidget);
    });
  });

  group('LevelIntroCard', () {
    final basicLevel = CampaignLevel(
      number: 1,
      name: 'First Steps',
      description: 'Learn the basics',
      targetHeight: 5.0,
    );

    final complexLevel = CampaignLevel(
      number: 10,
      name: 'Ultimate Challenge',
      description: 'Master all mechanics',
      targetHeight: 20.0,
      hasAutoSpawn: true,
      hasIncreasedGravity: true,
      gravityY: 15.0,
      hasWind: true,
      hasShapeVariety: true,
      hasBeamInstability: true,
      hasTimePressure: true,
    );

    Widget buildWidget({
      CampaignLevel? level,
      VoidCallback? onStart,
      VoidCallback? onBack,
    }) {
      return MaterialApp(
        home: LevelIntroCard(
          level: level ?? basicLevel,
          onStart: onStart ?? () {},
          onBack: onBack ?? () {},
        ),
      );
    }

    testWidgets('displays level number', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.text('LEVEL 1'), findsOneWidget);
    });

    testWidgets('displays level name uppercase', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.text('FIRST STEPS'), findsOneWidget);
    });

    testWidgets('displays description', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.text('Learn the basics'), findsOneWidget);
    });

    testWidgets('displays target height', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.text('TARGET'), findsOneWidget);
      expect(find.text('5 UNITS'), findsOneWidget);
    });

    testWidgets('displays height icon', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.byIcon(Icons.height), findsOneWidget);
    });

    testWidgets('shows START button', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.text('START'), findsOneWidget);
    });

    testWidgets('START button calls onStart', (tester) async {
      var startCalled = false;
      await tester.pumpWidget(buildWidget(
        onStart: () => startCalled = true,
      ));

      await tester.tap(find.text('START'));
      await tester.pump();

      expect(startCalled, isTrue);
    });

    testWidgets('displays back button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button calls onBack', (tester) async {
      var backCalled = false;
      await tester.pumpWidget(buildWidget(
        onBack: () => backCalled = true,
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('hides mechanics section for basic level', (tester) async {
      await tester.pumpWidget(buildWidget(level: basicLevel));

      expect(find.text('ACTIVE MECHANICS'), findsNothing);
    });

    testWidgets('shows ACTIVE MECHANICS for complex level', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('ACTIVE MECHANICS'), findsOneWidget);
    });

    testWidgets('shows AUTO DROP mechanic', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('AUTO DROP'), findsOneWidget);
      expect(find.byIcon(Icons.downloading), findsOneWidget);
    });

    testWidgets('shows HEAVY mechanic for increased gravity', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('HEAVY'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
    });

    testWidgets('shows WIND mechanic', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('WIND'), findsOneWidget);
      expect(find.byIcon(Icons.air), findsOneWidget);
    });

    testWidgets('shows VARIETY mechanic for multiple shapes', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('VARIETY'), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
    });

    testWidgets('shows UNSTABLE mechanic for beam instability', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('UNSTABLE'), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('shows TIMED mechanic for time pressure', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('TIMED'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('displays correct target height for complex level', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('20 UNITS'), findsOneWidget);
    });

    testWidgets('displays correct level number for complex level', (tester) async {
      await tester.pumpWidget(buildWidget(level: complexLevel));

      expect(find.text('LEVEL 10'), findsOneWidget);
    });
  });
}
