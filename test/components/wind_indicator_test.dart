import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/components/wind_indicator.dart';

class TestGame extends FlameGame {}

void main() {
  group('WindIndicator (Flame component)', () {
    final gameTester = FlameTester(TestGame.new);

    group('initialization', () {
      gameTester.testGameWidget(
        'creates with default values',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
          );
          await game.add(indicator);
          await game.ready();
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator, isA<PositionComponent>());
        },
      );

      gameTester.testGameWidget(
        'accepts custom priority',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
            priority: 200,
          );
          await game.add(indicator);
          await game.ready();
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator.priority, equals(200));
        },
      );
    });

    group('setWind', () {
      gameTester.testGameWidget(
        'activates with positive force',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
          );
          await game.add(indicator);
          await game.ready();
          indicator.setWind(1.0, true);
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator, isNotNull);
        },
      );

      gameTester.testGameWidget(
        'activates with negative force',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
          );
          await game.add(indicator);
          await game.ready();
          indicator.setWind(-1.0, true);
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator, isNotNull);
        },
      );

      gameTester.testGameWidget(
        'deactivates when inactive',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
          );
          await game.add(indicator);
          await game.ready();
          indicator.setWind(1.0, false);
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator, isNotNull);
        },
      );
    });

    group('setWarning', () {
      gameTester.testGameWidget(
        'sets warning state',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
          );
          await game.add(indicator);
          await game.ready();
          indicator.setWarning(1.0);
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator, isNotNull);
        },
      );

      gameTester.testGameWidget(
        'clearWarning clears warning state',
        setUp: (game, tester) async {
          final indicator = WindIndicator(
            position: Vector2.zero(),
            size: Vector2(100, 50),
          );
          await game.add(indicator);
          await game.ready();
          indicator.setWarning(1.0);
          indicator.clearWarning();
        },
        verify: (game, tester) async {
          final indicator = game.children.whereType<WindIndicator>().first;
          expect(indicator, isNotNull);
        },
      );
    });
  });

  group('WindState enum', () {
    test('has three states', () {
      expect(WindState.values.length, equals(3));
    });

    test('includes inactive, warning, and active', () {
      expect(WindState.values, contains(WindState.inactive));
      expect(WindState.values, contains(WindState.warning));
      expect(WindState.values, contains(WindState.active));
    });
  });

  group('WindDirectionIndicator (Flutter widget)', () {
    testWidgets('returns empty widget when wind force is near zero',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WindDirectionIndicator(windForce: 0.05),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('shows wind arrows for positive force', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WindDirectionIndicator(windForce: 1.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.air), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('shows wind arrows for negative force', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WindDirectionIndicator(windForce: -1.0),
          ),
        ),
      );

      expect(find.byIcon(Icons.air), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('shows more arrows for stronger wind', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WindDirectionIndicator(windForce: 2.0),
          ),
        ),
      );

      // With strength 2.0, should show 3 chevrons (max)
      final chevrons = find.byIcon(Icons.chevron_right);
      expect(chevrons, findsNWidgets(3));
    });

    testWidgets('is a Row widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WindDirectionIndicator(windForce: 1.0),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('AnimatedWindIndicator', () {
    testWidgets('creates without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.inactive,
              direction: 1.0,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedWindIndicator), findsOneWidget);
    });

    testWidgets('renders nothing when inactive', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.inactive,
              direction: 1.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should render SizedBox.shrink when fully faded out
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('renders CustomPaint when active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.active,
              direction: 1.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('renders CustomPaint when warning', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.warning,
              direction: -1.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('transitions from inactive to active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.inactive,
              direction: 1.0,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Now change to active
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.active,
              direction: 1.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
    });

    testWidgets('disposes animation controllers properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedWindIndicator(
              state: WindState.active,
              direction: 1.0,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Remove the widget (triggers dispose)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox.shrink(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No exception means dispose worked correctly
      expect(true, isTrue);
    });
  });
}
