import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../components/circle_shape.dart' show GameCircle;
import '../components/fulcrum.dart';
import '../components/scale_beam.dart';
import '../components/square_shape.dart';
import '../components/triangle_shape.dart';
import '../components/walls.dart';
import '../components/wind_indicator.dart';
import 'constants.dart';
import 'sandbox_challenges.dart';
import 'shape_type.dart';

/// Sandbox mode: Tap anywhere to spawn shapes freely.
/// No rules, no end state - just play with physics.
/// Now with optional challenge toggles for testing.
class SandboxGame extends Forge2DGame with TapCallbacks {
  late ScaleBeam scaleBeam;
  late Fulcrum fulcrum;
  late Body anchorBody;
  WindIndicator? _windIndicator;

  final VoidCallback? onExit;

  // Challenge settings
  SandboxChallenges _challenges = SandboxChallenges();
  SandboxChallenges get challenges => _challenges;

  // Tilt control state
  double _lastTiltX = 0;

  // Wind state
  final Random _random = Random();
  double _timeSinceLastGust = 0;
  double _nextGustInterval = 3.0;
  double _currentWindForce = 0;
  double _windGustTimer = 0;
  bool _isWindActive = false;
  bool _isWindWarning = false;
  double _windWarningTimer = 0;
  double _pendingWindDirection = 0;
  double _pendingWindForce = 0;

  // Beam instability state
  double _beamNudgeTimer = 0;
  double _nextNudgeInterval = 2.0;

  SandboxGame({this.onExit})
      : super(
          gravity: Vector2(0, GameConstants.gravityStart),
          zoom: GameConstants.zoom,
        );

  void updateChallenges(SandboxChallenges newChallenges) {
    final previousChallenges = _challenges;
    _challenges = newChallenges;

    // Update gravity when toggle or slider changes
    if (newChallenges.heavyGravity != previousChallenges.heavyGravity ||
        newChallenges.gravityMultiplier != previousChallenges.gravityMultiplier) {
      final gravity = newChallenges.heavyGravity
          ? newChallenges.gravityMultiplier
          : SandboxChallenges.defaultGravity;
      world.gravity = Vector2(0, gravity);
    }

    // Update beam friction when toggle or slider changes
    if (newChallenges.slipperyBeam != previousChallenges.slipperyBeam ||
        newChallenges.beamFriction != previousChallenges.beamFriction) {
      final friction = newChallenges.slipperyBeam
          ? newChallenges.beamFriction
          : SandboxChallenges.defaultBeamFriction;
      scaleBeam.setFriction(friction);
    }

    // Update beam damping when tilt control toggle or damping slider changes
    if (newChallenges.tiltControl != previousChallenges.tiltControl ||
        newChallenges.beamDamping != previousChallenges.beamDamping) {
      final damping = newChallenges.tiltControl
          ? newChallenges.beamDamping
          : SandboxChallenges.defaultBeamDamping;
      scaleBeam.setAngularDamping(damping);
    }
  }

  /// Update beam tilt based on phone tilt (accelerometer)
  void updateBeamFromTilt(double tiltX) {
    _lastTiltX = tiltX;
    if (_challenges.tiltControl) {
      _applyBeamTorque();
    }
  }

  void _applyBeamTorque() {
    final tiltDirection = _challenges.tiltInverted ? -1.0 : 1.0;
    final targetAngle = _lastTiltX * _challenges.tiltSensitivity * tiltDirection;
    final currentAngle = scaleBeam.body.angle;
    final angleDiff = targetAngle - currentAngle;
    final torque = angleDiff * _challenges.tiltStrength;
    scaleBeam.body.applyTorque(torque);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add invisible walls
    world.add(Walls(screenWidth: size.x, screenHeight: size.y));

    // Add wind indicator (always present in sandbox, controlled by setWind)
    // Use viewport size (screen pixels) not world size
    final screenSize = camera.viewport.size;
    _windIndicator = WindIndicator(
      position: Vector2.zero(),
      size: screenSize,
    );
    camera.viewport.add(_windIndicator!);

    // Position beam in lower portion of screen
    const beamY = 10.0;
    const fulcrumY = beamY + GameConstants.beamHeight / 2 + 1.5;

    // Add fulcrum (triangle support)
    fulcrum = Fulcrum(initialPosition: Vector2(0, fulcrumY));
    world.add(fulcrum);

    // Add scale beam
    scaleBeam = ScaleBeam(
      beamSize: Vector2(GameConstants.beamWidth, GameConstants.beamHeight),
      initialPosition: Vector2(0, beamY),
    );
    world.add(scaleBeam);

    // Create pivot joint after beam body is ready
    scaleBeam.loaded.then((_) {
      _createPivotJoint(Vector2(0, beamY));
    });
  }

  void _createPivotJoint(Vector2 pivotPoint) {
    final anchorDef = BodyDef(
      type: BodyType.static,
      position: pivotPoint,
    );
    anchorBody = world.createBody(anchorDef);

    final jointDef = RevoluteJointDef()
      ..initialize(anchorBody, scaleBeam.body, pivotPoint)
      ..enableLimit = false
      ..enableMotor = false;

    world.createJoint(RevoluteJoint(jointDef));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Apply tilt torque continuously if enabled
    if (_challenges.tiltControl) {
      _applyBeamTorque();
    }

    // Wind gust logic
    if (_challenges.windGusts) {
      _updateWind(dt);
    }

    // Beam instability logic
    if (_challenges.beamInstability) {
      _updateBeamInstability(dt);
    }
  }

  void _updateWind(double dt) {
    if (_isWindActive) {
      // Apply wind force to all shapes
      for (final child in world.children) {
        if (child is SquareShape) {
          child.body.applyForce(Vector2(_currentWindForce, 0));
        } else if (child is GameCircle) {
          child.body.applyForce(Vector2(_currentWindForce, 0));
        } else if (child is TriangleShape) {
          child.body.applyForce(Vector2(_currentWindForce, 0));
        }
      }

      // Count down gust timer
      _windGustTimer -= dt;
      if (_windGustTimer <= 0) {
        _isWindActive = false;
        _currentWindForce = 0;
        _windIndicator?.setWind(0, false);
        // Set next gust interval
        _nextGustInterval = SandboxChallenges.windGustIntervalMin +
            _random.nextDouble() *
                (SandboxChallenges.windGustIntervalMax - SandboxChallenges.windGustIntervalMin);
      }
    } else if (_isWindWarning) {
      // Warning phase - count down then start wind
      _windWarningTimer -= dt;
      if (_windWarningTimer <= 0) {
        _isWindWarning = false;
        _isWindActive = true;
        _windGustTimer = SandboxChallenges.windGustDuration;
        _currentWindForce = _pendingWindForce;
        _windIndicator?.setWind(_currentWindForce, true);
      }
    } else {
      // Wait for next gust
      _timeSinceLastGust += dt;
      if (_timeSinceLastGust >= _nextGustInterval) {
        // Start warning phase
        _isWindWarning = true;
        _timeSinceLastGust = 0;
        _windWarningTimer = SandboxChallenges.windWarningDuration;

        // Pre-calculate direction and force for after warning
        _pendingWindDirection = _random.nextBool() ? 1.0 : -1.0;
        final forceMagnitude = _challenges.windForceMin +
            _random.nextDouble() *
                (_challenges.windForceMax - _challenges.windForceMin);
        _pendingWindForce = _pendingWindDirection * forceMagnitude;

        // Show warning indicator
        _windIndicator?.setWarning(_pendingWindDirection);
      }
    }
  }

  void _updateBeamInstability(double dt) {
    _beamNudgeTimer += dt;
    if (_beamNudgeTimer >= _nextNudgeInterval) {
      _beamNudgeTimer = 0;
      // Random interval for next nudge (1-3 seconds)
      _nextNudgeInterval = 1.0 + _random.nextDouble() * 2.0;

      // Apply a small random torque to the beam
      final torqueDirection = _random.nextBool() ? 1.0 : -1.0;
      final torqueMagnitude = 50.0 + _random.nextDouble() * 100.0;
      scaleBeam.body.applyTorque(torqueDirection * torqueMagnitude);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // Spawn a shape at tap position
    final worldPosition = screenToWorld(event.localPosition);

    if (_challenges.shapeVariety) {
      // Random shape type
      final shapeTypes = GameShapeType.values;
      final randomType = shapeTypes[_random.nextInt(shapeTypes.length)];
      _addShape(randomType, worldPosition);
    } else {
      world.add(SquareShape(initialPosition: worldPosition));
    }
  }

  void _addShape(GameShapeType type, Vector2 position) {
    switch (type) {
      case GameShapeType.square:
        world.add(SquareShape(initialPosition: position));
      case GameShapeType.circle:
        world.add(GameCircle(initialPosition: position));
      case GameShapeType.triangle:
        world.add(TriangleShape(initialPosition: position));
    }
  }
}
