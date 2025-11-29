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
import 'systems/beam_instability_system.dart';
import 'systems/wind_system.dart';

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

  // Random for shape spawning
  final Random _random = Random();

  // Wind system
  late WindSystem _windSystem;

  // Beam instability system
  late BeamInstabilitySystem _beamInstabilitySystem;

  SandboxGame({this.onExit})
      : super(
          gravity: Vector2(0, GameConstants.gravityStart),
          zoom: GameConstants.zoom,
        ) {
    // Initialize wind system with sandbox-specific timing and callbacks
    _windSystem = WindSystem(
      gustIntervalMin: SandboxChallenges.windGustIntervalMin,
      gustIntervalMax: SandboxChallenges.windGustIntervalMax,
      gustDuration: SandboxChallenges.windGustDuration,
      warningDuration: SandboxChallenges.windWarningDuration,
      forceMin: SandboxChallenges.baseWindForceMin,
      forceMax: SandboxChallenges.baseWindForceMax,
      onWindChanged: (force, isActive) {
        _windIndicator?.setWind(force, isActive);
      },
      onWindWarning: (direction) {
        _windIndicator?.setWarning(direction);
      },
    );

    // Initialize beam instability system
    _beamInstabilitySystem = BeamInstabilitySystem();
  }

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

    // Update wind strength when slider changes
    if (newChallenges.windStrength != previousChallenges.windStrength) {
      _windSystem.windStrengthMultiplier = newChallenges.windStrength;
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
    // Collect all shape bodies for wind to act upon
    final shapeBodies = <Body>[];
    for (final child in world.children) {
      if (child is SquareShape) {
        shapeBodies.add(child.body);
      } else if (child is GameCircle) {
        shapeBodies.add(child.body);
      } else if (child is TriangleShape) {
        shapeBodies.add(child.body);
      }
    }
    _windSystem.update(dt, shapeBodies);
  }

  void _updateBeamInstability(double dt) {
    _beamInstabilitySystem.update(dt, scaleBeam.body);
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
