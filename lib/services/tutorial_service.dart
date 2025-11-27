import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  static const _keySeen = 'tutorial_seen';
  static TutorialService? _instance;
  static SharedPreferences? _prefs;

  TutorialService._();

  static Future<TutorialService> getInstance() async {
    _instance ??= TutorialService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  bool get hasSeenTutorial => _prefs?.getBool(_keySeen) ?? false;

  Future<void> markTutorialSeen() async {
    await _prefs?.setBool(_keySeen, true);
  }

  /// Reset tutorial (for testing)
  Future<void> resetTutorial() async {
    await _prefs?.remove(_keySeen);
  }
}
