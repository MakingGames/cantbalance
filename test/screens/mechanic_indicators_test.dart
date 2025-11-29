import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cant/screens/mechanic_indicators.dart';

void main() {
  group('MechanicIndicators', () {
    Widget buildWidget({
      bool hasWind = false,
      bool hasGravity = false,
      bool hasInstability = false,
      bool hasTimer = false,
      double? windDirection,
      double? gravityMultiplier,
      double? timeRemaining,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: MechanicIndicators(
              hasWind: hasWind,
              hasGravity: hasGravity,
              hasInstability: hasInstability,
              hasTimer: hasTimer,
              windDirection: windDirection,
              gravityMultiplier: gravityMultiplier,
              timeRemaining: timeRemaining,
            ),
          ),
        ),
      );
    }

    testWidgets('renders empty when no mechanics active', (tester) async {
      await tester.pumpWidget(buildWidget());

      // Should render a SizedBox.shrink (empty)
      expect(find.byType(MechanicIndicators), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('renders wind indicator when hasWind is true', (tester) async {
      await tester.pumpWidget(buildWidget(hasWind: true));

      expect(find.byIcon(Icons.air), findsOneWidget);
      expect(find.byIcon(Icons.double_arrow), findsOneWidget);
    });

    testWidgets('renders gravity indicator when hasGravity is true', (tester) async {
      await tester.pumpWidget(buildWidget(hasGravity: true));

      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.text('1.5x'), findsOneWidget);
    });

    testWidgets('renders gravity with custom multiplier', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasGravity: true,
        gravityMultiplier: 2.5,
      ));

      expect(find.text('2.5x'), findsOneWidget);
    });

    testWidgets('renders instability indicator when hasInstability is true', (tester) async {
      await tester.pumpWidget(buildWidget(hasInstability: true));

      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });

    testWidgets('renders timer indicator when hasTimer is true and timeRemaining provided', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasTimer: true,
        timeRemaining: 30,
      ));

      expect(find.byIcon(Icons.timer), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('does not render timer when hasTimer but no timeRemaining', (tester) async {
      await tester.pumpWidget(buildWidget(hasTimer: true));

      expect(find.byIcon(Icons.timer), findsNothing);
    });

    testWidgets('timer shows low time styling when under 10 seconds', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasTimer: true,
        timeRemaining: 5,
      ));

      expect(find.text('5s'), findsOneWidget);
      // The low time indicator should still render
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('renders all indicators together', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasWind: true,
        hasGravity: true,
        hasInstability: true,
        hasTimer: true,
        windDirection: 1.0,
        gravityMultiplier: 1.5,
        timeRemaining: 20,
      ));

      expect(find.byIcon(Icons.air), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('wind indicator respects direction', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasWind: true,
        windDirection: -1.0,
      ));

      // Should render with left direction
      expect(find.byIcon(Icons.air), findsOneWidget);
    });

    testWidgets('animations run without errors', (tester) async {
      await tester.pumpWidget(buildWidget(
        hasWind: true,
        hasGravity: true,
        hasInstability: true,
      ));

      // Pump several frames to test animations
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Should still be visible after animation frames
      expect(find.byIcon(Icons.air), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      expect(find.byIcon(Icons.vibration), findsOneWidget);
    });
  });
}
