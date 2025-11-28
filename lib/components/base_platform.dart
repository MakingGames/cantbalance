import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../utils/colors.dart';
import '../utils/shape_painter.dart';

class BasePlatform extends BodyComponent {
  final Vector2 initialPosition;
  final double width;
  final double height;

  BasePlatform({
    required this.initialPosition,
    this.width = 24.0,
    this.height = 1.0,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: initialPosition,
    );

    final body = world.createBody(bodyDef);

    final shape = PolygonShape()
      ..setAsBox(width / 2, height / 2, Vector2.zero(), 0);

    final fixtureDef = FixtureDef(shape)
      ..friction = 0.8
      ..restitution = 0.1;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    ShapePainter.drawBeam(canvas, width, height, GameColors.beam);
  }
}
