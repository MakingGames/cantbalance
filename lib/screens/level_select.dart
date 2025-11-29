import 'package:flutter/material.dart';
import '../game/campaign_level.dart';
import '../services/level_progress_service.dart';
import '../utils/colors.dart';

class LevelSelectScreen extends StatelessWidget {
  final LevelProgressService progressService;
  final void Function(CampaignLevel level) onLevelSelected;
  final VoidCallback onBack;

  const LevelSelectScreen({
    super.key,
    required this.progressService,
    required this.onLevelSelected,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: Icon(
                      Icons.arrow_back,
                      color: GameColors.beam.withValues(alpha: 0.6),
                      size: 28,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'CAMPAIGN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 8,
                      color: GameColors.beam,
                    ),
                  ),
                  const Spacer(),
                  // Stars counter
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: GameColors.beam,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${progressService.totalStars}/${CampaignLevel.all.length}',
                        style: TextStyle(
                          fontSize: 16,
                          color: GameColors.beam.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

            // Level grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: CampaignLevel.all.length,
                itemBuilder: (context, index) {
                  final level = CampaignLevel.all[index];
                  final isUnlocked = progressService.isLevelUnlocked(level.number);
                  final isCompleted = progressService.isLevelCompleted(level.number);

                  return _LevelTile(
                    level: level,
                    isUnlocked: isUnlocked,
                    isCompleted: isCompleted,
                    onTap: isUnlocked ? () => onLevelSelected(level) : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final CampaignLevel level;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? GameColors.beam.withValues(alpha: 0.1)
              : GameColors.beam.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCompleted
                ? GameColors.beam.withValues(alpha: 0.5)
                : isUnlocked
                    ? GameColors.beam.withValues(alpha: 0.2)
                    : GameColors.beam.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Level number or lock
            if (isUnlocked)
              Text(
                '${level.number}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w200,
                  color: isCompleted
                      ? GameColors.beam
                      : GameColors.beam.withValues(alpha: 0.8),
                ),
              )
            else
              Icon(
                Icons.lock_outline,
                size: 28,
                color: GameColors.beam.withValues(alpha: 0.2),
              ),

            const SizedBox(height: 4),

            // Level name
            Text(
              level.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
                color: isUnlocked
                    ? GameColors.beam.withValues(alpha: 0.6)
                    : GameColors.beam.withValues(alpha: 0.2),
              ),
            ),

            const SizedBox(height: 4),

            // Completion star
            if (isCompleted)
              Icon(
                Icons.star,
                size: 16,
                color: GameColors.beam,
              )
            else if (isUnlocked)
              Icon(
                Icons.star_border,
                size: 16,
                color: GameColors.beam.withValues(alpha: 0.3),
              ),
          ],
        ),
      ),
    );
  }
}
