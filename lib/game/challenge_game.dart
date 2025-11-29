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
import '../components/wind_indicator.dart';
import 'constants.dart';
import 'game_level.dart';
import 'shape_size.dart';
import 'shape_type.dart';
import 'systems/beam_instability_system.dart';
import 'systems/wind_system.dart';

enum GameState { playing, gameOver }

/// Challenge mode: The proper game with placement control,
/// tilt threshold, and collapse mechanics.
class ChallengeGame extends Forge2DGame with DragCallbacks {
  late ScaleBeam scaleBeam;
  late Fulcrum fulcrum;
  late Body anchorBody;
  WindIndicator? _windIndicator;

  GhostShape? _ghostShape;
  double _beamY = 10.0;
  bool _isReady = false;

  GameState _gameState = GameState.playing;
  GameState get gameState => _gameState;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  void pause() => _isPaused = true;
  void resume() => _isPaused = false;

  int _score = 0;
  int get score => _score;

  ShapeSize _selectedShapeSize = ShapeSize.medium;
  ShapeSize get selectedShapeSize => _selectedShapeSize;

  // Level tracking
  GameLevel _currentLevel = GameLevel.basics;
  GameLevel get currentLevel => _currentLevel;

  // Auto-spawn state
  final Random _random = Random();
  double _gameTime = 0;
  double _timeSinceLastSpawn = 0;

  /// Current spawn interval based on score (gets faster within auto-spawn levels)
  double get _currentSpawnInterval {
    if (!_currentLevel.hasAutoSpawn) return double.infinity;
    // Calculate shapes placed since auto-spawn started
    final shapesInAutoSpawn = _score - GameLevel.autoSpawn.minScore;
    final decrease = shapesInAutoSpawn * GameConstants.autoSpawnIntervalDecreasePerShape;
    return (GameConstants.autoSpawnIntervalStart - decrease)
        .clamp(GameConstants.autoSpawnIntervalMin, GameConstants.autoSpawnIntervalStart);
  }

  /// Current Y gravity based on level (only increases in gravity+ levels)
  double get _currentGravityY {
    if (!_currentLevel.hasIncreasedGravity) return GameConstants.gravityStart;
    // Calculate shapes placed since gravity started
    final shapesInGravity = _score - GameLevel.gravity.minScore;
    final increase = shapesInGravity * GameConstants.gravityIncreasePerShape;
    return (GameConstants.gravityStart + increase)
        .clamp(GameConstants.gravityStart, GameConstants.gravityMax);
  }

  /// Current time limit for placement (decreases progressively in time pressure level)
  double get _currentTimeLimit {
    if (!_currentLevel.hasTimePressure) return double.infinity;
    final shapesInTimePressure = _score - GameLevel.timePressure.minScore;
    final decrease = shapesInTimePressure * GameConstants.placementTimeDecreasePerShape;
    return (GameConstants.placementTimeLimit - decrease)
        .clamp(GameConstants.placementTimeLimitMin, GameConstants.placementTimeLimit);
  }

  /// Remaining time for placement (0 if time pressure not active)
  double get remainingPlacementTime => _timePressureActive ? _placementTimer : 0;

  // Track last tilt value for gravity updates
  double _lastTiltX = 0;

  // Wind system (Level 5+)
  late WindSystem _windSystem;

  // Beam instability system (Level 6+)
  late BeamInstabilitySystem _beamInstabilitySystem;

  // Time pressure state (Level 7+)
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
    // tiltX is roughly -10 to +10, convert to reasonable angle
    final tiltDirection = GameConstants.tiltInverted ? -1.0 : 1.0;
    final targetAngle = _lastTiltX * GameConstants.tiltToAngleMultiplier * tiltDirection;
    final currentAngle = scaleBeam.body.angle;
    final angleDiff = targetAngle - currentAngle;

    // Apply torque proportional to angle difference
    final torque = angleDiff * GameConstants.beamTiltTorqueStrength;
    scaleBeam.body.applyTorque(torque);
  }

  /// Update gravity for progressive difficulty (Y component only)
  void _updateGravity() {
    world.gravity = Vector2(0, _currentGravityY);
  }

  /// Check if score crosses a level threshold
  void _checkLevelChange() {
    final newLevel = GameLevel.fromScore(_score);
    if (newLevel != _currentLevel) {
      final previousLevel = _currentLevel;
      _currentLevel = newLevel;

      // Apply slippery beam when entering instability level
      if (newLevel.hasBeamInstability && !previousLevel.hasBeamInstability) {
        scaleBeam.setFriction(GameConstants.beamSlipperyFriction);
      }

      // Activate time pressure when entering that level
      if (newLevel.hasTimePressure && !previousLevel.hasTimePressure) {
        _timePressureActive = true;
        _placementTimer = _currentTimeLimit;
      }

      onLevelChanged?.call(newLevel);
    }
  }

  // Callbacks
  void Function(double finalAngle, int score)? onGameOver;
  void Function(int score)? onScoreChanged;
  void Function(double angleDegrees)? onTiltChanged;
  void Function(GameLevel level)? onLevelChanged;
  void Function(double remainingTime, double totalTime)? onTimePressureChanged;
  VoidCallback? onShapePlaced;
  final VoidCallback? onExit;

  void selectShapeSize(ShapeSize size) {
    _selectedShapeSize = size;
  }

  ChallengeGame({this.onExit, this.onGameOver, this.onScoreChanged, this.onTiltChanged, this.onLevelChanged, this.onTimePressureChanged, this.onShapePlaced})
      : super(
          gravity: GameConstants.gravity,
          zoom: GameConstants.zoom,
        ) {
    // Initialize wind system with callbacks for UI updates
    _windSystem = WindSystem(
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

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add invisible walls
    world.add(Walls(screenWidth: size.x, screenHeight: size.y));

    // Add wind indicator (always present, controlled by setWind)
    // Use viewport size (screen pixels) not world size
    final screenSize = camera.viewport.size;
    _windIndicator = WindIndicator(
      position: Vector2.zero(),
      size: screenSize,
    );
    add(_windIndicator!);

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

    if (!_isReady || _gameState != GameState.playing) return;

    // Update timers
    _gameTime += dt;
    _timeSinceLastSpawn += dt;

    // Auto-spawn logic (only in levels with auto-spawn, after grace period)
    if (_currentLevel.hasAutoSpawn && _gameTime > GameConstants.autoSpawnStartDelay) {
      if (_timeSinceLastSpawn >= _currentSpawnInterval) {
        _spawnRandomShape();
        _timeSinceLastSpawn = 0;
      }
    }

    // Wind gust logic (Level 5+)
    if (_currentLevel.hasWind) {
      _updateWind(dt);
    }

    // Beam instability logic (Level 6+)
    if (_currentLevel.hasBeamInstability) {
      _updateBeamInstability(dt);
    }

    // Time pressure logic (Level 7+)
    if (_timePressureActive) {
      _placementTimer -= dt;
      onTimePressureChanged?.call(_placementTimer, _currentTimeLimit);
      if (_placementTimer <= 0) {
        _triggerGameOver(currentTiltDegrees);
        return;
      }
    }

    // Check tilt angle (radians to degrees) for UI indicator
    final angleRadians = scaleBeam.body.angle;
    final angleDegrees = angleRadians * 180 / pi;
    onTiltChanged?.call(angleDegrees);

    // Check if any shapes have fallen below the floor threshold
    _checkForFallenShapes();
  }

  void _checkForFallenShapes() {
    for (final child in world.children) {
      if (child is SquareShape) {
        if (child.body.position.y > GameConstants.floorThreshold) {
          _triggerGameOver(currentTiltDegrees);
          return;
        }
      } else if (child is GameCircle) {
        if (child.body.position.y > GameConstants.floorThreshold) {
          _triggerGameOver(currentTiltDegrees);
          return;
        }
      } else if (child is TriangleShape) {
        if (child.body.position.y > GameConstants.floorThreshold) {
          _triggerGameOver(currentTiltDegrees);
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
    if (_currentLevel.hasShapeVariety) {
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

  void _triggerGameOver(double finalAngle) {
    _gameState = GameState.gameOver;

    // Cancel any active drag
    if (_ghostShape != null) {
      _ghostShape!.removeFromParent();
      _ghostShape = null;
    }

    // Notify listener
    onGameOver?.call(finalAngle, _score);
  }

  /// Get current tilt angle in degrees
  double get currentTiltDegrees {
    if (!_isReady) return 0;
    return scaleBeam.body.angle * 180 / pi;
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_gameState != GameState.playing) return;
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
    if (_gameState != GameState.playing) return;
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
    if (_gameState != GameState.playing) return;
    super.onDragEnd(event);

    if (_ghostShape != null) {
      // Spawn actual shape at ghost position
      final position = _ghostShape!.position.clone();
      world.add(SquareShape(
        initialPosition: position,
        shapeSize: _selectedShapeSize,
      ));

      // Increment score and check for level change
      _score++;
      _checkLevelChange();
      _updateGravity();
      onScoreChanged?.call(_score);
      onShapePlaced?.call();

      // Reset time pressure timer if active
      if (_timePressureActive) {
        _placementTimer = _currentTimeLimit;
      }

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
