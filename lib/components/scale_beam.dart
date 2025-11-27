import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/constants.dart';
import '../utils/colors.dart';

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
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: beamSize.x,
      height: beamSize.y,
    );
    canvas.drawRect(rect, Paint()..color = GameColors.beam);
  }
}
