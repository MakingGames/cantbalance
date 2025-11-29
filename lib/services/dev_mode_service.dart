import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage dev mode state (hidden testing features)
class DevModeService extends ChangeNotifier {
  static const String _devModeKey = 'dev_mode_enabled';
  static const int tapsToUnlock = 5;

  static DevModeService? _instance;
  SharedPreferences? _prefs;

  DevModeService._();

  /// Get the singleton instance asynchronously (initializes if needed)
  static Future<DevModeService> getInstance() async {
    if (_instance == null) {
      _instance = DevModeService._();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Get the singleton instance synchronously (must call getInstance first)
  static DevModeService get instance {
    assert(_instance != null, 'DevModeService not initialized. Call getInstance() first.');
    return _instance!;
  }

  /// Reset singleton for testing - forces re-initialization
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  bool _isDevMode = false;
  bool get isDevMode => _isDevMode;

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _isDevMode = _prefs!.getBool(_devModeKey) ?? false;
    notifyListeners();
  }

  Future<void> enableDevMode() async {
    _isDevMode = true;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_devModeKey, true);
    notifyListeners();
  }

  Future<void> disableDevMode() async {
    _isDevMode = false;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setBool(_devModeKey, false);
    notifyListeners();
  }

  Future<void> toggleDevMode() async {
    if (_isDevMode) {
      await disableDevMode();
    } else {
      await enableDevMode();
    }
  }
}
