import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';

import '../constants.dart';

/// Manages wind gust mechanics with warning phase, active phase, and intervals
class WindSystem {
  final Random _random = Random();

  // State
  double _timeSinceLastGust = 0;
  double _nextGustInterval = 3.0;
  double _currentWindForce = 0;
  double _windGustTimer = 0;
  bool _isWindActive = false;
  bool _isWindWarning = false;
  double _windWarningTimer = 0;
  double _pendingWindDirection = 0;
  double _pendingWindForce = 0;

  // Configuration (can be adjusted for sandbox mode)
  double windStrengthMultiplier;

  // Timing configuration (defaults to GameConstants values)
  double gustIntervalMin;
  double gustIntervalMax;
  double gustDuration;
  double warningDuration;
  double forceMin;
  double forceMax;

  // Callbacks for external effects
  final void Function(double force, bool isActive)? onWindChanged;
  final void Function(double direction)? onWindWarning;

  WindSystem({
    this.windStrengthMultiplier = 1.0,
    double? gustIntervalMin,
    double? gustIntervalMax,
    double? gustDuration,
    double? warningDuration,
    double? forceMin,
    double? forceMax,
    this.onWindChanged,
    this.onWindWarning,
  })  : gustIntervalMin = gustIntervalMin ?? GameConstants.windGustIntervalMin,
        gustIntervalMax = gustIntervalMax ?? GameConstants.windGustIntervalMax,
        gustDuration = gustDuration ?? GameConstants.windGustDuration,
        warningDuration = warningDuration ?? GameConstants.windWarningDuration,
        forceMin = forceMin ?? GameConstants.windForceMin,
        forceMax = forceMax ?? GameConstants.windForceMax;

  /// Current wind force (0 when inactive)
  double get currentWindForce => _currentWindForce;

  /// Whether wind is currently active
  bool get isActive => _isWindActive;

  /// Whether in warning phase (wind about to start)
  bool get isWarning => _isWindWarning;

  /// Wind direction: -1.0 (left) or 1.0 (right), 0 when inactive
  double get direction => _isWindActive ? _pendingWindDirection : 0;

  /// Update wind system state and apply forces to bodies
  void update(double dt, List<Body> bodies) {
    if (_isWindActive) {
      _updateActivePhase(dt, bodies);
    } else if (_isWindWarning) {
      _updateWarningPhase(dt);
    } else {
      _updateWaitingPhase(dt);
    }
  }

  void _updateActivePhase(double dt, List<Body> bodies) {
    // Apply wind force to all provided bodies
    for (final body in bodies) {
      body.applyForce(Vector2(_currentWindForce, 0));
    }

    // Count down gust timer
    _windGustTimer -= dt;
    if (_windGustTimer <= 0) {
      _isWindActive = false;
      _currentWindForce = 0;
      onWindChanged?.call(0, false);

      // Set next gust interval
      _nextGustInterval = gustIntervalMin +
          _random.nextDouble() * (gustIntervalMax - gustIntervalMin);
    }
  }

  void _updateWarningPhase(double dt) {
    _windWarningTimer -= dt;
    if (_windWarningTimer <= 0) {
      _isWindWarning = false;
      _isWindActive = true;
      _windGustTimer = gustDuration;
      _currentWindForce = _pendingWindForce;
      onWindChanged?.call(_currentWindForce, true);
    }
  }

  void _updateWaitingPhase(double dt) {
    _timeSinceLastGust += dt;
    if (_timeSinceLastGust >= _nextGustInterval) {
      // Start warning phase
      _isWindWarning = true;
      _timeSinceLastGust = 0;
      _windWarningTimer = warningDuration;

      // Pre-calculate direction and force for after warning
      _pendingWindDirection = _random.nextBool() ? 1.0 : -1.0;

      // Apply strength multiplier to force range
      final scaledForceMin = forceMin * windStrengthMultiplier;
      final scaledForceMax = forceMax * windStrengthMultiplier;
      final forceMagnitude =
          scaledForceMin + _random.nextDouble() * (scaledForceMax - scaledForceMin);
      _pendingWindForce = _pendingWindDirection * forceMagnitude;

      // Notify about warning
      onWindWarning?.call(_pendingWindDirection);
    }
  }

  /// Reset all wind state (useful for game restart)
  void reset() {
    _timeSinceLastGust = 0;
    _nextGustInterval = 3.0;
    _currentWindForce = 0;
    _windGustTimer = 0;
    _isWindActive = false;
    _isWindWarning = false;
    _windWarningTimer = 0;
    _pendingWindDirection = 0;
    _pendingWindForce = 0;
  }
}
