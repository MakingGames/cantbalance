import 'package:shared_preferences/shared_preferences.dart';

class HighScoreService {
  static const _key = 'high_score';
  static HighScoreService? _instance;
  static SharedPreferences? _prefs;

  HighScoreService._();

  static Future<HighScoreService> getInstance() async {
    _instance ??= HighScoreService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  int get highScore => _prefs?.getInt(_key) ?? 0;

  Future<bool> submitScore(int score) async {
    if (score > highScore) {
      await _prefs?.setInt(_key, score);
      return true; // New high score
    }
    return false;
  }

  Future<void> reset() async {
    await _prefs?.remove(_key);
  }
}
