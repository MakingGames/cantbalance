import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameThemeMode { dark, light }

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'game_theme_mode';
  static ThemeService? _instance;

  late SharedPreferences _prefs;
  GameThemeMode _themeMode = GameThemeMode.dark;

  GameThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == GameThemeMode.dark;

  ThemeService._();

  static Future<ThemeService> getInstance() async {
    if (_instance == null) {
      _instance = ThemeService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Get the singleton instance synchronously (must call getInstance first)
  static ThemeService get instance {
    assert(_instance != null, 'ThemeService not initialized. Call getInstance() first.');
    return _instance!;
  }

  /// Reset singleton for testing - forces re-initialization
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme == 'light') {
      _themeMode = GameThemeMode.light;
    } else {
      _themeMode = GameThemeMode.dark;
    }
  }

  Future<void> setThemeMode(GameThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode == GameThemeMode.light ? 'light' : 'dark');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(isDarkMode ? GameThemeMode.light : GameThemeMode.dark);
  }
}
