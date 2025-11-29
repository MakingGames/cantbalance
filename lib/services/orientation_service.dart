import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GameOrientation { portrait, landscape }

/// Service to manage game orientation preference.
/// Orientation is locked when entering a game and restored when exiting.
class OrientationService extends ChangeNotifier {
  static const String _orientationKey = 'game_orientation';
  static OrientationService? _instance;

  final SharedPreferences _prefs;
  GameOrientation _orientation = GameOrientation.portrait;

  OrientationService._(this._prefs) {
    final saved = _prefs.getString(_orientationKey);
    if (saved == 'landscape') {
      _orientation = GameOrientation.landscape;
    }
  }

  /// Get the singleton instance asynchronously (initializes if needed)
  static Future<OrientationService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = OrientationService._(prefs);
    }
    return _instance!;
  }

  /// Get the singleton instance synchronously (must call getInstance first)
  static OrientationService get instance {
    assert(_instance != null, 'OrientationService not initialized. Call getInstance() first.');
    return _instance!;
  }

  /// Reset singleton for testing
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }

  GameOrientation get orientation => _orientation;
  bool get isLandscape => _orientation == GameOrientation.landscape;
  bool get isPortrait => _orientation == GameOrientation.portrait;

  /// Set the preferred orientation
  Future<void> setOrientation(GameOrientation orientation) async {
    if (_orientation == orientation) return;
    _orientation = orientation;
    await _prefs.setString(
      _orientationKey,
      orientation == GameOrientation.landscape ? 'landscape' : 'portrait',
    );
    notifyListeners();
  }

  /// Toggle between portrait and landscape
  Future<void> toggleOrientation() async {
    await setOrientation(
      isPortrait ? GameOrientation.landscape : GameOrientation.portrait,
    );
  }

  /// Lock the device to the current preferred orientation.
  /// Call this when entering a game screen.
  Future<void> lockOrientation() async {
    if (isLandscape) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  /// Unlock orientation (allow all orientations).
  /// Call this when returning to menu if you want free rotation there.
  Future<void> unlockOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Get the accelerometer value adjusted for orientation.
  /// In portrait, X axis is used. In landscape, Y axis is used.
  double getAdjustedTilt(double accelX, double accelY) {
    if (isLandscape) {
      // In landscape, Y becomes the left-right tilt axis
      // Negate to match expected direction
      return -accelY;
    }
    return accelX;
  }
}
