import 'dart:ui';

import 'package:flame/components.dart';
import '../game/shape_size.dart';

/// A non-physics preview shape that shows where the piece will be placed.
class GhostShape extends PositionComponent {
  final ShapeSize shapeSize;

  GhostShape({
    required Vector2 position,
    this.shapeSize = ShapeSize.medium,
  }) : super(
          position: position,
          size: Vector2.all(shapeSize.size),
          anchor: Anchor.center,
        );

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: shapeSize.size,
      height: shapeSize.size,
    );

    // Draw outline only (ghost effect)
    final paint = Paint()
      ..color = shapeSize.color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.1;

    canvas.drawRect(rect, paint);

    // Draw semi-transparent fill
    final fillPaint = Paint()
      ..color = shapeSize.color.withValues(alpha: 0.2);

    canvas.drawRect(rect, fillPaint);
  }
}
