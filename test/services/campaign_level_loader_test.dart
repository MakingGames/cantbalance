import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cant/services/campaign_level_loader.dart';
import 'package:cant/game/campaign_level.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CampaignLevelLoader', () {
    setUp(() {
      CampaignLevelLoader.resetForTesting();
    });

    group('JSON validation', () {
      test('loads 40 levels from JSON', () async {
        // Load the actual JSON file
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;

        expect(levelsJson.length, 40);
      });

      test('all levels have required fields', () async {
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;

        for (final levelJson in levelsJson) {
          final level = levelJson as Map<String, dynamic>;
          expect(level.containsKey('number'), true, reason: 'Level missing number');
          expect(level.containsKey('name'), true, reason: 'Level missing name');
          expect(level.containsKey('description'), true, reason: 'Level missing description');
          expect(level.containsKey('targetHeight'), true, reason: 'Level missing targetHeight');
        }
      });

      test('level numbers are sequential 1-40', () async {
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;

        for (int i = 0; i < levelsJson.length; i++) {
          final level = levelsJson[i] as Map<String, dynamic>;
          expect(level['number'], i + 1, reason: 'Level at index $i should have number ${i + 1}');
        }
      });

      test('all target heights are positive', () async {
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;

        for (final levelJson in levelsJson) {
          final level = levelJson as Map<String, dynamic>;
          final targetHeight = level['targetHeight'] as num;
          expect(targetHeight, greaterThan(0),
              reason: 'Level ${level['number']} has invalid targetHeight');
        }
      });

      test('chapter 1 levels (1-5) have no mechanics enabled', () async {
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;

        for (int i = 0; i < 5; i++) {
          final level = levelsJson[i] as Map<String, dynamic>;
          expect(level['hasAutoSpawn'], isNull,
              reason: 'Level ${i + 1} should not have auto spawn');
          expect(level['hasIncreasedGravity'], isNull,
              reason: 'Level ${i + 1} should not have increased gravity');
        }
      });

      test('chapter 2 levels (6-10) have auto spawn enabled', () async {
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;

        for (int i = 5; i < 10; i++) {
          final level = levelsJson[i] as Map<String, dynamic>;
          expect(level['hasAutoSpawn'], true,
              reason: 'Level ${i + 1} should have auto spawn');
        }
      });

      test('level 40 has all mechanics enabled', () async {
        final jsonString = await rootBundle.loadString('assets/data/campaign_levels.json');
        final jsonData = json.decode(jsonString) as Map<String, dynamic>;
        final levelsJson = jsonData['levels'] as List<dynamic>;
        final level40 = levelsJson[39] as Map<String, dynamic>;

        expect(level40['hasAutoSpawn'], true);
        expect(level40['hasIncreasedGravity'], true);
        expect(level40['hasShapeVariety'], true);
        expect(level40['hasWind'], true);
        expect(level40['hasBeamInstability'], true);
        expect(level40['hasTimePressure'], true);
      });
    });

    group('JSON matches static const levels', () {
      test('all 40 levels match between JSON and static const', () async {
        // Load JSON levels via loader
        final loader = CampaignLevelLoader.instance;
        final jsonLevels = await loader.loadLevels();

        // Compare with static const levels
        final staticLevels = CampaignLevel.all;

        expect(jsonLevels.length, staticLevels.length);

        for (int i = 0; i < jsonLevels.length; i++) {
          final jsonLevel = jsonLevels[i];
          final staticLevel = staticLevels[i];

          expect(jsonLevel.number, staticLevel.number,
              reason: 'Level ${i + 1} number mismatch');
          expect(jsonLevel.name, staticLevel.name,
              reason: 'Level ${i + 1} name mismatch');
          expect(jsonLevel.description, staticLevel.description,
              reason: 'Level ${i + 1} description mismatch');
          expect(jsonLevel.targetHeight, staticLevel.targetHeight,
              reason: 'Level ${i + 1} targetHeight mismatch');
          expect(jsonLevel.hasAutoSpawn, staticLevel.hasAutoSpawn,
              reason: 'Level ${i + 1} hasAutoSpawn mismatch');
          expect(jsonLevel.hasIncreasedGravity, staticLevel.hasIncreasedGravity,
              reason: 'Level ${i + 1} hasIncreasedGravity mismatch');
          expect(jsonLevel.hasWind, staticLevel.hasWind,
              reason: 'Level ${i + 1} hasWind mismatch');
          expect(jsonLevel.hasShapeVariety, staticLevel.hasShapeVariety,
              reason: 'Level ${i + 1} hasShapeVariety mismatch');
          expect(jsonLevel.hasBeamInstability, staticLevel.hasBeamInstability,
              reason: 'Level ${i + 1} hasBeamInstability mismatch');
          expect(jsonLevel.hasTimePressure, staticLevel.hasTimePressure,
              reason: 'Level ${i + 1} hasTimePressure mismatch');
          expect(jsonLevel.spawnInterval, staticLevel.spawnInterval,
              reason: 'Level ${i + 1} spawnInterval mismatch');
          expect(jsonLevel.gravityY, staticLevel.gravityY,
              reason: 'Level ${i + 1} gravityY mismatch');
          expect(jsonLevel.beamFriction, staticLevel.beamFriction,
              reason: 'Level ${i + 1} beamFriction mismatch');
        }
      });
    });

    group('loader service', () {
      test('instance is singleton', () {
        final loader1 = CampaignLevelLoader.instance;
        final loader2 = CampaignLevelLoader.instance;
        expect(identical(loader1, loader2), true);
      });

      test('isLoaded returns false before loading', () {
        final loader = CampaignLevelLoader.instance;
        expect(loader.isLoaded, false);
      });

      test('isLoaded returns true after loading', () async {
        final loader = CampaignLevelLoader.instance;
        await loader.loadLevels();
        expect(loader.isLoaded, true);
      });

      test('levels getter throws before loading', () {
        final loader = CampaignLevelLoader.instance;
        expect(() => loader.levels, throwsStateError);
      });

      test('levels getter returns levels after loading', () async {
        final loader = CampaignLevelLoader.instance;
        await loader.loadLevels();
        expect(loader.levels.length, 40);
      });

      test('loadLevels returns same list on subsequent calls', () async {
        final loader = CampaignLevelLoader.instance;
        final levels1 = await loader.loadLevels();
        final levels2 = await loader.loadLevels();
        expect(identical(levels1, levels2), true);
      });

      test('getLevelByNumber returns correct level', () async {
        final loader = CampaignLevelLoader.instance;
        await loader.loadLevels();

        final level1 = loader.getLevelByNumber(1);
        expect(level1?.name, 'First Steps');

        final level40 = loader.getLevelByNumber(40);
        expect(level40?.name, 'The Final Balance');
      });

      test('getLevelByNumber returns null for invalid number', () async {
        final loader = CampaignLevelLoader.instance;
        await loader.loadLevels();

        expect(loader.getLevelByNumber(0), isNull);
        expect(loader.getLevelByNumber(41), isNull);
        expect(loader.getLevelByNumber(-1), isNull);
      });

      test('validateLevels returns no errors for valid data', () async {
        final loader = CampaignLevelLoader.instance;
        await loader.loadLevels();

        final errors = loader.validateLevels();
        expect(errors, isEmpty);
      });
    });
  });
}
