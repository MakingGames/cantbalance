import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cant/services/high_score_service.dart';

void main() {
  group('HighScoreService', () {
    setUp(() {
      // Reset singleton and SharedPreferences before each test
      HighScoreService.resetForTesting();
      SharedPreferences.setMockInitialValues({});
    });

    test('returns 0 when no high score exists', () async {
      SharedPreferences.setMockInitialValues({});
      final service = await HighScoreService.getInstance();

      expect(service.highScore, 0);
    });

    test('returns stored high score', () async {
      SharedPreferences.setMockInitialValues({'high_score': 42});
      // Force new instance by resetting singleton (for testing)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('high_score', 42);

      final service = await HighScoreService.getInstance();
      expect(service.highScore, 42);
    });

    group('submitScore', () {
      test('returns true and updates when score is higher than current', () async {
        SharedPreferences.setMockInitialValues({'high_score': 10});
        final service = await HighScoreService.getInstance();

        final result = await service.submitScore(20);

        expect(result, true);
        expect(service.highScore, 20);
      });

      test('returns false and does not update when score is lower', () async {
        SharedPreferences.setMockInitialValues({'high_score': 100});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('high_score', 100);

        final service = await HighScoreService.getInstance();

        final result = await service.submitScore(50);

        expect(result, false);
        expect(service.highScore, 100);
      });

      test('returns false when score equals current high score', () async {
        SharedPreferences.setMockInitialValues({'high_score': 50});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('high_score', 50);

        final service = await HighScoreService.getInstance();

        final result = await service.submitScore(50);

        expect(result, false);
        expect(service.highScore, 50);
      });

      test('returns true on first score submission', () async {
        SharedPreferences.setMockInitialValues({});
        final service = await HighScoreService.getInstance();

        final result = await service.submitScore(1);

        expect(result, true);
        expect(service.highScore, 1);
      });
    });

    group('reset', () {
      test('clears high score', () async {
        SharedPreferences.setMockInitialValues({'high_score': 100});
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('high_score', 100);

        final service = await HighScoreService.getInstance();
        expect(service.highScore, 100);

        await service.reset();

        expect(service.highScore, 0);
      });
    });
  });
}
