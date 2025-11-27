import 'package:flame_forge2d/flame_forge2d.dart';

class Walls extends BodyComponent {
  final double screenWidth;
  final double screenHeight;

  Walls({required this.screenWidth, required this.screenHeight});

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      type: BodyType.static,
      position: Vector2.zero(),
    );

    final body = world.createBody(bodyDef);

    // Convert screen size to world coordinates
    final worldWidth = screenWidth / game.camera.viewfinder.zoom;
    final worldHeight = screenHeight / game.camera.viewfinder.zoom;

    // Wall thickness
    const thickness = 1.0;

    // Left wall
    final leftWall = EdgeShape()
      ..set(
        Vector2(-worldWidth / 2 - thickness, -worldHeight),
        Vector2(-worldWidth / 2 - thickness, worldHeight),
      );
    body.createFixtureFromShape(leftWall);

    // Right wall
    final rightWall = EdgeShape()
      ..set(
        Vector2(worldWidth / 2 + thickness, -worldHeight),
        Vector2(worldWidth / 2 + thickness, worldHeight),
      );
    body.createFixtureFromShape(rightWall);

    // Bottom wall
    final bottomWall = EdgeShape()
      ..set(
        Vector2(-worldWidth, worldHeight / 2 + thickness),
        Vector2(worldWidth, worldHeight / 2 + thickness),
      );
    body.createFixtureFromShape(bottomWall);

    return body;
  }
}
