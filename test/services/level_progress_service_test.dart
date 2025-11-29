import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/services/level_progress_service.dart';
import 'package:cant/game/campaign_level.dart';

void main() {
  group('LevelProgressService', () {
    late LevelProgressService service;

    setUp(() async {
      // Reset singleton and SharedPreferences before each test
      LevelProgressService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    group('initialization', () {
      test('getInstance returns same instance on subsequent calls', () async {
        SharedPreferences.setMockInitialValues({});
        final service1 = await LevelProgressService.getInstance();
        final service2 = await LevelProgressService.getInstance();

        expect(identical(service1, service2), true);
      });

      test('synchronous instance getter works after initialization', () async {
        SharedPreferences.setMockInitialValues({});
        final asyncInstance = await LevelProgressService.getInstance();
        final syncInstance = LevelProgressService.instance;

        expect(identical(asyncInstance, syncInstance), true);
      });
    });

    group('highestUnlockedLevel', () {
      test('returns 1 when no progress exists', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        expect(service.highestUnlockedLevel, 1);
      });

      test('returns stored value', () async {
        SharedPreferences.setMockInitialValues({'unlocked_levels': 5});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('unlocked_levels', 5);

        service = await LevelProgressService.getInstance();

        expect(service.highestUnlockedLevel, 5);
      });
    });

    group('isLevelUnlocked', () {
      test('level 1 is always unlocked', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        expect(service.isLevelUnlocked(1), true);
      });

      test('levels up to highestUnlocked are unlocked', () async {
        SharedPreferences.setMockInitialValues({'unlocked_levels': 3});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('unlocked_levels', 3);

        service = await LevelProgressService.getInstance();

        expect(service.isLevelUnlocked(1), true);
        expect(service.isLevelUnlocked(2), true);
        expect(service.isLevelUnlocked(3), true);
        expect(service.isLevelUnlocked(4), false);
      });
    });

    group('isLevelCompleted', () {
      test('returns false when level not completed', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        expect(service.isLevelCompleted(1), false);
      });

      test('returns true when level is completed', () async {
        SharedPreferences.setMockInitialValues({'level_completed_1': true});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('level_completed_1', true);

        service = await LevelProgressService.getInstance();

        expect(service.isLevelCompleted(1), true);
      });
    });

    group('getBestScore', () {
      test('returns 0 when no score exists', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        expect(service.getBestScore(1), 0);
      });

      test('returns stored best score', () async {
        SharedPreferences.setMockInitialValues({'level_best_1': 150});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('level_best_1', 150);

        service = await LevelProgressService.getInstance();

        expect(service.getBestScore(1), 150);
      });
    });

    group('completeLevel', () {
      test('marks level as completed', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        await service.completeLevel(1, 100);

        expect(service.isLevelCompleted(1), true);
      });

      test('unlocks next level', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        expect(service.isLevelUnlocked(2), false);

        await service.completeLevel(1, 100);

        expect(service.highestUnlockedLevel, 2);
        expect(service.isLevelUnlocked(2), true);
      });

      test('saves best score', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        await service.completeLevel(1, 100);

        expect(service.getBestScore(1), 100);
      });

      test('updates best score only if better', () async {
        SharedPreferences.setMockInitialValues({
          'level_completed_1': true,
          'level_best_1': 150,
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('level_completed_1', true);
        await prefs.setInt('level_best_1', 150);

        service = await LevelProgressService.getInstance();

        // Lower score should not update
        await service.completeLevel(1, 100);
        expect(service.getBestScore(1), 150);

        // Higher score should update
        await service.completeLevel(1, 200);
        expect(service.getBestScore(1), 200);
      });

      test('does not unlock beyond max level', () async {
        SharedPreferences.setMockInitialValues({
          'unlocked_levels': CampaignLevel.all.length,
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('unlocked_levels', CampaignLevel.all.length);

        service = await LevelProgressService.getInstance();

        await service.completeLevel(CampaignLevel.all.length, 100);

        expect(service.highestUnlockedLevel, CampaignLevel.all.length);
      });
    });

    group('totalStars', () {
      test('returns 0 when no levels completed', () async {
        SharedPreferences.setMockInitialValues({});
        service = await LevelProgressService.getInstance();

        expect(service.totalStars, 0);
      });

      test('returns count of completed levels', () async {
        SharedPreferences.setMockInitialValues({
          'level_completed_1': true,
          'level_completed_2': true,
          'level_completed_3': true,
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('level_completed_1', true);
        await prefs.setBool('level_completed_2', true);
        await prefs.setBool('level_completed_3', true);

        service = await LevelProgressService.getInstance();

        expect(service.totalStars, 3);
      });
    });

    group('resetProgress', () {
      test('resets highestUnlockedLevel to 1', () async {
        SharedPreferences.setMockInitialValues({'unlocked_levels': 5});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('unlocked_levels', 5);

        service = await LevelProgressService.getInstance();
        expect(service.highestUnlockedLevel, 5);

        await service.resetProgress();

        expect(service.highestUnlockedLevel, 1);
      });

      test('clears all level completion data', () async {
        SharedPreferences.setMockInitialValues({
          'level_completed_1': true,
          'level_completed_2': true,
          'level_best_1': 100,
          'level_best_2': 200,
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('level_completed_1', true);
        await prefs.setBool('level_completed_2', true);
        await prefs.setInt('level_best_1', 100);
        await prefs.setInt('level_best_2', 200);

        service = await LevelProgressService.getInstance();
        expect(service.totalStars, 2);

        await service.resetProgress();

        expect(service.isLevelCompleted(1), false);
        expect(service.isLevelCompleted(2), false);
        expect(service.getBestScore(1), 0);
        expect(service.getBestScore(2), 0);
        expect(service.totalStars, 0);
      });
    });
  });
}
