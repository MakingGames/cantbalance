import 'package:flutter/material.dart';
import '../utils/colors.dart';

class GameOverOverlay extends StatelessWidget {
  final double finalAngle;
  final int score;
  final int highScore;
  final bool isNewHighScore;
  final VoidCallback onRestart;
  final VoidCallback onMenu;

  const GameOverOverlay({
    super.key,
    required this.finalAngle,
    required this.score,
    required this.highScore,
    required this.isNewHighScore,
    required this.onRestart,
    required this.onMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'COLLAPSED',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w200,
                letterSpacing: 8,
                color: GameColors.beam,
              ),
            ),
            const SizedBox(height: 32),
            // Score display
            Text(
              '$score',
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.w100,
                color: GameColors.beam,
              ),
            ),
            Text(
              score == 1 ? 'SHAPE PLACED' : 'SHAPES PLACED',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                letterSpacing: 4,
                color: GameColors.beam.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            // High score indicator
            if (isNewHighScore)
              Text(
                'NEW BEST',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                  color: GameColors.accent,
                ),
              )
            else
              Text(
                'BEST: $highScore',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: GameColors.beam.withValues(alpha: 0.4),
                ),
              ),
            const SizedBox(height: 48),
            _OverlayButton(
              label: 'TRY AGAIN',
              onPressed: onRestart,
              isPrimary: true,
            ),
            const SizedBox(height: 16),
            _OverlayButton(
              label: 'MENU',
              onPressed: onMenu,
              isPrimary: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _OverlayButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _OverlayButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor:
              isPrimary ? GameColors.beam.withValues(alpha: 0.1) : Colors.transparent,
          side: BorderSide(
            color: isPrimary ? GameColors.beam : GameColors.beam.withValues(alpha: 0.4),
            width: isPrimary ? 2 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 3,
            color: isPrimary ? GameColors.beam : GameColors.beam.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
