import 'dart:math';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../components/base_platform.dart';
import '../components/circle_shape.dart' show GameCircle;
import '../components/ghost_shape.dart';
import '../components/square_shape.dart';
import '../components/triangle_shape.dart';
import 'constants.dart';
import 'shape_size.dart';
import 'shape_type.dart';
import 'stacking_physics.dart';
import 'systems/spatial_hash.dart';

enum StackingGameState { playing, gameOver }

/// Stacking mode: No fulcrum, just stack infinitely upward.
/// Camera follows the stack as it grows.
class StackingGame extends Forge2DGame with DragCallbacks {
  GhostShape? _ghostShape;
  bool _isReady = false;

  StackingGameState _gameState = StackingGameState.playing;
  StackingGameState get gameState => _gameState;

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  void pause() => _isPaused = true;
  void resume() => _isPaused = false;

  int _score = 0;
  int get score => _score;

  double _highestPoint = 0;
  double get highestPoint => _highestPoint;

  ShapeSize _selectedShapeSize = ShapeSize.medium;
  ShapeSize get selectedShapeSize => _selectedShapeSize;

  // Next shape preview
  late GameShapeType _nextShapeType;
  GameShapeType get nextShapeType => _nextShapeType;
  final Random _random = Random();

  // Physics settings for test mode
  StackingPhysics _physics = StackingPhysics();
  StackingPhysics get physics => _physics;

  // Spatial hash for efficient proximity queries in magnetic attraction
  // Cell size matches attraction range for optimal performance
  final SpatialHash _spatialHash = SpatialHash(
    cellSize: StackingPhysics.attractionRange,
  );

  void updatePhysics(StackingPhysics newPhysics) {
    _physics = newPhysics;
  }

  // Base platform position
  late double _baseY;

  // Camera tracking
  double _targetCameraY = 0;
  static const double _cameraSmoothing = 0.05;
  static const double _cameraLeadDistance = 8.0; // How far ahead to look
  static const double _minStackHeightForCameraMove = 5.0; // Min stack height before camera moves

  // Left/right boundaries for game over detection
  static const double _boundaryX = 15.0;

  // Callbacks
  void Function(int score)? onGameOver;
  void Function(int score)? onScoreChanged;
  void Function(double height)? onHeightChanged;
  void Function(GameShapeType nextShape)? onNextShapeChanged;
  VoidCallback? onShapePlaced;
  final VoidCallback? onExit;

  void selectShapeSize(ShapeSize size) {
    _selectedShapeSize = size;
  }

  StackingGame({
    this.onExit,
    this.onGameOver,
    this.onScoreChanged,
    this.onHeightChanged,
    this.onNextShapeChanged,
    this.onShapePlaced,
  }) : super(
          gravity: Vector2(0, GameConstants.gravityStart),
          zoom: GameConstants.zoom,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Position base platform at bottom of screen
    _baseY = 10.0;

    // Initialize highest point to base level
    _highestPoint = _baseY;

    // Create the visible base platform
    _createBasePlatform();

    // Create invisible walls on left and right
    _createWalls();

    // Initialize camera to show base platform
    _targetCameraY = _baseY - 8.0;
    camera.viewfinder.position = Vector2(0, _targetCameraY);

    // Generate first next shape
    _generateNextShape();

    _isReady = true;
  }

  void _generateNextShape() {
    final shapeTypes = GameShapeType.values;
    _nextShapeType = shapeTypes[_random.nextInt(shapeTypes.length)];
    onNextShapeChanged?.call(_nextShapeType);
  }

  void _createBasePlatform() {
    // Add visible base platform component
    world.add(BasePlatform(
      initialPosition: Vector2(0, _baseY),
      width: 20.0,
      height: 1.0,
    ));
  }

  void _createWalls() {
    // Left wall
    final leftWallDef = BodyDef(
      type: BodyType.static,
      position: Vector2(-_boundaryX, 0),
    );
    final leftWall = world.createBody(leftWallDef);
    final leftShape = PolygonShape()..setAsBox(0.5, 100, Vector2.zero(), 0);
    leftWall.createFixture(FixtureDef(leftShape)..friction = 0.3);

    // Right wall
    final rightWallDef = BodyDef(
      type: BodyType.static,
      position: Vector2(_boundaryX, 0),
    );
    final rightWall = world.createBody(rightWallDef);
    final rightShape = PolygonShape()..setAsBox(0.5, 100, Vector2.zero(), 0);
    rightWall.createFixture(FixtureDef(rightShape)..friction = 0.3);
  }

  @override
  void update(double dt) {
    if (_isPaused) return;

    super.update(dt);

    if (!_isReady || _gameState != StackingGameState.playing) return;

    // Track highest point and update camera
    _updateHighestPoint();
    _updateCamera(dt);

    // Apply magnetic attraction if enabled
    if (_physics.magneticAttraction) {
      _applyMagneticAttraction();
    }

    // Check for fallen shapes (below base platform)
    _checkForFallenShapes();
  }

  void _applyMagneticAttraction() {
    // Clear and rebuild spatial hash each frame
    _spatialHash.clear();

    // Collect all shape bodies and insert into spatial hash
    final bodies = <Body>[];
    for (final child in world.children) {
      Body? body;
      if (child is SquareShape) {
        body = child.body;
      } else if (child is GameCircle) {
        body = child.body;
      } else if (child is TriangleShape) {
        body = child.body;
      }
      if (body != null) {
        bodies.add(body);
        _spatialHash.insert(body);
      }
    }

    // Track processed pairs to avoid duplicate force application
    final processed = <int>{};

    // For each body, only check nearby bodies from spatial hash
    // This reduces O(n²) to O(n*k) where k is avg bodies per cell region
    for (final bodyA in bodies) {
      final hashA = identityHashCode(bodyA);

      for (final bodyB in _spatialHash.getNearby(bodyA.position)) {
        // Skip self and already-processed pairs
        if (identical(bodyA, bodyB)) continue;

        final hashB = identityHashCode(bodyB);
        final pairKey = hashA < hashB ? hashA ^ hashB : hashB ^ hashA;
        if (processed.contains(pairKey)) continue;
        processed.add(pairKey);

        final diff = bodyB.position - bodyA.position;
        final distance = diff.length;

        // Only attract if within range
        if (distance < StackingPhysics.attractionRange && distance > 0.1) {
          final direction = diff.normalized();
          final force = direction *
              StackingPhysics.attractionForce *
              (1 - distance / StackingPhysics.attractionRange);

          bodyA.applyForce(force);
          bodyB.applyForce(-force);
        }
      }
    }
  }

  void _updateHighestPoint() {
    double highest = _baseY;

    for (final child in world.children) {
      double shapeTop = _baseY;

      if (child is SquareShape) {
        shapeTop = child.body.position.y - child.shapeSize.size / 2;
      } else if (child is GameCircle) {
        shapeTop = child.body.position.y - child.shapeSize.size / 2;
      } else if (child is TriangleShape) {
        shapeTop = child.body.position.y - child.shapeSize.size / 2;
      }

      if (shapeTop < highest) {
        highest = shapeTop;
      }
    }

    if (highest < _highestPoint) {
      _highestPoint = highest;
      // Convert to positive height for display
      final displayHeight = (_baseY - _highestPoint).abs();
      onHeightChanged?.call(displayHeight);
    }
  }

  void _updateCamera(double dt) {
    // Calculate current stack height
    final stackHeight = _baseY - _highestPoint;

    // Only start moving camera when stack is tall enough
    if (stackHeight < _minStackHeightForCameraMove) {
      return;
    }

    // Target camera to show the top of the stack with some lead room
    final targetY = _highestPoint - _cameraLeadDistance;

    // Only move camera up, never down
    if (targetY < _targetCameraY) {
      _targetCameraY = targetY;
    }

    // Smooth camera movement
    final currentY = camera.viewfinder.position.y;
    final newY = currentY + (_targetCameraY - currentY) * _cameraSmoothing;
    camera.viewfinder.position = Vector2(0, newY);
  }

  void _checkForFallenShapes() {
    // Check if any shape has fallen below the base platform
    final threshold = _baseY + 5.0;

    for (final child in world.children) {
      double shapeY = 0;

      if (child is SquareShape) {
        shapeY = child.body.position.y;
      } else if (child is GameCircle) {
        shapeY = child.body.position.y;
      } else if (child is TriangleShape) {
        shapeY = child.body.position.y;
      }

      if (shapeY > threshold) {
        _triggerGameOver();
        return;
      }
    }
  }

  void _triggerGameOver() {
    _gameState = StackingGameState.gameOver;

    // Cancel any active drag
    if (_ghostShape != null) {
      _ghostShape!.removeFromParent();
      _ghostShape = null;
    }

    // Notify listener
    onGameOver?.call(_score);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (_gameState != StackingGameState.playing) return;
    super.onDragStart(event);

    final worldPosition = screenToWorld(event.localPosition);

    // Allow placement anywhere above the base platform
    if (worldPosition.y < _baseY) {
      _ghostShape = GhostShape(
        position: worldPosition,
        shapeSize: _selectedShapeSize,
      );
      world.add(_ghostShape!);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_gameState != StackingGameState.playing) return;
    super.onDragUpdate(event);

    if (_ghostShape != null) {
      final worldPosition = screenToWorld(event.localEndPosition);

      // Clamp X to within boundaries
      final clampedX = worldPosition.x.clamp(-_boundaryX + 2, _boundaryX - 2);

      _ghostShape!.position = Vector2(clampedX, worldPosition.y);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    if (_gameState != StackingGameState.playing) return;
    super.onDragEnd(event);

    if (_ghostShape != null) {
      // Spawn actual shape at ghost position using the pre-determined next shape
      final position = _ghostShape!.position.clone();

      // Get physics overrides
      final friction = (_physics.highFriction || _physics.stickyContacts) ? _physics.friction : null;
      final linearDamping = _physics.linearDamping;
      final angularDamping = _physics.angularDamping;

      switch (_nextShapeType) {
        case GameShapeType.square:
          world.add(SquareShape(
            initialPosition: position,
            shapeSize: _selectedShapeSize,
            frictionOverride: friction,
            linearDamping: linearDamping,
            angularDamping: angularDamping,
          ));
        case GameShapeType.circle:
          world.add(GameCircle(
            initialPosition: position,
            shapeSize: _selectedShapeSize,
            frictionOverride: friction,
            linearDamping: linearDamping,
            angularDamping: angularDamping,
          ));
        case GameShapeType.triangle:
          world.add(TriangleShape(
            initialPosition: position,
            shapeSize: _selectedShapeSize,
            frictionOverride: friction,
            linearDamping: linearDamping,
            angularDamping: angularDamping,
          ));
      }

      // Increment score
      _score++;
      onScoreChanged?.call(_score);
      onShapePlaced?.call();

      // Generate the next shape for preview
      _generateNextShape();

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
