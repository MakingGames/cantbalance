import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../components/fulcrum.dart';
import '../components/ghost_shape.dart';
import '../components/scale_beam.dart';
import '../components/square_shape.dart';
import '../components/walls.dart';
import 'constants.dart';
import 'game_level.dart';
import 'shape_size.dart';

enum GameState { playing, gameOver }

/// Challenge mode: The proper game with placement control,
/// tilt threshold, and collapse mechanics.
class ChallengeGame extends Forge2DGame with DragCallbacks {
  late ScaleBeam scaleBeam;
  late Fulcrum fulcrum;
  late Body anchorBody;

  GhostShape? _ghostShape;
  double _beamY = 10.0;
  bool _isReady = false;

  GameState _gameState = GameState.playing;
  GameState get gameState => _gameState;

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

  // Track last tilt value for gravity updates
  double _lastTiltX = 0;

  /// Update gravity based on phone tilt (accelerometer)
  void updateGravityFromTilt(double tiltX) {
    _lastTiltX = tiltX;
    _updateGravity();
  }

  /// Recalculate gravity with current tilt and progressive Y component
  void _updateGravity() {
    final horizontalGravity = _lastTiltX * GameConstants.tiltGravityMultiplier;
    world.gravity = Vector2(horizontalGravity, _currentGravityY);
  }

  /// Check if score crosses a level threshold
  void _checkLevelChange() {
    final newLevel = GameLevel.fromScore(_score);
    if (newLevel != _currentLevel) {
      _currentLevel = newLevel;
      onLevelChanged?.call(newLevel);
    }
  }

  // Callbacks
  void Function(double finalAngle, int score)? onGameOver;
  void Function(int score)? onScoreChanged;
  void Function(double angleDegrees)? onTiltChanged;
  void Function(GameLevel level)? onLevelChanged;
  VoidCallback? onShapePlaced;
  final VoidCallback? onExit;

  void selectShapeSize(ShapeSize size) {
    _selectedShapeSize = size;
  }

  ChallengeGame({this.onExit, this.onGameOver, this.onScoreChanged, this.onTiltChanged, this.onLevelChanged, this.onShapePlaced})
      : super(
          gravity: GameConstants.gravity,
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

    // Check tilt angle (radians to degrees)
    final angleRadians = scaleBeam.body.angle;
    final angleDegrees = angleRadians * 180 / pi;

    // Notify listeners of tilt change
    onTiltChanged?.call(angleDegrees);

    if (angleDegrees.abs() > GameConstants.tiltThreshold) {
      _triggerGameOver(angleDegrees);
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

    world.add(SquareShape(
      initialPosition: Vector2(x, y),
      shapeSize: randomSize,
    ));
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
