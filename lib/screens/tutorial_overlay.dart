import 'package:flutter/material.dart';
import '../utils/colors.dart';

class TutorialOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const TutorialOverlay({
    super.key,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: GameColors.background.withValues(alpha: 0.9),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Hand/tap icon pointing down
              Icon(
                Icons.touch_app,
                size: 64,
                color: GameColors.beam.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 24),
              // Main instruction
              Text(
                'DRAG ABOVE THE BEAM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'TO DROP SHAPES',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 32),
              // Secondary instruction
              Text(
                'KEEP THE BALANCE',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TILT YOUR PHONE TO SHIFT GRAVITY',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 64),
              // Tap to continue
              Text(
                'TAP TO START',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3,
                  color: GameColors.beam.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
