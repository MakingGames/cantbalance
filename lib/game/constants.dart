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

  // Shapes - three sizes with different weights
  static const double shapeSmallSize = 1.0;
  static const double shapeMediumSize = 1.5;
  static const double shapeLargeSize = 2.2;

  static const double shapeSmallDensity = 0.8;
  static const double shapeMediumDensity = 1.0;
  static const double shapeLargeDensity = 1.3;

  static const double shapeFriction = 0.8;
  static const double shapeRestitution = 0.1;

  // Legacy - for backwards compatibility
  static const double squareSize = shapeMediumSize;
  static const double shapeDensity = shapeMediumDensity;

  // Tilt threshold (degrees) - for UI indicator only
  static const double tiltThreshold = 30.0;

  // Floor threshold - shapes hitting the bottom of screen trigger game over
  // Let them fall and give player time to react/stack more
  static const double floorThreshold = 38.0;

  // Auto-spawn settings (progressive difficulty)
  static const double autoSpawnIntervalStart = 5.0; // seconds between spawns
  static const double autoSpawnIntervalMin = 1.5; // minimum interval
  static const double autoSpawnIntervalDecreasePerShape = 0.3; // faster each shape
  static const double autoSpawnStartDelay = 3.0; // grace period before first spawn

  // Phone tilt settings (controls beam rotation)
  static const double tiltToAngleMultiplier = 0.05; // convert accelerometer to radians
  static const double beamTiltTorqueStrength = 200.0; // torque applied to match tilt

  // Progressive gravity settings
  static const double gravityStart = 10.0; // starting Y gravity
  static const double gravityMax = 18.0; // maximum Y gravity
  static const double gravityIncreasePerShape = 0.5; // gravity increase per shape placed

  // Wind settings (Level 5+)
  static const double windGustIntervalMin = 2.0; // minimum seconds between gusts
  static const double windGustIntervalMax = 5.0; // maximum seconds between gusts
  static const double windForceMin = 15.0; // minimum horizontal force
  static const double windForceMax = 40.0; // maximum horizontal force
  static const double windGustDuration = 0.8; // how long each gust lasts

  // Beam instability settings (Level 6+)
  static const double beamSlipperyFriction = 0.3; // reduced friction when slippery

  // Time pressure settings (Level 7+)
  static const double placementTimeLimit = 8.0; // seconds to place a shape
  static const double placementTimeLimitMin = 4.0; // minimum time limit
  static const double placementTimeDecreasePerShape = 0.2; // gets faster
}
