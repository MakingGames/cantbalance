import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TiltIndicator extends StatelessWidget {
  final double angleDegrees;
  final double threshold;

  const TiltIndicator({
    super.key,
    required this.angleDegrees,
    this.threshold = 30.0,
  });

  /// Returns a color from green (safe) to yellow (warning) to red (danger)
  Color get _indicatorColor {
    final absAngle = angleDegrees.abs();

    // Percentage toward threshold (0 = level, 1 = at threshold)
    final danger = (absAngle / threshold).clamp(0.0, 1.0);

    if (danger < 0.5) {
      // Safe zone: beam color
      return GameColors.beam.withValues(alpha: 0.4);
    } else if (danger < 0.75) {
      // Warning zone: accent/gold
      return GameColors.beam.withValues(alpha: 0.7);
    } else {
      // Danger zone: red
      return GameColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: CustomPaint(
        painter: _TiltPainter(
          angleDegrees: angleDegrees,
          color: _indicatorColor,
        ),
      ),
    );
  }
}

class _TiltPainter extends CustomPainter {
  final double angleDegrees;
  final Color color;

  _TiltPainter({
    required this.angleDegrees,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw outer circle
    final circlePaint = Paint()
      ..color = GameColors.beam.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, circlePaint);

    // Draw tilt line
    final angleRadians = angleDegrees * pi / 180;
    final lineLength = radius - 4;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw a horizontal line that rotates with the tilt
    final leftPoint = Offset(
      center.dx - lineLength * cos(angleRadians),
      center.dy + lineLength * sin(angleRadians),
    );
    final rightPoint = Offset(
      center.dx + lineLength * cos(angleRadians),
      center.dy - lineLength * sin(angleRadians),
    );

    canvas.drawLine(leftPoint, rightPoint, linePaint);

    // Draw center pivot point
    final pivotPaint = Paint()..color = color;
    canvas.drawCircle(center, 4, pivotPaint);
  }

  @override
  bool shouldRepaint(_TiltPainter oldDelegate) {
    return oldDelegate.angleDegrees != angleDegrees || oldDelegate.color != color;
  }
}
