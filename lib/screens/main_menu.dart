import 'package:flutter/material.dart';
import '../utils/colors.dart';

class MainMenu extends StatelessWidget {
  final VoidCallback onSandboxPressed;
  final VoidCallback onChallengePressed;

  const MainMenu({
    super.key,
    required this.onSandboxPressed,
    required this.onChallengePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                'CANT',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 16,
                  color: GameColors.beam,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'a balance game',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 4,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 80),

              // Challenge Mode Button
              _MenuButton(
                label: 'CHALLENGE',
                onPressed: onChallengePressed,
                isPrimary: true,
              ),
              const SizedBox(height: 20),

              // Sandbox Mode Button
              _MenuButton(
                label: 'SANDBOX',
                onPressed: onSandboxPressed,
                isPrimary: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _MenuButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 56,
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
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
            color: isPrimary ? GameColors.beam : GameColors.beam.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}
