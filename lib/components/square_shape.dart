import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/constants.dart';
import '../game/shape_size.dart';
import '../utils/shape_painter.dart';

class SquareShape extends BodyComponent {
  final Vector2 initialPosition;
  final ShapeSize shapeSize;
  final double? frictionOverride;
  final double linearDamping;
  final double angularDamping;

  SquareShape({
    required this.initialPosition,
    this.shapeSize = ShapeSize.medium,
    this.frictionOverride,
    this.linearDamping = 0.0,
    this.angularDamping = 0.0,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      linearDamping: linearDamping,
      angularDamping: angularDamping,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(shapeSize.size / 2, shapeSize.size / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(shape)
      ..density = shapeSize.density
      ..friction = frictionOverride ?? GameConstants.shapeFriction
      ..restitution = GameConstants.shapeRestitution;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    ShapePainter.drawSquare(canvas, shapeSize);
  }
}
