import 'package:flame_forge2d/flame_forge2d.dart';
import 'sandbox_challenges.dart';

class GameConstants {
  // World physics
  static final gravity = Vector2(0, SandboxChallenges.defaultGravity);
  static const double zoom = 10.0; // 10 pixels per world unit

  // Scale beam
  static const double beamWidth = 25.0; // 250 pixels at zoom 10
  static const double beamHeight = 0.8;
  static const double beamDensity = 2.0; // Heavier beam for stability
  static double get beamFriction => SandboxChallenges.defaultBeamFriction;
  static const double beamRestitution = 0.1;
  static double get beamAngularDamping => SandboxChallenges.defaultBeamDamping;

  // Settling detection - shapes considered settled when velocity below this
  static const double settlingVelocityThreshold = 0.5;

  // Shapes - three sizes with different weights
  static const double shapeSmallSize = 1.5;
  static const double shapeMediumSize = 2.2;
  static const double shapeLargeSize = 3.0;

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

  // Phone tilt settings (controls beam rotation) - from SandboxChallenges
  static double get tiltToAngleMultiplier => SandboxChallenges.defaultTiltSensitivity;
  static double get beamTiltTorqueStrength => SandboxChallenges.defaultTiltStrength;
  static const bool tiltInverted = true; // matches SandboxChallenges default

  // Progressive gravity settings - from SandboxChallenges
  static double get gravityStart => SandboxChallenges.defaultGravity;
  static const double gravityMax = 18.0; // maximum Y gravity
  static const double gravityIncreasePerShape = 0.5; // gravity increase per shape placed

  // Wind settings (Level 5+) - from SandboxChallenges
  static double get windGustIntervalMin => SandboxChallenges.windGustIntervalMin;
  static double get windGustIntervalMax => SandboxChallenges.windGustIntervalMax;
  static double get windForceMin => SandboxChallenges.baseWindForceMin;
  static double get windForceMax => SandboxChallenges.baseWindForceMax;
  static double get windGustDuration => SandboxChallenges.windGustDuration;
  static double get windWarningDuration => SandboxChallenges.windWarningDuration;

  // Beam instability settings (Level 6+)
  static const double beamSlipperyFriction = 0.3; // reduced friction when slippery

  // Time pressure settings (Level 7+)
  static const double placementTimeLimit = 8.0; // seconds to place a shape
  static const double placementTimeLimitMin = 4.0; // minimum time limit
  static const double placementTimeDecreasePerShape = 0.2; // gets faster
}
