import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../utils/colors.dart';

/// Weather vane style wind direction indicator
/// Shows at top of screen, smoothly fades in during warning and active phases
class WindIndicator extends PositionComponent {
  double _windDirection = 0; // -1 = left, 0 = none, 1 = right
  double _targetAlpha = 0; // Target opacity
  double _currentAlpha = 0; // Current opacity (for smooth transitions)
  double _arrowAngle = 0; // Current arrow rotation
  double _targetAngle = 0; // Target arrow rotation
  bool _isWarning = false;

  static const double _fadeSpeed = 3.0; // How fast to fade in/out
  static const double _rotateSpeed = 8.0; // How fast arrow rotates

  WindIndicator({
    super.position,
    super.size,
    super.priority = 100,
  });

  /// Update the wind force and activation state
  void setWind(double force, bool isActive) {
    if (isActive && force.abs() > 0.01) {
      _windDirection = force > 0 ? 1.0 : -1.0;
      _targetAlpha = 0.8;
      _targetAngle = _windDirection > 0 ? 0 : pi; // Point right or left (horizontal)
      _isWarning = false;
    } else {
      _targetAlpha = 0;
    }
  }

  /// Show warning indicator before wind hits
  void setWarning(double direction) {
    _windDirection = direction;
    _targetAlpha = 0.4; // Dimmer during warning
    _targetAngle = direction > 0 ? 0 : pi;
    _isWarning = true;
  }

  /// Clear warning state
  void clearWarning() {
    _isWarning = false;
    _targetAlpha = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smoothly interpolate alpha
    if (_currentAlpha < _targetAlpha) {
      _currentAlpha = (_currentAlpha + _fadeSpeed * dt).clamp(0.0, _targetAlpha);
    } else if (_currentAlpha > _targetAlpha) {
      _currentAlpha = (_currentAlpha - _fadeSpeed * dt).clamp(_targetAlpha, 1.0);
    }

    // Smoothly rotate arrow
    final angleDiff = _targetAngle - _arrowAngle;
    if (angleDiff.abs() > 0.01) {
      _arrowAngle += angleDiff * _rotateSpeed * dt;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_currentAlpha < 0.01) return;

    // Position on left side, well below back button row
    const leftX = 32.0;
    const topY = 160.0;

    // Draw minimal wind arrow
    _drawWindArrow(canvas, leftX, topY);
  }

  void _drawWindArrow(Canvas canvas, double centerX, double centerY) {
    final paint = Paint()
      ..color = GameColors.beam.withValues(alpha: _currentAlpha * 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(centerX, centerY);
    canvas.rotate(_arrowAngle);

    // Simple horizontal arrow - just a line with chevron head
    const lineLength = 20.0;
    const headSize = 6.0;

    // Line
    canvas.drawLine(
      const Offset(-lineLength / 2, 0),
      Offset(lineLength / 2 - 2, 0),
      paint,
    );

    // Chevron arrow head (two lines forming a V)
    canvas.drawLine(
      Offset(lineLength / 2, 0),
      Offset(lineLength / 2 - headSize, -headSize * 0.6),
      paint,
    );
    canvas.drawLine(
      Offset(lineLength / 2, 0),
      Offset(lineLength / 2 - headSize, headSize * 0.6),
      paint,
    );

    canvas.restore();

    // Subtle pulsing dot during warning
    if (_isWarning && _currentAlpha > 0.1) {
      final pulseAlpha = (sin(DateTime.now().millisecondsSinceEpoch / 400) * 0.3 + 0.4)
          .clamp(0.1, 0.7);
      final dotPaint = Paint()
        ..color = GameColors.beam.withValues(alpha: pulseAlpha * _currentAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(centerX, centerY), 2.5, dotPaint);
    }
  }
}

/// Compact wind direction indicator for HUD overlay (Flutter widget version)
class WindDirectionIndicator extends StatelessWidget {
  final double windForce;

  const WindDirectionIndicator({
    super.key,
    required this.windForce,
  });

  @override
  Widget build(BuildContext context) {
    if (windForce.abs() < 0.1) {
      return const SizedBox.shrink();
    }

    final direction = windForce > 0 ? 1.0 : -1.0;
    final strength = windForce.abs().clamp(0.0, 2.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.air,
          size: 14,
          color: GameColors.beam.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        // Wind arrows based on direction and strength
        for (int i = 0; i < (strength * 2).ceil().clamp(1, 3); i++)
          Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Transform.scale(
              scaleX: direction,
              child: Icon(
                Icons.chevron_right,
                size: 12,
                color: GameColors.beam.withValues(alpha: 0.3 + i * 0.1),
              ),
            ),
          ),
      ],
    );
  }
}

/// Wind state for the HUD indicator
enum WindState { inactive, warning, active }

/// Animated wind indicator for the HUD (Flutter widget with animations)
/// Replaces the Flame-based WindIndicator for consistent HUD layout
class AnimatedWindIndicator extends StatefulWidget {
  final WindState state;
  final double direction; // -1 = left, 1 = right

  const AnimatedWindIndicator({
    super.key,
    required this.state,
    required this.direction,
  });

  @override
  State<AnimatedWindIndicator> createState() => _AnimatedWindIndicatorState();
}

class _AnimatedWindIndicatorState extends State<AnimatedWindIndicator>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _updateAnimation();
  }

  @override
  void didUpdateWidget(AnimatedWindIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _updateAnimation();
    }
  }

  void _updateAnimation() {
    switch (widget.state) {
      case WindState.inactive:
        _fadeController.reverse();
        _pulseController.stop();
        break;
      case WindState.warning:
        _fadeController.forward();
        _pulseController.repeat(reverse: true);
        break;
      case WindState.active:
        _fadeController.forward();
        _pulseController.stop();
        break;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeAnimation, _pulseAnimation]),
      builder: (context, child) {
        if (_fadeAnimation.value < 0.01) {
          return const SizedBox.shrink();
        }

        final baseAlpha = widget.state == WindState.warning
            ? _pulseAnimation.value
            : (widget.state == WindState.active ? 0.8 : 0.0);
        final alpha = baseAlpha * _fadeAnimation.value;

        return CustomPaint(
          size: const Size(40, 24),
          painter: _WindArrowPainter(
            direction: widget.direction,
            alpha: alpha,
            isWarning: widget.state == WindState.warning,
            pulseValue: _pulseAnimation.value,
          ),
        );
      },
    );
  }
}

class _WindArrowPainter extends CustomPainter {
  final double direction;
  final double alpha;
  final bool isWarning;
  final double pulseValue;

  _WindArrowPainter({
    required this.direction,
    required this.alpha,
    required this.isWarning,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (alpha < 0.01) return;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final paint = Paint()
      ..color = GameColors.beam.withValues(alpha: alpha * 0.6)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(centerX, centerY);

    // Rotate based on direction
    if (direction < 0) {
      canvas.rotate(pi);
    }

    // Simple horizontal arrow - just a line with chevron head
    const lineLength = 20.0;
    const headSize = 6.0;

    // Line
    canvas.drawLine(
      const Offset(-lineLength / 2, 0),
      const Offset(lineLength / 2 - 2, 0),
      paint,
    );

    // Chevron arrow head (two lines forming a V)
    canvas.drawLine(
      const Offset(lineLength / 2, 0),
      const Offset(lineLength / 2 - headSize, -headSize * 0.6),
      paint,
    );
    canvas.drawLine(
      const Offset(lineLength / 2, 0),
      const Offset(lineLength / 2 - headSize, headSize * 0.6),
      paint,
    );

    canvas.restore();

    // Subtle pulsing dot during warning
    if (isWarning && alpha > 0.1) {
      final dotPaint = Paint()
        ..color = GameColors.beam.withValues(alpha: pulseValue * alpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(centerX, centerY), 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_WindArrowPainter oldDelegate) {
    return oldDelegate.direction != direction ||
        oldDelegate.alpha != alpha ||
        oldDelegate.isWarning != isWarning ||
        oldDelegate.pulseValue != pulseValue;
  }
}
