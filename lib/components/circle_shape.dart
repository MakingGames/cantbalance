import 'dart:ui';

import 'package:flame_forge2d/flame_forge2d.dart' hide CircleShape;
import 'package:forge2d/forge2d.dart' as forge2d;
import '../game/constants.dart';
import '../game/shape_size.dart';
import '../utils/shape_painter.dart';

class GameCircle extends BodyComponent {
  final Vector2 initialPosition;
  final ShapeSize shapeSize;
  final double? frictionOverride;
  final double linearDamping;
  final double angularDamping;

  /// Tracks if this shape has ever had significant velocity (has fallen)
  bool hasHadVelocity = false;

  GameCircle({
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

    final shape = forge2d.CircleShape()..radius = shapeSize.size / 2;

    final fixtureDef = FixtureDef(shape)
      ..density = shapeSize.density
      ..friction = frictionOverride ?? GameConstants.shapeFriction
      ..restitution = GameConstants.shapeRestitution;

    body.createFixture(fixtureDef);

    return body;
  }

  @override
  void render(Canvas canvas) {
    ShapePainter.drawCircle(canvas, shapeSize);
  }
}
