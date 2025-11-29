import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/campaign_level.dart';
import 'package:cant/game/sandbox_challenges.dart';

void main() {
  group('CampaignLevel', () {
    group('all levels list', () {
      test('has 40 levels', () {
        expect(CampaignLevel.all.length, 40);
      });

      test('level numbers are sequential 1-40', () {
        for (int i = 0; i < CampaignLevel.all.length; i++) {
          expect(CampaignLevel.all[i].number, i + 1,
              reason: 'Level at index $i should be level ${i + 1}');
        }
      });

      test('all levels have non-empty names', () {
        for (final level in CampaignLevel.all) {
          expect(level.name.isNotEmpty, true,
              reason: 'Level ${level.number} should have a name');
        }
      });

      test('all levels have non-empty descriptions', () {
        for (final level in CampaignLevel.all) {
          expect(level.description.isNotEmpty, true,
              reason: 'Level ${level.number} should have a description');
        }
      });

      test('all levels have positive target heights', () {
        for (final level in CampaignLevel.all) {
          expect(level.targetHeight, greaterThan(0),
              reason: 'Level ${level.number} should have positive targetHeight');
        }
      });

      test('all levels are height-based', () {
        for (final level in CampaignLevel.all) {
          expect(level.isHeightBased, true,
              reason: 'Level ${level.number} should be height-based');
        }
      });
    });

    group('chapter 1 (basics) levels 1-5', () {
      test('have no auto spawn', () {
        for (int i = 0; i < 5; i++) {
          expect(CampaignLevel.all[i].hasAutoSpawn, false,
              reason: 'Level ${i + 1} should not have auto spawn');
        }
      });

      test('have no special mechanics', () {
        for (int i = 0; i < 5; i++) {
          final level = CampaignLevel.all[i];
          expect(level.hasIncreasedGravity, false);
          expect(level.hasWind, false);
          expect(level.hasShapeVariety, false);
          expect(level.hasBeamInstability, false);
          expect(level.hasTimePressure, false);
        }
      });

      test('have progressive target heights 3-7', () {
        expect(CampaignLevel.level1.targetHeight, 3.0);
        expect(CampaignLevel.level2.targetHeight, 4.0);
        expect(CampaignLevel.level3.targetHeight, 5.0);
        expect(CampaignLevel.level4.targetHeight, 6.0);
        expect(CampaignLevel.level5.targetHeight, 7.0);
      });
    });

    group('chapter 2 (falling objects) levels 6-10', () {
      test('have auto spawn enabled', () {
        for (int i = 5; i < 10; i++) {
          expect(CampaignLevel.all[i].hasAutoSpawn, true,
              reason: 'Level ${i + 1} should have auto spawn');
        }
      });

      test('have decreasing spawn intervals', () {
        final intervals = [
          CampaignLevel.level6.spawnInterval,
          CampaignLevel.level7.spawnInterval,
          CampaignLevel.level8.spawnInterval,
          CampaignLevel.level9.spawnInterval,
          CampaignLevel.level10.spawnInterval,
        ];
        for (int i = 1; i < intervals.length; i++) {
          expect(intervals[i], lessThanOrEqualTo(intervals[i - 1]),
              reason: 'Spawn interval should decrease or stay same');
        }
      });
    });

    group('chapter 3 (heavy world) levels 11-15', () {
      test('have increased gravity enabled', () {
        for (int i = 10; i < 15; i++) {
          expect(CampaignLevel.all[i].hasIncreasedGravity, true,
              reason: 'Level ${i + 1} should have increased gravity');
        }
      });

      test('have gravity values above default', () {
        const defaultGravity = 10.0;
        for (int i = 10; i < 15; i++) {
          expect(CampaignLevel.all[i].gravityY, greaterThan(defaultGravity),
              reason: 'Level ${i + 1} should have gravity > 10');
        }
      });
    });

    group('chapter 4 (shape mastery) levels 16-20', () {
      test('have shape variety enabled', () {
        for (int i = 15; i < 20; i++) {
          expect(CampaignLevel.all[i].hasShapeVariety, true,
              reason: 'Level ${i + 1} should have shape variety');
        }
      });
    });

    group('chapter 5 (wind) levels 21-25', () {
      test('have wind enabled', () {
        for (int i = 20; i < 25; i++) {
          expect(CampaignLevel.all[i].hasWind, true,
              reason: 'Level ${i + 1} should have wind');
        }
      });
    });

    group('chapter 6 (unstable ground) levels 26-30', () {
      test('have beam instability enabled', () {
        for (int i = 25; i < 30; i++) {
          expect(CampaignLevel.all[i].hasBeamInstability, true,
              reason: 'Level ${i + 1} should have beam instability');
        }
      });

      test('have reduced beam friction', () {
        for (int i = 25; i < 30; i++) {
          expect(CampaignLevel.all[i].beamFriction, lessThan(SandboxChallenges.defaultBeamFriction),
              reason: 'Level ${i + 1} should have reduced friction');
        }
      });
    });

    group('chapter 7 (time crunch) levels 31-35', () {
      test('have time pressure enabled', () {
        for (int i = 30; i < 35; i++) {
          expect(CampaignLevel.all[i].hasTimePressure, true,
              reason: 'Level ${i + 1} should have time pressure');
        }
      });
    });

    group('chapter 8 (mastery) levels 36-40', () {
      test('level 40 has all mechanics enabled', () {
        final level40 = CampaignLevel.level40;
        expect(level40.hasAutoSpawn, true);
        expect(level40.hasIncreasedGravity, true);
        expect(level40.hasShapeVariety, true);
        expect(level40.hasWind, true);
        expect(level40.hasBeamInstability, true);
        expect(level40.hasTimePressure, true);
      });

      test('level 40 has highest target height', () {
        final maxHeight = CampaignLevel.all
            .map((l) => l.targetHeight)
            .reduce((a, b) => a > b ? a : b);
        expect(CampaignLevel.level40.targetHeight, maxHeight);
      });
    });

    group('beam physics', () {
      test('beamDamping uses level override when set', () {
        // Levels without override should use default
        expect(CampaignLevel.level1.beamDamping, SandboxChallenges.defaultBeamDamping);
      });

      test('beamFriction uses level override when set', () {
        // Level 26 has explicit friction override of 0.3
        expect(CampaignLevel.level26.beamFriction, 0.3);
      });

      test('beamFriction uses default when not overridden', () {
        expect(CampaignLevel.level1.beamFriction, SandboxChallenges.defaultBeamFriction);
      });
    });

    group('specific levels', () {
      test('level1 First Steps', () {
        expect(CampaignLevel.level1.number, 1);
        expect(CampaignLevel.level1.name, 'First Steps');
        expect(CampaignLevel.level1.targetHeight, 3.0);
      });

      test('level40 The Final Balance', () {
        expect(CampaignLevel.level40.number, 40);
        expect(CampaignLevel.level40.name, 'The Final Balance');
        expect(CampaignLevel.level40.targetHeight, 10.0);
      });
    });

    group('settleTime', () {
      test('tutorial levels (1-5) have base time of 1.5s', () {
        // Tutorial levels have no hazards, so settleTime = 1.5
        expect(CampaignLevel.level1.settleTime, 1.5);
        expect(CampaignLevel.level2.settleTime, 1.5);
        expect(CampaignLevel.level3.settleTime, 1.5);
        expect(CampaignLevel.level4.settleTime, 1.5);
        expect(CampaignLevel.level5.settleTime, 1.5);
      });

      test('non-tutorial levels without hazards have base time of 2.0s', () {
        // Level 6-10 have auto-spawn but no hazards that affect settle time
        expect(CampaignLevel.level6.settleTime, 2.0);
        expect(CampaignLevel.level10.settleTime, 2.0);
      });

      test('wind hazard reduces settle time by 0.3s', () {
        // Chapter 5 (wind) levels 21-25 have wind, base 2.0 - 0.3 = 1.7
        expect(CampaignLevel.level21.settleTime, 1.7);
        expect(CampaignLevel.level25.settleTime, 1.7);
      });

      test('beam instability reduces settle time by 0.3s', () {
        // Chapter 6 (unstable ground) levels 26-30 have beam instability
        // base 2.0 - 0.3 = 1.7
        expect(CampaignLevel.level26.settleTime, 1.7);
        expect(CampaignLevel.level30.settleTime, 1.7);
      });

      test('time pressure reduces settle time by 0.4s', () {
        // Chapter 7 (time crunch) levels 31-35 have time pressure
        // base 2.0 - 0.4 = 1.6
        expect(CampaignLevel.level31.settleTime, 1.6);
        expect(CampaignLevel.level35.settleTime, 1.6);
      });

      test('multiple hazards stack reductions', () {
        // Level 40 has wind (-0.3), beam instability (-0.3), and time pressure (-0.4)
        // base 2.0 - 0.3 - 0.3 - 0.4 = 1.0 (clamped minimum)
        expect(CampaignLevel.level40.settleTime, 1.0);
      });

      test('settle time is clamped to minimum of 1.0s', () {
        // Level 40 has all hazards: 2.0 - 0.3 - 0.3 - 0.4 = 1.0
        // Even with all hazards, should not go below 1.0
        expect(CampaignLevel.level40.settleTime, greaterThanOrEqualTo(1.0));
      });

      test('settle time is clamped to maximum of 2.5s', () {
        for (final level in CampaignLevel.all) {
          expect(level.settleTime, lessThanOrEqualTo(2.5),
              reason: 'Level ${level.number} settle time should not exceed 2.5s');
        }
      });

      test('all levels have valid settle times within bounds', () {
        for (final level in CampaignLevel.all) {
          expect(level.settleTime, greaterThanOrEqualTo(1.0),
              reason: 'Level ${level.number} settle time should be >= 1.0s');
          expect(level.settleTime, lessThanOrEqualTo(2.5),
              reason: 'Level ${level.number} settle time should be <= 2.5s');
        }
      });
    });
  });
}
