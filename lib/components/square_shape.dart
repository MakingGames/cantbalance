import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/constants.dart';
import '../utils/colors.dart';

class SquareShape extends BodyComponent {
  final Vector2 initialPosition;
  final double shapeSize;

  SquareShape({
    required this.initialPosition,
    double size = GameConstants.squareSize,
  }) : shapeSize = size;

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(shapeSize / 2, shapeSize / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(shape)
      ..density = GameConstants.shapeDensity
      ..friction = GameConstants.shapeFriction
      ..restitution = GameConstants.shapeRestitution;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeSize,
      height: shapeSize,
    );
    canvas.drawRect(rect, Paint()..color = GameColors.shapeMedium);
  }
}
