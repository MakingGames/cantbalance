import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import '../components/fulcrum.dart';
import '../components/scale_beam.dart';
import '../components/square_shape.dart';
import '../components/walls.dart';
import 'constants.dart';

class BalanceGame extends Forge2DGame with TapCallbacks {
  late ScaleBeam scaleBeam;
  late Fulcrum fulcrum;
  late Body anchorBody;

  BalanceGame()
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
    // Create a static anchor body at the pivot point
    final anchorDef = BodyDef(
      type: BodyType.static,
      position: pivotPoint,
    );
    anchorBody = world.createBody(anchorDef);

    // Create revolute joint connecting the anchor to the beam
    final jointDef = RevoluteJointDef()
      ..initialize(anchorBody, scaleBeam.body, pivotPoint)
      ..enableLimit = false
      ..enableMotor = false;

    world.createJoint(RevoluteJoint(jointDef));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    // Convert screen position to world position
    final worldPosition = screenToWorld(event.localPosition);

    // Spawn a square at the tap position
    world.add(SquareShape(initialPosition: worldPosition));
  }
}
