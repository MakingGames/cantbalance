import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cant/screens/game_hud.dart';

void main() {
  group('GameHUD', () {
    Widget buildWidget({
      Widget? gameWidget,
      VoidCallback? onBack,
      bool showDevToggle = false,
      bool isDevPanelOpen = false,
      VoidCallback? onDevToggle,
      Widget? devPanel,
      VoidCallback? onDismissDevPanel,
      List<Widget> leftIndicators = const [],
      Widget? rightContent,
      Widget? centerContent,
      Widget? bottomContent,
      bool showHUD = true,
      List<Widget> overlays = const [],
    }) {
      return MaterialApp(
        home: GameHUD(
          gameWidget: gameWidget ?? Container(color: Colors.grey),
          onBack: onBack ?? () {},
          showDevToggle: showDevToggle,
          isDevPanelOpen: isDevPanelOpen,
          onDevToggle: onDevToggle,
          devPanel: devPanel,
          onDismissDevPanel: onDismissDevPanel,
          leftIndicators: leftIndicators,
          rightContent: rightContent,
          centerContent: centerContent,
          bottomContent: bottomContent,
          showHUD: showHUD,
          overlays: overlays,
        ),
      );
    }

    testWidgets('renders game widget', (tester) async {
      await tester.pumpWidget(buildWidget(
        gameWidget: Container(key: const Key('game'), color: Colors.blue),
      ));

      expect(find.byKey(const Key('game')), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button calls onBack', (tester) async {
      var backPressed = false;
      await tester.pumpWidget(buildWidget(
        onBack: () => backPressed = true,
      ));

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(backPressed, isTrue);
    });

    testWidgets('hides dev toggle by default', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byIcon(Icons.science), findsNothing);
      expect(find.byIcon(Icons.science_outlined), findsNothing);
    });

    testWidgets('shows dev toggle when showDevToggle is true', (tester) async {
      await tester.pumpWidget(buildWidget(showDevToggle: true));

      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });

    testWidgets('dev toggle shows filled icon when panel is open', (tester) async {
      await tester.pumpWidget(buildWidget(
        showDevToggle: true,
        isDevPanelOpen: true,
      ));

      expect(find.byIcon(Icons.science), findsOneWidget);
    });

    testWidgets('dev toggle calls onDevToggle', (tester) async {
      var toggled = false;
      await tester.pumpWidget(buildWidget(
        showDevToggle: true,
        onDevToggle: () => toggled = true,
      ));

      await tester.tap(find.byIcon(Icons.science_outlined));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('shows dev panel when open', (tester) async {
      await tester.pumpWidget(buildWidget(
        showDevToggle: true,
        isDevPanelOpen: true,
        devPanel: Container(key: const Key('devPanel')),
      ));

      expect(find.byKey(const Key('devPanel')), findsOneWidget);
    });

    testWidgets('hides dev panel when closed', (tester) async {
      await tester.pumpWidget(buildWidget(
        showDevToggle: true,
        isDevPanelOpen: false,
        devPanel: Container(key: const Key('devPanel')),
      ));

      expect(find.byKey(const Key('devPanel')), findsNothing);
    });

    testWidgets('tapping game widget calls onDismissDevPanel when panel open', (tester) async {
      var dismissed = false;
      await tester.pumpWidget(buildWidget(
        isDevPanelOpen: true,
        onDismissDevPanel: () => dismissed = true,
      ));

      // Tap somewhere on the game widget area
      await tester.tapAt(const Offset(200, 400));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('shows left indicators', (tester) async {
      await tester.pumpWidget(buildWidget(
        leftIndicators: [
          Container(key: const Key('indicator1')),
          Container(key: const Key('indicator2')),
        ],
      ));

      expect(find.byKey(const Key('indicator1')), findsOneWidget);
      expect(find.byKey(const Key('indicator2')), findsOneWidget);
    });

    testWidgets('shows right content', (tester) async {
      await tester.pumpWidget(buildWidget(
        rightContent: Container(key: const Key('rightContent')),
      ));

      expect(find.byKey(const Key('rightContent')), findsOneWidget);
    });

    testWidgets('shows center content', (tester) async {
      await tester.pumpWidget(buildWidget(
        centerContent: Container(key: const Key('centerContent')),
      ));

      expect(find.byKey(const Key('centerContent')), findsOneWidget);
    });

    testWidgets('shows bottom content', (tester) async {
      await tester.pumpWidget(buildWidget(
        bottomContent: Container(key: const Key('bottomContent')),
      ));

      expect(find.byKey(const Key('bottomContent')), findsOneWidget);
    });

    testWidgets('hides HUD elements when showHUD is false', (tester) async {
      await tester.pumpWidget(buildWidget(
        showHUD: false,
        rightContent: Container(key: const Key('rightContent')),
        bottomContent: Container(key: const Key('bottomContent')),
      ));

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byKey(const Key('rightContent')), findsNothing);
      expect(find.byKey(const Key('bottomContent')), findsNothing);
    });

    testWidgets('shows overlays', (tester) async {
      await tester.pumpWidget(buildWidget(
        overlays: [
          Container(key: const Key('overlay1')),
          Container(key: const Key('overlay2')),
        ],
      ));

      expect(find.byKey(const Key('overlay1')), findsOneWidget);
      expect(find.byKey(const Key('overlay2')), findsOneWidget);
    });

    testWidgets('overlays are visible even when showHUD is false', (tester) async {
      await tester.pumpWidget(buildWidget(
        showHUD: false,
        overlays: [
          Container(key: const Key('overlay')),
        ],
      ));

      expect(find.byKey(const Key('overlay')), findsOneWidget);
    });
  });
}
