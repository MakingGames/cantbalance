import 'package:flutter/material.dart';
import '../game/campaign_level.dart';
import '../utils/colors.dart';

class LevelCompleteOverlay extends StatelessWidget {
  final CampaignLevel level;
  final int score;
  final bool hasNextLevel;
  final VoidCallback onNextLevel;
  final VoidCallback onRetry;
  final VoidCallback onLevelSelect;

  const LevelCompleteOverlay({
    super.key,
    required this.level,
    required this.score,
    required this.hasNextLevel,
    required this.onNextLevel,
    required this.onRetry,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withValues(alpha: 0.95),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Star
              Icon(
                Icons.star,
                size: 64,
                color: GameColors.accent,
              ),

              const SizedBox(height: 24),

              // Level complete text
              Text(
                'LEVEL ${level.number}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'COMPLETE',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8,
                  color: GameColors.beam,
                ),
              ),

              const SizedBox(height: 32),

              // Level name
              Text(
                level.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3,
                  color: GameColors.accent,
                ),
              ),

              const SizedBox(height: 16),

              // Score
              Text(
                '$score / ${level.targetShapes} shapes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 48),

              // Buttons
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Level select
                  _ActionButton(
                    label: 'LEVELS',
                    icon: Icons.grid_view,
                    onTap: onLevelSelect,
                  ),

                  // Retry
                  _ActionButton(
                    label: 'RETRY',
                    icon: Icons.refresh,
                    onTap: onRetry,
                  ),

                  if (hasNextLevel)
                    // Next level
                    _ActionButton(
                      label: 'NEXT',
                      icon: Icons.arrow_forward,
                      onTap: onNextLevel,
                      isPrimary: true,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LevelFailedOverlay extends StatelessWidget {
  final CampaignLevel level;
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onLevelSelect;

  const LevelFailedOverlay({
    super.key,
    required this.level,
    required this.score,
    required this.onRetry,
    required this.onLevelSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background.withValues(alpha: 0.95),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // X icon
              Icon(
                Icons.close,
                size: 64,
                color: GameColors.danger,
              ),

              const SizedBox(height: 24),

              // Level failed text
              Text(
                'LEVEL ${level.number}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'FAILED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8,
                  color: GameColors.danger,
                ),
              ),

              const SizedBox(height: 32),

              // Progress
              Text(
                '$score / ${level.targetShapes} shapes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: GameColors.beam.withValues(alpha: 0.6),
                ),
              ),

              const SizedBox(height: 48),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Level select
                  _ActionButton(
                    label: 'LEVELS',
                    icon: Icons.grid_view,
                    onTap: onLevelSelect,
                  ),

                  const SizedBox(width: 16),

                  // Retry
                  _ActionButton(
                    label: 'RETRY',
                    icon: Icons.refresh,
                    onTap: onRetry,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isPrimary
              ? GameColors.accent.withValues(alpha: 0.2)
              : GameColors.beam.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPrimary
                ? GameColors.accent.withValues(alpha: 0.5)
                : GameColors.beam.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary ? GameColors.accent : GameColors.beam.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                letterSpacing: 2,
                color: isPrimary ? GameColors.accent : GameColors.beam.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
