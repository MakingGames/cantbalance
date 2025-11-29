import 'dart:ui';

import 'package:flame/components.dart';
import '../utils/colors.dart';

/// A visual marker that shows the current stack height as a horizontal line.
/// Updates in real-time as blocks move, providing visual feedback to the player.
class HeightMarker extends PositionComponent {
  /// The width of the line in world units (should span the game area)
  final double lineWidth;

  /// Optional target height to show as a second line (for campaign mode)
  double? targetHeight;

  /// Whether the marker is currently visible
  bool isVisible = true;

  HeightMarker({
    this.lineWidth = 50.0,
    this.targetHeight,
    super.position,
    super.priority = -1, // Render behind other components
  });

  /// Updates the marker's Y position based on the current height.
  /// In Flame's coordinate system, negative Y is up.
  void updateHeight(double height) {
    // Position Y is negative because height increases upward
    // The base (height = 0) starts at Y = beamY (around 10.0)
    // So we need to offset from the base position
    position.y = -height;
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    // Draw current height line - simple horizontal line
    final paint = Paint()
      ..color = GameColors.beam.withValues(alpha: 0.3)
      ..strokeWidth = 0.05
      ..style = PaintingStyle.stroke;

    // Line spans full width centered at current position
    canvas.drawLine(
      Offset(-lineWidth / 2, 0),
      Offset(lineWidth / 2, 0),
      paint,
    );

    // Draw target height line if set (for campaign mode)
    if (targetHeight != null && targetHeight! > 0) {
      final targetPaint = Paint()
        ..color = GameColors.accent.withValues(alpha: 0.2)
        ..strokeWidth = 0.08
        ..style = PaintingStyle.stroke;

      // Target line is at a fixed Y relative to this component
      // Since this component moves with current height,
      // the target line offset = targetHeight - currentHeight
      // But we want target at absolute position, so we draw it
      // relative to where this marker currently is
      final targetY = -(targetHeight! - (-position.y));
      canvas.drawLine(
        Offset(-lineWidth / 2, targetY),
        Offset(lineWidth / 2, targetY),
        targetPaint,
      );
    }
  }
}
