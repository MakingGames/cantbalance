import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/components/circle_shape.dart';
import 'package:cant/game/shape_size.dart';
import 'package:cant/game/constants.dart';

class TestGame extends Forge2DGame {
  TestGame() : super(gravity: Vector2(0, 10));
}

void main() {
  group('GameCircle', () {
    final gameTester = FlameTester(TestGame.new);

    group('initialization', () {
      gameTester.testGameWidget(
        'creates with default medium size',
        setUp: (game, tester) async {
          final shape = GameCircle(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          expect(shape.shapeSize, equals(ShapeSize.medium));
        },
      );

      gameTester.testGameWidget(
        'creates with specified small size',
        setUp: (game, tester) async {
          final shape = GameCircle(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.small,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          expect(shape.shapeSize, equals(ShapeSize.small));
        },
      );

      gameTester.testGameWidget(
        'spawns at specified position',
        setUp: (game, tester) async {
          final shape = GameCircle(initialPosition: Vector2(3, -7));
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          expect(shape.body.position.x, closeTo(3, 0.1));
          expect(shape.body.position.y, closeTo(-7, 0.1));
        },
      );
    });

    group('physics body', () {
      gameTester.testGameWidget(
        'creates dynamic body',
        setUp: (game, tester) async {
          final shape = GameCircle(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          expect(shape.body.bodyType, equals(BodyType.dynamic));
        },
      );

      gameTester.testGameWidget(
        'has correct density for large size',
        setUp: (game, tester) async {
          final shape = GameCircle(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.large,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.density, equals(ShapeSize.large.density));
        },
      );

      gameTester.testGameWidget(
        'uses default friction',
        setUp: (game, tester) async {
          final shape = GameCircle(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.friction, equals(GameConstants.shapeFriction));
        },
      );

      gameTester.testGameWidget(
        'uses friction override when provided',
        setUp: (game, tester) async {
          final shape = GameCircle(
            initialPosition: Vector2.zero(),
            frictionOverride: 0.9,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.friction, equals(0.9));
        },
      );
    });

    group('velocity tracking', () {
      gameTester.testGameWidget(
        'hasHadVelocity starts as false',
        setUp: (game, tester) async {
          final shape = GameCircle(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<GameCircle>().first;
          expect(shape.hasHadVelocity, isFalse);
        },
      );

      gameTester.testGameWidget(
        'hasHadVelocity becomes true after falling',
        setUp: (game, tester) async {
          final shape = GameCircle(initialPosition: Vector2(0, -5));
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          for (var i = 0; i < 60; i++) {
            game.update(1 / 60);
          }
          final shape = game.world.children.whereType<GameCircle>().first;
          expect(shape.hasHadVelocity, isTrue);
        },
      );
    });
  });
}
