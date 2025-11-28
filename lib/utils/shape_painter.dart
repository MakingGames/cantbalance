import 'dart:math' as math;

import 'package:flutter/painting.dart';

import '../game/shape_size.dart';

/// Utility class for rendering shapes with subtle depth effects
class ShapePainter {
  // Corner radius for rounded rectangles
  static const double _cornerRadius = 0.15;
  static const double _beamCornerRadius = 0.08;

  /// Creates a gradient paint with subtle depth (lighter top-left, darker bottom-right)
  static Paint _createGradientPaint(Color baseColor, Rect bounds) {
    // Extract HSL values to create subtle variations
    final hsl = HSLColor.fromColor(baseColor);

    // Lighter version for top-left highlight
    final lightColor = hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();

    // Darker version for bottom-right shadow
    final darkColor = hsl.withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0)).toColor();

    return Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1, -1),
        end: const Alignment(1, 1),
        colors: [lightColor, baseColor, darkColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(bounds);
  }

  /// Creates a subtle highlight paint for top edge
  static Paint _createHighlightPaint(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    final highlightColor = hsl.withLightness((hsl.lightness + 0.2).clamp(0.0, 1.0)).toColor();
    return Paint()
      ..color = highlightColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.08;
  }

  /// Draw a square with subtle depth
  static void drawSquare(Canvas canvas, ShapeSize shapeSize) {
    final halfSize = shapeSize.size / 2;
    final radius = halfSize * _cornerRadius;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: shapeSize.size, height: shapeSize.size),
      Radius.circular(radius),
    );

    // Main gradient fill
    final gradientPaint = _createGradientPaint(
      shapeSize.color,
      Rect.fromCenter(center: Offset.zero, width: shapeSize.size, height: shapeSize.size),
    );
    canvas.drawRRect(rect, gradientPaint);

    // Subtle top-left highlight edge
    final highlightPaint = _createHighlightPaint(shapeSize.color);
    final highlightPath = Path()
      ..moveTo(-halfSize + radius, -halfSize)
      ..lineTo(halfSize - radius, -halfSize)
      ..arcToPoint(
        Offset(halfSize, -halfSize + radius),
        radius: Radius.circular(radius),
      );
    canvas.drawPath(highlightPath, highlightPaint);
  }

  /// Draw a circle with subtle depth
  static void drawCircle(Canvas canvas, ShapeSize shapeSize) {
    final radius = shapeSize.size / 2;

    // Main gradient fill (radial for circles)
    final hsl = HSLColor.fromColor(shapeSize.color);
    final lightColor = hsl.withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0)).toColor();
    final darkColor = hsl.withLightness((hsl.lightness - 0.08).clamp(0.0, 1.0)).toColor();

    final gradientPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 1.2,
        colors: [lightColor, shapeSize.color, darkColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius));

    canvas.drawCircle(Offset.zero, radius, gradientPaint);

    // Subtle highlight arc on top-left
    final highlightPaint = _createHighlightPaint(shapeSize.color);
    final highlightRect = Rect.fromCircle(center: Offset.zero, radius: radius - 0.04);
    canvas.drawArc(highlightRect, -math.pi * 0.8, math.pi * 0.5, false, highlightPaint);
  }

  /// Draw a triangle with subtle depth
  static void drawTriangle(Canvas canvas, ShapeSize shapeSize) {
    final halfSize = shapeSize.size / 2;
    final height = halfSize * math.sqrt(3);

    // Triangle vertices
    final top = Offset(0, -height / 2);
    final bottomLeft = Offset(-halfSize, height / 2);
    final bottomRight = Offset(halfSize, height / 2);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    // Main gradient fill
    final bounds = Rect.fromPoints(
      Offset(-halfSize, -height / 2),
      Offset(halfSize, height / 2),
    );
    final gradientPaint = _createGradientPaint(shapeSize.color, bounds);
    canvas.drawPath(path, gradientPaint);

    // Subtle highlight on top-left edge
    final highlightPaint = _createHighlightPaint(shapeSize.color);
    final highlightPath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  /// Draw a beam (wide rectangle) with subtle depth
  static void drawBeam(Canvas canvas, double width, double height, Color color) {
    final radius = height * _beamCornerRadius;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: width, height: height),
      Radius.circular(radius),
    );

    // Main gradient fill (top to bottom for beam)
    final hsl = HSLColor.fromColor(color);
    final lightColor = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final darkColor = hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0)).toColor();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightColor, color, darkColor],
        stops: const [0.0, 0.4, 1.0],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: width, height: height));

    canvas.drawRRect(rect, gradientPaint);

    // Subtle top highlight
    final highlightPaint = Paint()
      ..color = lightColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.06;

    final halfWidth = width / 2;
    final halfHeight = height / 2;
    final highlightPath = Path()
      ..moveTo(-halfWidth + radius, -halfHeight)
      ..lineTo(halfWidth - radius, -halfHeight);
    canvas.drawPath(highlightPath, highlightPaint);
  }

  /// Draw a fulcrum (triangle pointing up) with subtle depth
  static void drawFulcrum(Canvas canvas, double baseWidth, double height, Color color) {
    // Triangle vertices (pointing up)
    final halfBase = baseWidth / 2;
    final halfHeight = height / 2;
    final top = Offset(0, -halfHeight);
    final bottomLeft = Offset(-halfBase, halfHeight);
    final bottomRight = Offset(halfBase, halfHeight);

    final path = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();

    // Main gradient fill
    final hsl = HSLColor.fromColor(color);
    final lightColor = hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
    final darkColor = hsl.withLightness((hsl.lightness - 0.06).clamp(0.0, 1.0)).toColor();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [lightColor, color, darkColor],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromPoints(
        Offset(-halfBase, -halfHeight),
        Offset(halfBase, halfHeight),
      ));

    canvas.drawPath(path, gradientPaint);

    // Subtle highlight on top edges
    final highlightPaint = Paint()
      ..color = lightColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.06;

    final highlightPath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(top.dx, top.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy);
    canvas.drawPath(highlightPath, highlightPaint);
  }
}
