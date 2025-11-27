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

  // Callbacks
  void Function(double finalAngle, int score)? onGameOver;
  void Function(int score)? onScoreChanged;
  void Function(double angleDegrees)? onTiltChanged;
  final VoidCallback? onExit;

  void selectShapeSize(ShapeSize size) {
    _selectedShapeSize = size;
  }

  ChallengeGame({this.onExit, this.onGameOver, this.onScoreChanged, this.onTiltChanged})
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

    // Check tilt angle (radians to degrees)
    final angleRadians = scaleBeam.body.angle;
    final angleDegrees = angleRadians * 180 / pi;

    // Notify listeners of tilt change
    onTiltChanged?.call(angleDegrees);

    if (angleDegrees.abs() > GameConstants.tiltThreshold) {
      _triggerGameOver(angleDegrees);
    }
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

      // Increment score
      _score++;
      onScoreChanged?.call(_score);

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
