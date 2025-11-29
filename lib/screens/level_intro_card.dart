import 'package:flutter/material.dart';
import '../game/campaign_level.dart';
import '../utils/colors.dart';

/// Shows level info before starting a campaign level
class LevelIntroCard extends StatelessWidget {
  final CampaignLevel level;
  final VoidCallback onStart;
  final VoidCallback onBack;

  const LevelIntroCard({
    super.key,
    required this.level,
    required this.onStart,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GameColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back,
                    color: GameColors.beam.withValues(alpha: 0.6),
                    size: 28,
                  ),
                ),
              ),
              const Spacer(),
              // Level number
              Text(
                'LEVEL ${level.number}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  color: GameColors.beam.withValues(alpha: 0.5),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 8),
              // Level name
              Text(
                level.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                  letterSpacing: 8,
                  color: GameColors.beam,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                level.description,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 2,
                  color: GameColors.beam.withValues(alpha: 0.6),
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Target
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: GameColors.beam.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'TARGET',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4,
                        color: GameColors.beam.withValues(alpha: 0.4),
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.height,
                          size: 24,
                          color: GameColors.beam.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${level.targetHeight.toStringAsFixed(0)} UNITS',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 4,
                            color: GameColors.beam,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Active mechanics
              if (_hasAnyMechanic()) ...[
                Text(
                  'ACTIVE MECHANICS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 4,
                    color: GameColors.beam.withValues(alpha: 0.4),
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _buildMechanicChips(),
                ),
              ],
              const Spacer(),
              // Start button
              SizedBox(
                width: 200,
                height: 56,
                child: OutlinedButton(
                  onPressed: onStart,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: GameColors.beam.withValues(alpha: 0.1),
                    side: BorderSide(
                      color: GameColors.beam,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'START',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 6,
                      color: GameColors.beam,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasAnyMechanic() {
    return level.hasAutoSpawn ||
        level.hasIncreasedGravity ||
        level.hasWind ||
        level.hasShapeVariety ||
        level.hasBeamInstability ||
        level.hasTimePressure;
  }

  List<Widget> _buildMechanicChips() {
    final chips = <Widget>[];

    if (level.hasAutoSpawn) {
      chips.add(_MechanicChip(
        icon: Icons.downloading,
        label: 'AUTO DROP',
        description: 'Shapes fall automatically',
      ));
    }
    if (level.hasIncreasedGravity) {
      chips.add(_MechanicChip(
        icon: Icons.arrow_downward,
        label: 'HEAVY',
        description: 'Increased gravity',
      ));
    }
    if (level.hasWind) {
      chips.add(_MechanicChip(
        icon: Icons.air,
        label: 'WIND',
        description: 'Gusts push shapes',
      ));
    }
    if (level.hasShapeVariety) {
      chips.add(_MechanicChip(
        icon: Icons.category,
        label: 'VARIETY',
        description: 'Multiple shapes',
      ));
    }
    if (level.hasBeamInstability) {
      chips.add(_MechanicChip(
        icon: Icons.vibration,
        label: 'UNSTABLE',
        description: 'Slippery beam',
      ));
    }
    if (level.hasTimePressure) {
      chips.add(_MechanicChip(
        icon: Icons.timer,
        label: 'TIMED',
        description: 'Time pressure',
      ));
    }

    return chips;
  }
}

class _MechanicChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;

  const _MechanicChip({
    required this.icon,
    required this.label,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: description,
      preferBelow: true,
      textStyle: TextStyle(
        fontSize: 12,
        color: GameColors.background,
      ),
      decoration: BoxDecoration(
        color: GameColors.beam,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: GameColors.beam.withValues(alpha: 0.1),
          border: Border.all(
            color: GameColors.beam.withValues(alpha: 0.4),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: GameColors.beam.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 2,
                color: GameColors.beam.withValues(alpha: 0.8),
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
