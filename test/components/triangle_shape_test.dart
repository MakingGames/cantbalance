import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/components/triangle_shape.dart';
import 'package:cant/game/shape_size.dart';
import 'package:cant/game/constants.dart';

class TestGame extends Forge2DGame {
  TestGame() : super(gravity: Vector2(0, 10));
}

void main() {
  group('TriangleShape', () {
    final gameTester = FlameTester(TestGame.new);

    group('initialization', () {
      gameTester.testGameWidget(
        'creates with default medium size',
        setUp: (game, tester) async {
          final shape = TriangleShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          expect(shape.shapeSize, equals(ShapeSize.medium));
        },
      );

      gameTester.testGameWidget(
        'creates with specified large size',
        setUp: (game, tester) async {
          final shape = TriangleShape(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.large,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          expect(shape.shapeSize, equals(ShapeSize.large));
        },
      );

      gameTester.testGameWidget(
        'spawns at specified position',
        setUp: (game, tester) async {
          final shape = TriangleShape(initialPosition: Vector2(-2, 4));
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          expect(shape.body.position.x, closeTo(-2, 0.1));
          expect(shape.body.position.y, closeTo(4, 0.1));
        },
      );
    });

    group('physics body', () {
      gameTester.testGameWidget(
        'creates dynamic body',
        setUp: (game, tester) async {
          final shape = TriangleShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          expect(shape.body.bodyType, equals(BodyType.dynamic));
        },
      );

      gameTester.testGameWidget(
        'has reduced density compared to base (0.9x)',
        setUp: (game, tester) async {
          final shape = TriangleShape(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.medium,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          final fixture = shape.body.fixtures.first;
          // Triangle has 0.9x density for less stability
          expect(fixture.density, closeTo(ShapeSize.medium.density * 0.9, 0.01));
        },
      );

      gameTester.testGameWidget(
        'has reduced friction compared to default (0.7x)',
        setUp: (game, tester) async {
          final shape = TriangleShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          final fixture = shape.body.fixtures.first;
          // Triangle has 0.7x friction for more slippery behavior
          expect(fixture.friction, closeTo(GameConstants.shapeFriction * 0.7, 0.01));
        },
      );

      gameTester.testGameWidget(
        'uses exact friction override when provided',
        setUp: (game, tester) async {
          final shape = TriangleShape(
            initialPosition: Vector2.zero(),
            frictionOverride: 0.5,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          final fixture = shape.body.fixtures.first;
          // With override, no 0.7x modifier applied
          expect(fixture.friction, equals(0.5));
        },
      );
    });

    group('velocity tracking', () {
      gameTester.testGameWidget(
        'hasHadVelocity starts as false',
        setUp: (game, tester) async {
          final shape = TriangleShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<TriangleShape>().first;
          expect(shape.hasHadVelocity, isFalse);
        },
      );

      gameTester.testGameWidget(
        'hasHadVelocity becomes true after falling',
        setUp: (game, tester) async {
          final shape = TriangleShape(initialPosition: Vector2(0, -5));
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          for (var i = 0; i < 60; i++) {
            game.update(1 / 60);
          }
          final shape = game.world.children.whereType<TriangleShape>().first;
          expect(shape.hasHadVelocity, isTrue);
        },
      );
    });
  });
}
