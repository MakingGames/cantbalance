import 'dart:math';

import 'package:flame_forge2d/flame_forge2d.dart';

/// Manages beam instability mechanics - applies random torque nudges to the beam
class BeamInstabilitySystem {
  final Random _random = Random();

  // State
  double _nudgeTimer = 0;
  double _nextNudgeInterval = 1.5;

  // Configuration (can be adjusted for sandbox mode)
  double nudgeIntervalMin;
  double nudgeIntervalMax;
  double torqueMagnitudeMin;
  double torqueMagnitudeMax;

  // Callback for external effects
  final void Function(double torque)? onNudgeApplied;

  BeamInstabilitySystem({
    this.nudgeIntervalMin = 1.0,
    this.nudgeIntervalMax = 3.0,
    this.torqueMagnitudeMin = 50.0,
    this.torqueMagnitudeMax = 150.0,
    this.onNudgeApplied,
  });

  /// Time until next nudge
  double get timeUntilNextNudge => _nextNudgeInterval - _nudgeTimer;

  /// Update beam instability and apply torque to beam body
  void update(double dt, Body beamBody) {
    _nudgeTimer += dt;

    if (_nudgeTimer >= _nextNudgeInterval) {
      _nudgeTimer = 0;
      _nextNudgeInterval = nudgeIntervalMin +
          _random.nextDouble() * (nudgeIntervalMax - nudgeIntervalMin);

      final torqueDirection = _random.nextBool() ? 1.0 : -1.0;
      final torqueMagnitude = torqueMagnitudeMin +
          _random.nextDouble() * (torqueMagnitudeMax - torqueMagnitudeMin);
      final torque = torqueDirection * torqueMagnitude;

      beamBody.applyTorque(torque);
      onNudgeApplied?.call(torque);
    }
  }

  /// Reset all state (useful for game restart)
  void reset() {
    _nudgeTimer = 0;
    _nextNudgeInterval = 1.5;
  }
}
