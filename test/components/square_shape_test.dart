import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/components/square_shape.dart';
import 'package:cant/game/shape_size.dart';
import 'package:cant/game/constants.dart';

class TestGame extends Forge2DGame {
  TestGame() : super(gravity: Vector2(0, 10));
}

void main() {
  group('SquareShape', () {
    final gameTester = FlameTester(TestGame.new);

    group('initialization', () {
      gameTester.testGameWidget(
        'creates with default medium size',
        setUp: (game, tester) async {
          final shape = SquareShape(
            initialPosition: Vector2.zero(),
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.shapeSize, equals(ShapeSize.medium));
        },
      );

      gameTester.testGameWidget(
        'creates with specified small size',
        setUp: (game, tester) async {
          final shape = SquareShape(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.small,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.shapeSize, equals(ShapeSize.small));
        },
      );

      gameTester.testGameWidget(
        'creates with specified large size',
        setUp: (game, tester) async {
          final shape = SquareShape(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.large,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.shapeSize, equals(ShapeSize.large));
        },
      );

      gameTester.testGameWidget(
        'spawns at specified position',
        setUp: (game, tester) async {
          final position = Vector2(5, -10);
          final shape = SquareShape(initialPosition: position);
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.body.position.x, closeTo(5, 0.1));
          expect(shape.body.position.y, closeTo(-10, 0.1));
        },
      );
    });

    group('physics body', () {
      gameTester.testGameWidget(
        'creates dynamic body',
        setUp: (game, tester) async {
          final shape = SquareShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.body.bodyType, equals(BodyType.dynamic));
        },
      );

      gameTester.testGameWidget(
        'has correct density for medium size',
        setUp: (game, tester) async {
          final shape = SquareShape(
            initialPosition: Vector2.zero(),
            shapeSize: ShapeSize.medium,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.density, equals(ShapeSize.medium.density));
        },
      );

      gameTester.testGameWidget(
        'uses default friction',
        setUp: (game, tester) async {
          final shape = SquareShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.friction, equals(GameConstants.shapeFriction));
        },
      );

      gameTester.testGameWidget(
        'uses friction override when provided',
        setUp: (game, tester) async {
          final shape = SquareShape(
            initialPosition: Vector2.zero(),
            frictionOverride: 0.5,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.friction, equals(0.5));
        },
      );

      gameTester.testGameWidget(
        'uses correct restitution',
        setUp: (game, tester) async {
          final shape = SquareShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          final fixture = shape.body.fixtures.first;
          expect(fixture.restitution, equals(GameConstants.shapeRestitution));
        },
      );
    });

    group('velocity tracking', () {
      gameTester.testGameWidget(
        'hasHadVelocity starts as false',
        setUp: (game, tester) async {
          final shape = SquareShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.hasHadVelocity, isFalse);
        },
      );

      gameTester.testGameWidget(
        'hasHadVelocity becomes true after falling',
        setUp: (game, tester) async {
          final shape = SquareShape(initialPosition: Vector2(0, -5));
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          // Let the shape fall for a bit
          for (var i = 0; i < 60; i++) {
            game.update(1 / 60);
          }
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.hasHadVelocity, isTrue);
        },
      );
    });

    group('damping', () {
      gameTester.testGameWidget(
        'uses default zero damping',
        setUp: (game, tester) async {
          final shape = SquareShape(initialPosition: Vector2.zero());
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.body.linearDamping, equals(0.0));
          expect(shape.body.angularDamping, equals(0.0));
        },
      );

      gameTester.testGameWidget(
        'uses custom damping when specified',
        setUp: (game, tester) async {
          final shape = SquareShape(
            initialPosition: Vector2.zero(),
            linearDamping: 0.5,
            angularDamping: 0.3,
          );
          await game.world.add(shape);
          await game.ready();
        },
        verify: (game, tester) async {
          final shape = game.world.children.whereType<SquareShape>().first;
          expect(shape.body.linearDamping, equals(0.5));
          expect(shape.body.angularDamping, equals(0.3));
        },
      );
    });
  });
}
