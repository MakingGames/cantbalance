import 'package:flame_forge2d/flame_forge2d.dart';

class GameConstants {
  // World physics
  static final gravity = Vector2(0, 10.0);
  static const double zoom = 10.0; // 10 pixels per world unit

  // Scale beam
  static const double beamWidth = 25.0; // 250 pixels at zoom 10
  static const double beamHeight = 0.8;
  static const double beamDensity = 2.0; // Heavier beam for stability
  static const double beamFriction = 0.8;
  static const double beamRestitution = 0.1;

  // Shapes
  static const double squareSize = 1.5;
  static const double shapeDensity = 1.0;
  static const double shapeFriction = 0.8;
  static const double shapeRestitution = 0.1;

  // Tilt threshold (degrees)
  static const double tiltThreshold = 30.0;
}
