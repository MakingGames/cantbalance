import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/components/scale_beam.dart';
import 'package:cant/game/constants.dart';

class TestGame extends Forge2DGame {
  TestGame() : super(gravity: Vector2(0, 10));
}

void main() {
  group('ScaleBeam', () {
    final gameTester = FlameTester(TestGame.new);

    group('initialization', () {
      gameTester.testGameWidget(
        'creates with specified size',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          expect(beam.beamSize.x, equals(10));
          expect(beam.beamSize.y, equals(1));
        },
      );

      gameTester.testGameWidget(
        'spawns at specified position',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2(5, -2),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          expect(beam.body.position.x, closeTo(5, 0.1));
          expect(beam.body.position.y, closeTo(-2, 0.1));
        },
      );
    });

    group('physics body', () {
      gameTester.testGameWidget(
        'creates dynamic body',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          expect(beam.body.bodyType, equals(BodyType.dynamic));
        },
      );

      gameTester.testGameWidget(
        'has correct density',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          final fixture = beam.body.fixtures.first;
          expect(fixture.density, equals(GameConstants.beamDensity));
        },
      );

      gameTester.testGameWidget(
        'has correct restitution',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          final fixture = beam.body.fixtures.first;
          expect(fixture.restitution, equals(GameConstants.beamRestitution));
        },
      );
    });

    group('setFriction', () {
      gameTester.testGameWidget(
        'changes fixture friction',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          beam.setFriction(0.5);
          final fixture = beam.body.fixtures.first;
          expect(fixture.friction, equals(0.5));
        },
      );

      gameTester.testGameWidget(
        'can set to slippery friction',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          beam.setFriction(GameConstants.beamSlipperyFriction);
          final fixture = beam.body.fixtures.first;
          expect(fixture.friction, equals(GameConstants.beamSlipperyFriction));
        },
      );
    });

    group('setAngularDamping', () {
      gameTester.testGameWidget(
        'changes body angular damping',
        setUp: (game, tester) async {
          final beam = ScaleBeam(
            beamSize: Vector2(10, 1),
            initialPosition: Vector2.zero(),
          );
          await game.world.add(beam);
          await game.ready();
        },
        verify: (game, tester) async {
          final beam = game.world.children.whereType<ScaleBeam>().first;
          beam.setAngularDamping(5.0);
          expect(beam.body.angularDamping, equals(5.0));
        },
      );
    });
  });
}
