import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage dev mode state (hidden testing features)
class DevModeService extends ChangeNotifier {
  static const String _devModeKey = 'dev_mode_enabled';
  static const int tapsToUnlock = 5;

  static final DevModeService _instance = DevModeService._internal();
  static DevModeService get instance => _instance;

  DevModeService._internal();

  bool _isDevMode = false;
  bool get isDevMode => _isDevMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDevMode = prefs.getBool(_devModeKey) ?? false;
    notifyListeners();
  }

  Future<void> enableDevMode() async {
    _isDevMode = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModeKey, true);
    notifyListeners();
  }

  Future<void> disableDevMode() async {
    _isDevMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_devModeKey, false);
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
