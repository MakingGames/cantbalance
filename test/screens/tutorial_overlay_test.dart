import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/screens/tutorial_overlay.dart';

void main() {
  group('TutorialOverlay', () {
    testWidgets('displays touch icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () {}),
        ),
      );

      expect(find.byIcon(Icons.touch_app), findsOneWidget);
    });

    testWidgets('displays main instruction text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () {}),
        ),
      );

      expect(find.text('DRAG ABOVE THE BEAM'), findsOneWidget);
      expect(find.text('TO DROP SHAPES'), findsOneWidget);
    });

    testWidgets('displays secondary instruction text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () {}),
        ),
      );

      expect(find.text('KEEP THE BALANCE'), findsOneWidget);
      expect(find.text('TILT YOUR PHONE TO SHIFT GRAVITY'), findsOneWidget);
    });

    testWidgets('displays tap to start text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () {}),
        ),
      );

      expect(find.text('TAP TO START'), findsOneWidget);
    });

    testWidgets('tapping calls onDismiss', (tester) async {
      var dismissCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () => dismissCalled = true),
        ),
      );

      await tester.tap(find.byType(TutorialOverlay));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });

    testWidgets('tapping anywhere dismisses overlay', (tester) async {
      var dismissCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () => dismissCalled = true),
        ),
      );

      // Tap on the icon
      await tester.tap(find.byIcon(Icons.touch_app));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });

    testWidgets('tapping on text dismisses overlay', (tester) async {
      var dismissCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: TutorialOverlay(onDismiss: () => dismissCalled = true),
        ),
      );

      // Tap on the main instruction text
      await tester.tap(find.text('DRAG ABOVE THE BEAM'));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });
  });
}
