import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/screens/stacking_game_screen.dart';
import 'package:cant/screens/shape_picker.dart';
import 'package:cant/services/dev_mode_service.dart';

void main() {
  group('StackingGameScreen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      DevModeService.resetForTesting();
      await DevModeService.getInstance();
    });

    testWidgets('renders game screen with back button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      // Allow async initialization
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders shape picker', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show shape picker
      expect(find.byType(ShapePicker), findsOneWidget);
    });

    testWidgets('displays score starting at 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Score should start at 0 shapes
      expect(find.text('0 shapes'), findsOneWidget);
    });

    testWidgets('displays height value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show height starting at 0.0m
      expect(find.text('0.0m'), findsOneWidget);
    });

    testWidgets('back button is tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const StackingGameScreen(),
                ),
              ),
              child: const Text('Go'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Now on StackingGameScreen
      await tester.pump(const Duration(milliseconds: 100));

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be back at original screen
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('does not show physics panel by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Physics panel options should not be visible initially
      expect(find.text('HELPERS'), findsNothing);
      expect(find.text('High Friction'), findsNothing);
    });

    testWidgets('shows settings button in dev mode', (tester) async {
      // Enable dev mode
      SharedPreferences.setMockInitialValues({
        'dev_mode_enabled': true,
      });
      DevModeService.resetForTesting();
      await DevModeService.getInstance();

      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show science icon in dev mode
      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });

    testWidgets('tapping settings button toggles physics panel',
        (tester) async {
      // Enable dev mode
      SharedPreferences.setMockInitialValues({
        'dev_mode_enabled': true,
      });
      DevModeService.resetForTesting();
      await DevModeService.getInstance();

      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Tap science button
      await tester.tap(find.byIcon(Icons.science_outlined));
      await tester.pump();
      await tester.pump();

      // Physics panel should now be visible
      expect(find.text('HELPERS'), findsOneWidget);
    });

    testWidgets('shows next shape indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: StackingGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show "NEXT" label
      expect(find.text('NEXT'), findsOneWidget);
    });
  });
}
