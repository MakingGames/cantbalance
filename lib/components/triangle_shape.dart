import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/constants.dart';
import '../game/shape_size.dart';
import '../utils/shape_painter.dart';

class TriangleShape extends BodyComponent {
  final Vector2 initialPosition;
  final ShapeSize shapeSize;
  final double? frictionOverride;
  final double linearDamping;
  final double angularDamping;

  /// Tracks if this shape has ever had significant velocity (has fallen)
  bool hasHadVelocity = false;

  TriangleShape({
    required this.initialPosition,
    this.shapeSize = ShapeSize.medium,
    this.frictionOverride,
    this.linearDamping = 0.0,
    this.angularDamping = 0.0,
  });

  @override
  void update(double dt) {
    super.update(dt);
    // Mark as having had velocity once it starts moving
    if (!hasHadVelocity && body.linearVelocity.length > 1.0) {
      hasHadVelocity = true;
    }
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.dynamic,
      position: initialPosition,
      linearDamping: linearDamping,
      angularDamping: angularDamping,
    );

    final body = world.createBody(bodyDef);

    // Create equilateral triangle vertices
    final halfSize = shapeSize.size / 2;
    final height = halfSize * math.sqrt(3);

    final shape = PolygonShape()
      ..set([
        Vector2(0, -height / 2),           // Top
        Vector2(-halfSize, height / 2),    // Bottom left
        Vector2(halfSize, height / 2),     // Bottom right
      ]);

    // Use override or default (triangles are naturally more slippery)
    final baseFriction = frictionOverride ?? GameConstants.shapeFriction;
    final triangleFriction = frictionOverride != null ? baseFriction : baseFriction * 0.7;

    final fixtureDef = FixtureDef(shape)
      ..density = shapeSize.density * 0.9  // Slightly lighter (less stable)
      ..friction = triangleFriction
      ..restitution = GameConstants.shapeRestitution;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    ShapePainter.drawTriangle(canvas, shapeSize);
  }
}
