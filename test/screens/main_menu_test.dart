import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/screens/main_menu.dart';

void main() {
  group('MainMenu', () {
    late bool challengePressed;
    late bool sandboxPressed;
    late bool campaignPressed;
    late bool stackingPressed;
    late bool themeToggled;
    late bool orientationToggled;
    late int logoTapCount;

    setUp(() {
      challengePressed = false;
      sandboxPressed = false;
      campaignPressed = false;
      stackingPressed = false;
      themeToggled = false;
      orientationToggled = false;
      logoTapCount = 0;
    });

    Widget buildMainMenu({
      bool isDarkMode = true,
      bool isLandscape = false,
      bool isDevMode = false,
      int highScore = 0,
      int campaignStars = 0,
      int totalCampaignLevels = 15,
    }) {
      return MaterialApp(
        home: MainMenu(
          onChallengePressed: () => challengePressed = true,
          onSandboxPressed: () => sandboxPressed = true,
          onCampaignPressed: () => campaignPressed = true,
          onStackingPressed: () => stackingPressed = true,
          onThemeToggle: () => themeToggled = true,
          onOrientationToggle: () => orientationToggled = true,
          onLogoTap: () => logoTapCount++,
          isDarkMode: isDarkMode,
          isLandscape: isLandscape,
          isDevMode: isDevMode,
          highScore: highScore,
          campaignStars: campaignStars,
          totalCampaignLevels: totalCampaignLevels,
        ),
      );
    }

    group('UI elements', () {
      testWidgets('displays title and subtitle', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        expect(find.text('CANT'), findsOneWidget);
        expect(find.text('a balance game'), findsOneWidget);
      });

      testWidgets('displays all four game mode buttons', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        expect(find.text('CHALLENGE'), findsOneWidget);
        expect(find.text('SANDBOX'), findsOneWidget);
        expect(find.text('CAMPAIGN'), findsOneWidget);
        expect(find.text('STACKING'), findsOneWidget);
      });

      testWidgets('displays theme toggle button', (tester) async {
        await tester.pumpWidget(buildMainMenu(isDarkMode: true));

        // In dark mode, should show light_mode icon to toggle to light
        expect(find.byIcon(Icons.light_mode), findsOneWidget);
      });

      testWidgets('displays orientation toggle button', (tester) async {
        await tester.pumpWidget(buildMainMenu(isLandscape: false));

        // In portrait mode, should show portrait icon
        expect(find.byIcon(Icons.stay_current_portrait), findsOneWidget);
      });

      testWidgets('shows landscape icon when in landscape mode', (tester) async {
        await tester.pumpWidget(buildMainMenu(isLandscape: true));

        expect(find.byIcon(Icons.stay_current_landscape), findsOneWidget);
      });

      testWidgets('shows dark_mode icon when in light mode', (tester) async {
        await tester.pumpWidget(buildMainMenu(isDarkMode: false));

        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      });
    });

    group('button interactions', () {
      testWidgets('Challenge button triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        await tester.tap(find.text('CHALLENGE'));
        await tester.pumpAndSettle();

        expect(challengePressed, isTrue);
      });

      testWidgets('Sandbox button triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        await tester.tap(find.text('SANDBOX'));
        await tester.pumpAndSettle();

        expect(sandboxPressed, isTrue);
      });

      testWidgets('Campaign button triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        await tester.tap(find.text('CAMPAIGN'));
        await tester.pumpAndSettle();

        expect(campaignPressed, isTrue);
      });

      testWidgets('Stacking button triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        await tester.tap(find.text('STACKING'));
        await tester.pumpAndSettle();

        expect(stackingPressed, isTrue);
      });

      testWidgets('Theme toggle button triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu(isDarkMode: true));

        await tester.tap(find.byIcon(Icons.light_mode));
        await tester.pumpAndSettle();

        expect(themeToggled, isTrue);
      });

      testWidgets('Orientation toggle button triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu(isLandscape: false));

        await tester.tap(find.byIcon(Icons.stay_current_portrait));
        await tester.pumpAndSettle();

        expect(orientationToggled, isTrue);
      });

      testWidgets('Logo tap triggers callback', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        await tester.tap(find.text('CANT'));
        await tester.pumpAndSettle();

        expect(logoTapCount, equals(1));
      });

      testWidgets('Multiple logo taps increment counter', (tester) async {
        await tester.pumpWidget(buildMainMenu());

        await tester.tap(find.text('CANT'));
        await tester.tap(find.text('CANT'));
        await tester.tap(find.text('CANT'));
        await tester.pumpAndSettle();

        expect(logoTapCount, equals(3));
      });
    });

    group('high score display', () {
      testWidgets('hides high score when zero', (tester) async {
        await tester.pumpWidget(buildMainMenu(highScore: 0));

        expect(find.textContaining('BEST:'), findsNothing);
      });

      testWidgets('shows high score when greater than zero', (tester) async {
        await tester.pumpWidget(buildMainMenu(highScore: 42));

        expect(find.text('BEST: 42'), findsOneWidget);
      });
    });

    group('campaign progress display', () {
      testWidgets('hides campaign stars when zero', (tester) async {
        await tester.pumpWidget(buildMainMenu(campaignStars: 0));

        expect(find.textContaining('★'), findsNothing);
      });

      testWidgets('shows campaign stars when greater than zero', (tester) async {
        await tester.pumpWidget(buildMainMenu(
          campaignStars: 5,
          totalCampaignLevels: 15,
        ));

        expect(find.text('★ 5 / 15'), findsOneWidget);
      });
    });

    group('dev mode indicator', () {
      testWidgets('hides dev mode indicator when not in dev mode', (tester) async {
        await tester.pumpWidget(buildMainMenu(isDevMode: false));

        expect(find.text('DEV MODE'), findsNothing);
        expect(find.byIcon(Icons.science), findsNothing);
      });

      testWidgets('shows dev mode indicator when in dev mode', (tester) async {
        await tester.pumpWidget(buildMainMenu(isDevMode: true));

        expect(find.text('DEV MODE'), findsOneWidget);
        expect(find.byIcon(Icons.science), findsOneWidget);
      });
    });
  });
}
