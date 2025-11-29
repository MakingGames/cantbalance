import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/constants.dart';
import '../utils/colors.dart';
import '../utils/shape_painter.dart';

class ScaleBeam extends BodyComponent {
  final Vector2 beamSize;
  final Vector2 initialPosition;

  ScaleBeam({
    required this.beamSize,
    required this.initialPosition,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      angularDamping: GameConstants.beamAngularDamping,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(beamSize.x / 2, beamSize.y / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(shape)
      ..density = GameConstants.beamDensity
      ..friction = GameConstants.beamFriction
      ..restitution = GameConstants.beamRestitution;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    ShapePainter.drawBeam(canvas, beamSize.x, beamSize.y, GameColors.beam);
  }

  /// Set the beam's friction (for slippery beam effect)
  void setFriction(double friction) {
    for (final fixture in body.fixtures) {
      fixture.friction = friction;
    }
  }

  /// Set the beam's angular damping (controls how quickly it stops swinging)
  void setAngularDamping(double damping) {
    body.angularDamping = damping;
  }
}
