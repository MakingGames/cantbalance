import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Compact HUD indicators for active mechanics during gameplay
class MechanicIndicators extends StatelessWidget {
  final bool hasWind;
  final bool hasGravity;
  final bool hasInstability;
  final bool hasTimer;
  final double? windDirection; // Positive = right, negative = left
  final double? gravityMultiplier;
  final double? timeRemaining;

  const MechanicIndicators({
    super.key,
    this.hasWind = false,
    this.hasGravity = false,
    this.hasInstability = false,
    this.hasTimer = false,
    this.windDirection,
    this.gravityMultiplier,
    this.timeRemaining,
  });

  @override
  Widget build(BuildContext context) {
    final indicators = <Widget>[];

    if (hasWind) {
      indicators.add(_WindIndicator(direction: windDirection ?? 1.0));
    }
    if (hasGravity) {
      indicators.add(_GravityIndicator(multiplier: gravityMultiplier ?? 1.5));
    }
    if (hasInstability) {
      indicators.add(const _InstabilityIndicator());
    }
    if (hasTimer && timeRemaining != null) {
      indicators.add(_TimerIndicator(timeRemaining: timeRemaining!));
    }

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < indicators.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          indicators[i],
        ],
      ],
    );
  }
}

/// Shows wind direction with animated chevrons
class _WindIndicator extends StatefulWidget {
  final double direction;

  const _WindIndicator({required this.direction});

  @override
  State<_WindIndicator> createState() => _WindIndicatorState();
}

class _WindIndicatorState extends State<_WindIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRight = widget.direction > 0;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final offset = _controller.value * 4 - 2;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: GameColors.beam.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Transform.translate(
            offset: Offset(offset * (isRight ? 1 : -1), 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.air,
                  size: 12,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 2),
                Transform.scale(
                  scaleX: isRight ? 1 : -1,
                  child: Icon(
                    Icons.double_arrow,
                    size: 10,
                    color: GameColors.beam.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shows gravity with downward arrows
class _GravityIndicator extends StatefulWidget {
  final double multiplier;

  const _GravityIndicator({required this.multiplier});

  @override
  State<_GravityIndicator> createState() => _GravityIndicatorState();
}

class _GravityIndicatorState extends State<_GravityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final offset = _controller.value * 3 - 1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: GameColors.beam.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Transform.translate(
            offset: Offset(0, offset),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_downward,
                  size: 12,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 2),
                Text(
                  '${widget.multiplier.toStringAsFixed(1)}x',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: GameColors.beam.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Shows beam instability with a wobbling icon
class _InstabilityIndicator extends StatefulWidget {
  const _InstabilityIndicator();

  @override
  State<_InstabilityIndicator> createState() => _InstabilityIndicatorState();
}

class _InstabilityIndicatorState extends State<_InstabilityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final rotation = (_controller.value - 0.5) * 0.15;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: GameColors.beam.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Transform.rotate(
            angle: rotation,
            child: Icon(
              Icons.vibration,
              size: 14,
              color: GameColors.beam.withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }
}

/// Timer countdown display
class _TimerIndicator extends StatelessWidget {
  final double timeRemaining;

  const _TimerIndicator({required this.timeRemaining});

  @override
  Widget build(BuildContext context) {
    final isLow = timeRemaining < 10;
    final color = isLow
        ? GameColors.beam.withValues(alpha: 0.8)
        : GameColors.beam.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLow
            ? GameColors.beam.withValues(alpha: 0.15)
            : GameColors.beam.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: isLow
            ? Border.all(color: GameColors.beam.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '${timeRemaining.toInt()}s',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
