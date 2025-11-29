import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/components/ghost_shape.dart';
import 'package:cant/game/shape_size.dart';

class TestGame extends FlameGame {}

void main() {
  group('GhostShape', () {
    final gameTester = FlameTester(TestGame.new);

    group('initialization', () {
      gameTester.testGameWidget(
        'creates with default medium size',
        setUp: (game, tester) async {
          final ghost = GhostShape(position: Vector2.zero());
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.shapeSize, equals(ShapeSize.medium));
        },
      );

      gameTester.testGameWidget(
        'creates with specified small size',
        setUp: (game, tester) async {
          final ghost = GhostShape(
            position: Vector2.zero(),
            shapeSize: ShapeSize.small,
          );
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.shapeSize, equals(ShapeSize.small));
        },
      );

      gameTester.testGameWidget(
        'creates with specified large size',
        setUp: (game, tester) async {
          final ghost = GhostShape(
            position: Vector2.zero(),
            shapeSize: ShapeSize.large,
          );
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.shapeSize, equals(ShapeSize.large));
        },
      );

      gameTester.testGameWidget(
        'spawns at specified position',
        setUp: (game, tester) async {
          final ghost = GhostShape(position: Vector2(5, -3));
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.position.x, equals(5));
          expect(ghost.position.y, equals(-3));
        },
      );
    });

    group('size and anchor', () {
      gameTester.testGameWidget(
        'size matches shapeSize dimensions for medium',
        setUp: (game, tester) async {
          final ghost = GhostShape(
            position: Vector2.zero(),
            shapeSize: ShapeSize.medium,
          );
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.size.x, closeTo(ShapeSize.medium.size, 0.01));
          expect(ghost.size.y, closeTo(ShapeSize.medium.size, 0.01));
        },
      );

      gameTester.testGameWidget(
        'size matches shapeSize dimensions for small',
        setUp: (game, tester) async {
          final ghost = GhostShape(
            position: Vector2.zero(),
            shapeSize: ShapeSize.small,
          );
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.size.x, closeTo(ShapeSize.small.size, 0.01));
          expect(ghost.size.y, closeTo(ShapeSize.small.size, 0.01));
        },
      );

      gameTester.testGameWidget(
        'anchor is centered',
        setUp: (game, tester) async {
          final ghost = GhostShape(position: Vector2.zero());
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost.anchor, equals(Anchor.center));
        },
      );
    });

    group('component hierarchy', () {
      gameTester.testGameWidget(
        'is a PositionComponent',
        setUp: (game, tester) async {
          final ghost = GhostShape(position: Vector2.zero());
          await game.add(ghost);
          await game.ready();
        },
        verify: (game, tester) async {
          final ghost = game.children.whereType<GhostShape>().first;
          expect(ghost, isA<PositionComponent>());
        },
      );
    });
  });
}
