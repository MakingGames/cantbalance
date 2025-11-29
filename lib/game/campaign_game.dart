import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../components/circle_shape.dart' show GameCircle;
import '../components/fulcrum.dart';
import '../components/ghost_shape.dart';
import '../components/scale_beam.dart';
import '../components/square_shape.dart';
import '../components/triangle_shape.dart';
import '../components/walls.dart';
import 'campaign_level.dart';
import 'constants.dart';
import 'shape_size.dart';
import 'shape_type.dart';

enum CampaignGameState { playing, won, lost }

/// Campaign mode: Discrete levels with specific win conditions
class CampaignGame extends Forge2DGame with DragCallbacks {
  late ScaleBeam scaleBeam;
  late Fulcrum fulcrum;
  late Body anchorBody;

  GhostShape? _ghostShape;
  double _beamY = 10.0;
  bool _isReady = false;

  CampaignGameState _gameState = CampaignGameState.playing;
  CampaignGameState get gameState => _gameState;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  void pause() => _isPaused = true;
  void resume() => _isPaused = false;

  int _score = 0;
  int get score => _score;

  // Height tracking for height-based levels
  double _currentHeight = 0;
  double get currentHeight => _currentHeight;

  ShapeSize _selectedShapeSize = ShapeSize.medium;
  ShapeSize get selectedShapeSize => _selectedShapeSize;

  // The campaign level being played
  final CampaignLevel level;

  // Auto-spawn state
  final Random _random = Random();
  double _gameTime = 0;
  double _timeSinceLastSpawn = 0;

  // Track last tilt value for gravity updates
  double _lastTiltX = 0;

  // Wind state
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

  // Time pressure state
  double _placementTimer = 0;
  bool _timePressureActive = false;

  /// Update beam tilt based on phone tilt (accelerometer)
  void updateBeamFromTilt(double tiltX) {
    if (!_isReady) return;
    _lastTiltX = tiltX;
    _applyBeamTorque();
  }

  /// Apply torque to beam to match phone tilt
  void _applyBeamTorque() {
    // Convert phone tilt to target angle (radians)
    final targetAngle = _lastTiltX * GameConstants.tiltToAngleMultiplier;
    final currentAngle = scaleBeam.body.angle;
    final angleDiff = targetAngle - currentAngle;

    // Apply torque proportional to angle difference
    final torque = angleDiff * GameConstants.beamTiltTorqueStrength;
    scaleBeam.body.applyTorque(torque);
  }

  // Callbacks
  void Function(int score)? onWin;
  void Function(double finalAngle, int score)? onLose;
  void Function(int score)? onScoreChanged;
  void Function(double angleDegrees)? onTiltChanged;
  void Function(double remainingTime, double totalTime)? onTimePressureChanged;
  void Function(bool isActive, bool isWarning, double direction)? onWindChanged;
  void Function(double currentHeight, double targetHeight)? onHeightChanged;
  VoidCallback? onShapePlaced;
  final VoidCallback? onExit;

  // Expose wind state for UI
  bool get isWindActive => _isWindActive;
  double get currentWindDirection => _currentWindForce > 0 ? 1.0 : (_currentWindForce < 0 ? -1.0 : 0);

  void selectShapeSize(ShapeSize size) {
    _selectedShapeSize = size;
  }

  CampaignGame({
    required this.level,
    this.onExit,
    this.onWin,
    this.onLose,
    this.onScoreChanged,
    this.onTiltChanged,
    this.onTimePressureChanged,
    this.onWindChanged,
    this.onHeightChanged,
    this.onShapePlaced,
  }) : super(
          gravity: Vector2(0, level.gravityY),
          zoom: GameConstants.zoom,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add invisible walls
    world.add(Walls(screenWidth: size.x, screenHeight: size.y));

    // Position beam in lower portion of screen
    _beamY = 10.0;
    final fulcrumY = _beamY + GameConstants.beamHeight / 2 + 1.5;

    // Add fulcrum (triangle support)
    fulcrum = Fulcrum(initialPosition: Vector2(0, fulcrumY));
    world.add(fulcrum);

    // Add scale beam
    scaleBeam = ScaleBeam(
      beamSize: Vector2(GameConstants.beamWidth, GameConstants.beamHeight),
      initialPosition: Vector2(0, _beamY),
    );
    world.add(scaleBeam);

    // Create pivot joint after beam body is ready
    scaleBeam.loaded.then((_) {
      _createPivotJoint(Vector2(0, _beamY));

      // Apply level-specific beam physics (uses defaults if not overridden)
      scaleBeam.setAngularDamping(level.beamDamping);
      scaleBeam.setFriction(level.beamFriction);

      // Activate time pressure if this level has it
      if (level.hasTimePressure) {
        _timePressureActive = true;
        _placementTimer = GameConstants.placementTimeLimit;
      }

      _isReady = true;
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
    // Check pause BEFORE updating physics
    if (_isPaused) return;

    super.update(dt);

    if (!_isReady || _gameState != CampaignGameState.playing) return;

    // Update timers
    _gameTime += dt;
    _timeSinceLastSpawn += dt;

    // Auto-spawn logic (if level has it, after grace period)
    if (level.hasAutoSpawn && _gameTime > GameConstants.autoSpawnStartDelay) {
      if (_timeSinceLastSpawn >= level.spawnInterval) {
        _spawnRandomShape();
        _timeSinceLastSpawn = 0;
      }
    }

    // Wind gust logic
    if (level.hasWind) {
      _updateWind(dt);
    }

    // Beam instability logic
    if (level.hasBeamInstability) {
      _updateBeamInstability(dt);
    }

    // Time pressure logic
    if (_timePressureActive) {
      _placementTimer -= dt;
      onTimePressureChanged?.call(_placementTimer, GameConstants.placementTimeLimit);
      if (_placementTimer <= 0) {
        _triggerLoss(currentTiltDegrees);
        return;
      }
    }

    // Check tilt angle (radians to degrees) for UI indicator
    final angleRadians = scaleBeam.body.angle;
    final angleDegrees = angleRadians * 180 / pi;
    onTiltChanged?.call(angleDegrees);

    // Check if any shapes have fallen below the floor threshold
    _checkForFallenShapes();

    // Track height and check win condition
    _currentHeight = _calculateCurrentHeight();
    onHeightChanged?.call(_currentHeight, level.targetHeight);

    // Check win condition
    if (_currentHeight >= level.targetHeight) {
      _checkWinCondition();
    }
  }

  void _checkForFallenShapes() {
    for (final child in world.children) {
      if (child is SquareShape) {
        if (child.body.position.y > GameConstants.floorThreshold) {
          _triggerLoss(currentTiltDegrees);
          return;
        }
      } else if (child is GameCircle) {
        if (child.body.position.y > GameConstants.floorThreshold) {
          _triggerLoss(currentTiltDegrees);
          return;
        }
      } else if (child is TriangleShape) {
        if (child.body.position.y > GameConstants.floorThreshold) {
          _triggerLoss(currentTiltDegrees);
          return;
        }
      }
    }
  }

  void _spawnRandomShape() {
    // Random x position within beam bounds (with some margin)
    final beamHalfWidth = GameConstants.beamWidth / 2 - 2;
    final x = _random.nextDouble() * beamHalfWidth * 2 - beamHalfWidth;

    // Spawn from top of screen
    final y = -15.0;

    // Random size
    final sizes = ShapeSize.values;
    final randomSize = sizes[_random.nextInt(sizes.length)];

    // Random shape type (if level supports variety)
    if (level.hasShapeVariety) {
      final shapeTypes = GameShapeType.values;
      final randomType = shapeTypes[_random.nextInt(shapeTypes.length)];
      _addShape(randomType, Vector2(x, y), randomSize);
    } else {
      world.add(SquareShape(
        initialPosition: Vector2(x, y),
        shapeSize: randomSize,
      ));
    }
  }

  void _addShape(GameShapeType type, Vector2 position, ShapeSize size) {
    switch (type) {
      case GameShapeType.square:
        world.add(SquareShape(initialPosition: position, shapeSize: size));
      case GameShapeType.circle:
        world.add(GameCircle(initialPosition: position, shapeSize: size));
      case GameShapeType.triangle:
        world.add(TriangleShape(initialPosition: position, shapeSize: size));
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
        onWindChanged?.call(false, false, 0);
        // Set next gust interval
        _nextGustInterval = GameConstants.windGustIntervalMin +
            _random.nextDouble() *
                (GameConstants.windGustIntervalMax - GameConstants.windGustIntervalMin);
      }
    } else if (_isWindWarning) {
      // Warning phase - count down then start wind
      _windWarningTimer -= dt;
      if (_windWarningTimer <= 0) {
        _isWindWarning = false;
        _isWindActive = true;
        _windGustTimer = GameConstants.windGustDuration;
        _currentWindForce = _pendingWindForce;
        onWindChanged?.call(true, false, _pendingWindDirection);
      }
    } else {
      // Wait for next gust
      _timeSinceLastGust += dt;
      if (_timeSinceLastGust >= _nextGustInterval) {
        // Start warning phase
        _isWindWarning = true;
        _timeSinceLastGust = 0;
        _windWarningTimer = GameConstants.windWarningDuration;

        // Pre-calculate direction and force for after warning
        _pendingWindDirection = _random.nextBool() ? 1.0 : -1.0;
        final forceMagnitude = GameConstants.windForceMin +
            _random.nextDouble() *
                (GameConstants.windForceMax - GameConstants.windForceMin);
        _pendingWindForce = _pendingWindDirection * forceMagnitude;

        // Show warning indicator via callback
        onWindChanged?.call(false, true, _pendingWindDirection);
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

  void _triggerLoss(double finalAngle) {
    _gameState = CampaignGameState.lost;

    // Cancel any active drag
    if (_ghostShape != null) {
      _ghostShape!.removeFromParent();
      _ghostShape = null;
    }

    // Notify listener
    onLose?.call(finalAngle, _score);
  }

  void _checkWinCondition() {
    // Check height-based win condition
    if (_currentHeight >= level.targetHeight) {
      // Check if all shapes have settled (low velocity)
      if (!_areShapesSettled()) {
        return; // Wait for shapes to settle before declaring win
      }

      _gameState = CampaignGameState.won;

      // Cancel any active drag
      if (_ghostShape != null) {
        _ghostShape!.removeFromParent();
        _ghostShape = null;
      }

      // Notify listener
      onWin?.call(_score);
    }
  }

  /// Check if all shapes on the beam have settled (velocity below threshold)
  bool _areShapesSettled() {
    for (final child in world.children) {
      if (child is SquareShape) {
        if (child.body.linearVelocity.length > GameConstants.settlingVelocityThreshold) {
          return false;
        }
      } else if (child is GameCircle) {
        if (child.body.linearVelocity.length > GameConstants.settlingVelocityThreshold) {
          return false;
        }
      } else if (child is TriangleShape) {
        if (child.body.linearVelocity.length > GameConstants.settlingVelocityThreshold) {
          return false;
        }
      }
    }
    return true;
  }

  /// Calculate current stack height (distance from beam surface to top of highest shape)
  double _calculateCurrentHeight() {
    // Beam surface is at _beamY - beamHeight/2 (top of beam)
    final beamSurface = _beamY - GameConstants.beamHeight / 2;
    double highestPoint = beamSurface; // Start at beam surface (no height)

    for (final child in world.children) {
      double shapeTop = beamSurface;

      if (child is SquareShape) {
        // Top of square = center.y - half size
        shapeTop = child.body.position.y - child.shapeSize.size / 2;
      } else if (child is GameCircle) {
        // Top of circle = center.y - radius
        shapeTop = child.body.position.y - child.shapeSize.size / 2;
      } else if (child is TriangleShape) {
        // Top of triangle = center.y - half height (approximate)
        shapeTop = child.body.position.y - child.shapeSize.size / 2;
      }

      // Lower y = higher position (y increases downward)
      if (shapeTop < highestPoint) {
        highestPoint = shapeTop;
      }
    }

    // Height = distance from beam surface to highest point
    // beamSurface - highestPoint gives positive height when shapes are stacked
    return (beamSurface - highestPoint).clamp(0.0, double.infinity);
  }

  /// Get current tilt angle in degrees
  double get currentTiltDegrees {
    if (!_isReady) return 0;
    return scaleBeam.body.angle * 180 / pi;
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_gameState != CampaignGameState.playing) return;
    super.onDragStart(event);

    final worldPosition = screenToWorld(event.localPosition);

    // Only allow placement above the beam
    if (worldPosition.y < _beamY - GameConstants.beamHeight) {
      _ghostShape = GhostShape(
        position: worldPosition,
        shapeSize: _selectedShapeSize,
      );
      world.add(_ghostShape!);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_gameState != CampaignGameState.playing) return;
    super.onDragUpdate(event);

    if (_ghostShape != null) {
      final worldPosition = screenToWorld(event.localEndPosition);

      // Restrict ghost to above the beam
      if (worldPosition.y < _beamY - GameConstants.beamHeight) {
        _ghostShape!.position = worldPosition;
      } else {
        // Clamp to minimum height above beam
        _ghostShape!.position = Vector2(
          worldPosition.x,
          _beamY - GameConstants.beamHeight - _selectedShapeSize.size / 2,
        );
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_gameState != CampaignGameState.playing) return;
    super.onDragEnd(event);

    if (_ghostShape != null) {
      // Spawn actual shape at ghost position
      final position = _ghostShape!.position.clone();
      world.add(SquareShape(
        initialPosition: position,
        shapeSize: _selectedShapeSize,
      ));

      // Increment score
      _score++;
      onScoreChanged?.call(_score);
      onShapePlaced?.call();

      // Reset time pressure timer if active
      if (_timePressureActive) {
        _placementTimer = GameConstants.placementTimeLimit;
      }

      // Check win condition
      _checkWinCondition();

      // Remove ghost
      _ghostShape!.removeFromParent();
      _ghostShape = null;
    }
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);

    // Remove ghost without placing
    if (_ghostShape != null) {
      _ghostShape!.removeFromParent();
      _ghostShape = null;
    }
  }
}
