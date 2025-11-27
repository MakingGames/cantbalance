import 'dart:ui';

import 'package:flame/components.dart';
import '../game/constants.dart';
import '../utils/colors.dart';

/// A non-physics preview shape that shows where the piece will be placed.
class GhostShape extends PositionComponent {
  final double shapeSize;

  GhostShape({
    required Vector2 position,
    this.shapeSize = GameConstants.squareSize,
  }) : super(
          position: position,
          size: Vector2.all(shapeSize),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeSize,
      height: shapeSize,
    );

    // Draw outline only (ghost effect)
    final paint = Paint()
      ..color = GameColors.shapeMedium.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1;

    canvas.drawRect(rect, paint);

    // Draw semi-transparent fill
    final fillPaint = Paint()
      ..color = GameColors.shapeMedium.withValues(alpha: 0.2);

    canvas.drawRect(rect, fillPaint);
  }
}
