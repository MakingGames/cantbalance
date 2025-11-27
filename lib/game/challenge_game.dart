import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../components/fulcrum.dart';
import '../components/ghost_shape.dart';
import '../components/scale_beam.dart';
import '../components/square_shape.dart';
import '../components/walls.dart';
import 'constants.dart';

/// Challenge mode: The proper game with placement control,
/// tilt threshold, and collapse mechanics.
class ChallengeGame extends Forge2DGame with DragCallbacks {
  late ScaleBeam scaleBeam;
  late Fulcrum fulcrum;
  late Body anchorBody;

  GhostShape? _ghostShape;
  double _beamY = 10.0;

  final VoidCallback? onExit;

  ChallengeGame({this.onExit})
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
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);

    final worldPosition = screenToWorld(event.localPosition);

    // Only allow placement above the beam
    if (worldPosition.y < _beamY - GameConstants.beamHeight) {
      _ghostShape = GhostShape(position: worldPosition);
      world.add(_ghostShape!);
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
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
          _beamY - GameConstants.beamHeight - GameConstants.squareSize / 2,
        );
      }
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);

    if (_ghostShape != null) {
      // Spawn actual shape at ghost position
      final position = _ghostShape!.position.clone();
      world.add(SquareShape(initialPosition: position));

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
