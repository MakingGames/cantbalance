import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const _keySeen = 'tutorial_seen';
  static TutorialService? _instance;

  final SharedPreferences _prefs;

  TutorialService._(this._prefs);

  /// Get the singleton instance asynchronously (initializes if needed)
  static Future<TutorialService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = TutorialService._(prefs);
    }
    return _instance!;
  }

  /// Get the singleton instance synchronously (must call getInstance first)
  static TutorialService get instance {
    assert(_instance != null, 'TutorialService not initialized. Call getInstance() first.');
    return _instance!;
  }

  /// Reset singleton for testing - forces re-initialization
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  bool get hasSeenTutorial => _prefs.getBool(_keySeen) ?? false;

  Future<void> markTutorialSeen() async {
    await _prefs.setBool(_keySeen, true);
  }

  /// Reset tutorial (for testing)
  Future<void> resetTutorial() async {
    await _prefs.remove(_keySeen);
  }
}
