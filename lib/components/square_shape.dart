import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/constants.dart';
import '../game/shape_size.dart';

class SquareShape extends BodyComponent {
  final Vector2 initialPosition;
  final ShapeSize shapeSize;

  SquareShape({
    required this.initialPosition,
    this.shapeSize = ShapeSize.medium,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(shapeSize.size / 2, shapeSize.size / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(shape)
      ..density = shapeSize.density
      ..friction = GameConstants.shapeFriction
      ..restitution = GameConstants.shapeRestitution;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeSize.size,
      height: shapeSize.size,
    );
    canvas.drawRect(rect, Paint()..color = shapeSize.color);
  }
}
