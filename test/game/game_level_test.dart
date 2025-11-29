import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/game_level.dart';

void main() {
  group('GameLevel', () {
    group('enum values', () {
      test('has 7 levels', () {
        expect(GameLevel.values.length, 7);
      });

      test('levels are ordered by number', () {
        for (int i = 0; i < GameLevel.values.length; i++) {
          expect(GameLevel.values[i].number, i + 1);
        }
      });

      test('minScores are progressive', () {
        int previousScore = -1;
        for (final level in GameLevel.values) {
          expect(level.minScore, greaterThan(previousScore),
              reason: '${level.name} should have higher minScore than previous');
          previousScore = level.minScore;
        }
      });
    });

    group('level properties', () {
      test('basics level has no modifiers', () {
        expect(GameLevel.basics.hasAutoSpawn, false);
        expect(GameLevel.basics.hasIncreasedGravity, false);
        expect(GameLevel.basics.hasWind, false);
        expect(GameLevel.basics.hasShapeVariety, false);
        expect(GameLevel.basics.hasBeamInstability, false);
        expect(GameLevel.basics.hasTimePressure, false);
        expect(GameLevel.basics.challenge, '');
      });

      test('autoSpawn level enables auto spawn', () {
        expect(GameLevel.autoSpawn.hasAutoSpawn, true);
        expect(GameLevel.autoSpawn.hasIncreasedGravity, false);
        expect(GameLevel.autoSpawn.challenge, 'FALLING SHAPES');
      });

      test('gravity level enables gravity and auto spawn', () {
        expect(GameLevel.gravity.hasAutoSpawn, true);
        expect(GameLevel.gravity.hasIncreasedGravity, true);
        expect(GameLevel.gravity.hasWind, false);
        expect(GameLevel.gravity.challenge, 'HEAVY GRAVITY');
      });

      test('shapes level enables shape variety', () {
        expect(GameLevel.shapes.hasShapeVariety, true);
        expect(GameLevel.shapes.hasIncreasedGravity, true);
        expect(GameLevel.shapes.challenge, 'NEW SHAPES');
      });

      test('wind level enables wind', () {
        expect(GameLevel.wind.hasWind, true);
        expect(GameLevel.wind.hasShapeVariety, true);
        expect(GameLevel.wind.challenge, 'WIND GUSTS');
      });

      test('instability level enables beam instability', () {
        expect(GameLevel.instability.hasBeamInstability, true);
        expect(GameLevel.instability.hasWind, true);
        expect(GameLevel.instability.challenge, 'UNSTABLE BEAM');
      });

      test('timePressure level enables all modifiers', () {
        expect(GameLevel.timePressure.hasAutoSpawn, true);
        expect(GameLevel.timePressure.hasIncreasedGravity, true);
        expect(GameLevel.timePressure.hasWind, true);
        expect(GameLevel.timePressure.hasShapeVariety, true);
        expect(GameLevel.timePressure.hasBeamInstability, true);
        expect(GameLevel.timePressure.hasTimePressure, true);
        expect(GameLevel.timePressure.challenge, 'TIME PRESSURE');
      });
    });

    group('fromScore', () {
      test('returns basics for score 0', () {
        expect(GameLevel.fromScore(0), GameLevel.basics);
      });

      test('returns basics for negative score', () {
        expect(GameLevel.fromScore(-5), GameLevel.basics);
      });

      test('returns autoSpawn at minScore threshold', () {
        expect(GameLevel.fromScore(5), GameLevel.autoSpawn);
      });

      test('returns autoSpawn for score between autoSpawn and gravity', () {
        expect(GameLevel.fromScore(7), GameLevel.autoSpawn);
      });

      test('returns gravity at minScore threshold', () {
        expect(GameLevel.fromScore(10), GameLevel.gravity);
      });

      test('returns shapes at minScore threshold', () {
        expect(GameLevel.fromScore(16), GameLevel.shapes);
      });

      test('returns wind at minScore threshold', () {
        expect(GameLevel.fromScore(22), GameLevel.wind);
      });

      test('returns instability at minScore threshold', () {
        expect(GameLevel.fromScore(30), GameLevel.instability);
      });

      test('returns timePressure at minScore threshold', () {
        expect(GameLevel.fromScore(40), GameLevel.timePressure);
      });

      test('returns timePressure for very high scores', () {
        expect(GameLevel.fromScore(100), GameLevel.timePressure);
        expect(GameLevel.fromScore(1000), GameLevel.timePressure);
      });

      test('returns correct level just below each threshold', () {
        expect(GameLevel.fromScore(4), GameLevel.basics);
        expect(GameLevel.fromScore(9), GameLevel.autoSpawn);
        expect(GameLevel.fromScore(15), GameLevel.gravity);
        expect(GameLevel.fromScore(21), GameLevel.shapes);
        expect(GameLevel.fromScore(29), GameLevel.wind);
        expect(GameLevel.fromScore(39), GameLevel.instability);
      });
    });
  });
}
