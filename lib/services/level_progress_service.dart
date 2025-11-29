import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/campaign_level.dart';

/// Tracks campaign level progress (unlocked, completed, best scores)
class LevelProgressService {
  static const String _unlockedKey = 'unlocked_levels';
  static const String _completedKeyPrefix = 'level_completed_';
  static const String _bestScoreKeyPrefix = 'level_best_';

  final SharedPreferences _prefs;

  LevelProgressService._(this._prefs);

  static LevelProgressService? _instance;

  /// Get the singleton instance asynchronously (initializes if needed)
  static Future<LevelProgressService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = LevelProgressService._(prefs);
    }
    return _instance!;
  }

  /// Get the singleton instance synchronously (must call getInstance first)
  static LevelProgressService get instance {
    assert(_instance != null, 'LevelProgressService not initialized. Call getInstance() first.');
    return _instance!;
  }

  /// Reset singleton for testing - forces re-initialization
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  /// Get the highest unlocked level number (1-indexed)
  int get highestUnlockedLevel {
    return _prefs.getInt(_unlockedKey) ?? 1;
  }

  /// Check if a specific level is unlocked
  bool isLevelUnlocked(int levelNumber) {
    return levelNumber <= highestUnlockedLevel;
  }

  /// Check if a specific level is completed
  bool isLevelCompleted(int levelNumber) {
    return _prefs.getBool('$_completedKeyPrefix$levelNumber') ?? false;
  }

  /// Get best score for a level (0 if never completed)
  int getBestScore(int levelNumber) {
    return _prefs.getInt('$_bestScoreKeyPrefix$levelNumber') ?? 0;
  }

  /// Mark a level as completed and unlock the next one
  Future<void> completeLevel(int levelNumber, int score) async {
    // Mark as completed
    await _prefs.setBool('$_completedKeyPrefix$levelNumber', true);

    // Update best score if better
    final currentBest = getBestScore(levelNumber);
    if (score > currentBest) {
      await _prefs.setInt('$_bestScoreKeyPrefix$levelNumber', score);
    }

    // Unlock next level
    final nextLevel = levelNumber + 1;
    if (nextLevel <= CampaignLevel.all.length && nextLevel > highestUnlockedLevel) {
      await _prefs.setInt(_unlockedKey, nextLevel);
    }
  }

  /// Reset all progress (for testing or "new game")
  Future<void> resetProgress() async {
    await _prefs.setInt(_unlockedKey, 1);
    for (int i = 1; i <= CampaignLevel.all.length; i++) {
      await _prefs.remove('$_completedKeyPrefix$i');
      await _prefs.remove('$_bestScoreKeyPrefix$i');
    }
  }

  /// Get total stars earned (completed levels)
  int get totalStars {
    int stars = 0;
    for (int i = 1; i <= CampaignLevel.all.length; i++) {
      if (isLevelCompleted(i)) stars++;
    }
    return stars;
  }
}
