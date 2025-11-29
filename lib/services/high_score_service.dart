import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const _key = 'high_score';
  static HighScoreService? _instance;

  final SharedPreferences _prefs;

  HighScoreService._(this._prefs);

  /// Get the singleton instance asynchronously (initializes if needed)
  static Future<HighScoreService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = HighScoreService._(prefs);
    }
    return _instance!;
  }

  /// Get the singleton instance synchronously (must call getInstance first)
  static HighScoreService get instance {
    assert(_instance != null, 'HighScoreService not initialized. Call getInstance() first.');
    return _instance!;
  }

  /// Reset singleton for testing - forces re-initialization
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  int get highScore => _prefs.getInt(_key) ?? 0;

  Future<bool> submitScore(int score) async {
    if (score > highScore) {
      await _prefs.setInt(_key, score);
      return true; // New high score
    }
    return false;
  }

  Future<void> reset() async {
    await _prefs.remove(_key);
  }
}
