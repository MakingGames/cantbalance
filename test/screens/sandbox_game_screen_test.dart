import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/screens/sandbox_game_screen.dart';
import 'package:cant/services/dev_mode_service.dart';
import 'package:cant/services/orientation_service.dart';

void main() {
  group('SandboxGameScreen', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      DevModeService.resetForTesting();
      OrientationService.resetForTesting();
      // Initialize services
      await DevModeService.getInstance();
      await OrientationService.getInstance();
    });

    testWidgets('renders game screen with back button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SandboxGameScreen()),
      );

      // Allow async initialization
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('back button is tappable', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SandboxGameScreen(),
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

      // Now on SandboxGameScreen
      await tester.pump(const Duration(milliseconds: 100));

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Should be back at original screen
      expect(find.text('Go'), findsOneWidget);
    });

    testWidgets('does not show dev panel by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: SandboxGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Challenge panel toggles should not be visible initially
      expect(find.text('HAZARDS'), findsNothing);
      expect(find.text('Wind Gusts'), findsNothing);
    });

    testWidgets('shows hazards button in dev mode', (tester) async {
      // Enable dev mode
      SharedPreferences.setMockInitialValues({
        'dev_mode_enabled': true,
      });
      DevModeService.resetForTesting();
      OrientationService.resetForTesting();
      await DevModeService.getInstance();
      await OrientationService.getInstance();

      await tester.pumpWidget(
        const MaterialApp(home: SandboxGameScreen()),
      );

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Should show science icon when in dev mode
      expect(find.byIcon(Icons.science_outlined), findsOneWidget);
    });

  });
}
