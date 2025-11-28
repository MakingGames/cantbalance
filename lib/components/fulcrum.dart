import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../utils/colors.dart';
import '../utils/shape_painter.dart';

class Fulcrum extends BodyComponent {
  final Vector2 initialPosition;
  final double baseWidth;
  final double height;

  Fulcrum({
    required this.initialPosition,
    this.baseWidth = 3.0,
    this.height = 2.0,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: initialPosition,
    );

    final body = world.createBody(bodyDef);

    // Create triangle shape for the fulcrum
    final vertices = [
      Vector2(-baseWidth / 2, height / 2), // bottom left
      Vector2(baseWidth / 2, height / 2), // bottom right
      Vector2(0, -height / 2), // top center
    ];

    final shape = PolygonShape()..set(vertices);

    final fixtureDef = FixtureDef(shape)
      ..friction = 0.8
      ..restitution = 0.0;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    ShapePainter.drawFulcrum(canvas, baseWidth, height, GameColors.fulcrum);
  }
}
