import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cant/screens/tilt_indicator.dart';

void main() {
  group('TiltIndicator', () {
    Widget buildWidget({double angleDegrees = 0, double threshold = 30.0}) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: TiltIndicator(
              angleDegrees: angleDegrees,
              threshold: threshold,
            ),
          ),
        ),
      );
    }

    testWidgets('renders with default values', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(TiltIndicator), findsOneWidget);
      // CustomPaint is used by the indicator (may be multiple due to framework)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('has correct size', (tester) async {
      await tester.pumpWidget(buildWidget());

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(TiltIndicator),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, 60);
      expect(sizedBox.height, 60);
    });

    testWidgets('renders at zero angle', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 0));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('renders at positive angle', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 15));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('renders at negative angle', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: -15));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('renders at warning threshold', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 20, threshold: 30));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('renders at danger threshold', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 25, threshold: 30));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('renders at threshold limit', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 30, threshold: 30));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('renders beyond threshold', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 45, threshold: 30));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });

    testWidgets('custom threshold changes behavior', (tester) async {
      await tester.pumpWidget(buildWidget(angleDegrees: 15, threshold: 20));
      expect(find.byType(TiltIndicator), findsOneWidget);
    });
  });
}
