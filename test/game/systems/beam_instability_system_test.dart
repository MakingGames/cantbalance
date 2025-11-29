import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/systems/beam_instability_system.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

class MockBody extends Mock implements Body {}

void main() {
  group('BeamInstabilitySystem', () {
    late MockBody mockBody;

    setUp(() {
      mockBody = MockBody();
    });

    group('initial state', () {
      test('has default configuration values', () {
        final system = BeamInstabilitySystem();
        expect(system.nudgeIntervalMin, 1.0);
        expect(system.nudgeIntervalMax, 3.0);
        expect(system.torqueMagnitudeMin, 50.0);
        expect(system.torqueMagnitudeMax, 150.0);
      });

      test('timeUntilNextNudge starts positive', () {
        final system = BeamInstabilitySystem();
        expect(system.timeUntilNextNudge, greaterThan(0));
      });
    });

    group('configuration', () {
      test('accepts custom nudge interval', () {
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 2.0,
          nudgeIntervalMax: 5.0,
        );
        expect(system.nudgeIntervalMin, 2.0);
        expect(system.nudgeIntervalMax, 5.0);
      });

      test('accepts custom torque magnitude', () {
        final system = BeamInstabilitySystem(
          torqueMagnitudeMin: 100.0,
          torqueMagnitudeMax: 200.0,
        );
        expect(system.torqueMagnitudeMin, 100.0);
        expect(system.torqueMagnitudeMax, 200.0);
      });
    });

    group('update behavior', () {
      test('does not apply torque before interval elapses', () {
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 2.0,
          nudgeIntervalMax: 2.0,
        );

        system.update(0.5, mockBody);
        verifyNever(() => mockBody.applyTorque(any()));
      });

      test('applies torque after interval elapses', () {
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 1.0,
          nudgeIntervalMax: 1.0,
        );

        // Initial interval is 1.5 seconds, so we need to exceed that
        system.update(2.0, mockBody);
        verify(() => mockBody.applyTorque(any())).called(1);
      });

      test('applies multiple torques over time', () {
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 0.5,
          nudgeIntervalMax: 0.5,
        );

        // Multiple updates to trigger multiple nudges
        for (int i = 0; i < 10; i++) {
          system.update(1.0, mockBody);
        }

        verify(() => mockBody.applyTorque(any())).called(greaterThan(1));
      });

      test('timeUntilNextNudge decreases with update', () {
        final system = BeamInstabilitySystem();
        final initialTime = system.timeUntilNextNudge;

        system.update(0.5, mockBody);
        expect(system.timeUntilNextNudge, lessThan(initialTime));
      });
    });

    group('callback', () {
      test('onNudgeApplied is called when torque is applied', () {
        double? appliedTorque;
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 0.5,
          nudgeIntervalMax: 0.5,
          onNudgeApplied: (torque) => appliedTorque = torque,
        );

        system.update(2.0, mockBody);

        expect(appliedTorque, isNotNull);
        expect(appliedTorque!.abs(), greaterThanOrEqualTo(50.0));
        expect(appliedTorque!.abs(), lessThanOrEqualTo(150.0));
      });

      test('torque direction is either positive or negative', () {
        final torques = <double>[];
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 0.1,
          nudgeIntervalMax: 0.1,
          onNudgeApplied: (torque) => torques.add(torque),
        );

        // Run many times to get both directions
        for (int i = 0; i < 50; i++) {
          system.update(1.0, mockBody);
        }

        final hasPositive = torques.any((t) => t > 0);
        final hasNegative = torques.any((t) => t < 0);

        expect(hasPositive, true, reason: 'Should have at least one positive torque');
        expect(hasNegative, true, reason: 'Should have at least one negative torque');
      });
    });

    group('reset', () {
      test('reset clears timer state', () {
        final system = BeamInstabilitySystem();

        system.update(1.0, mockBody);
        final timeBeforeReset = system.timeUntilNextNudge;

        system.reset();

        // After reset, timeUntilNextNudge should be reset to initial interval
        expect(system.timeUntilNextNudge, equals(1.5));
        expect(system.timeUntilNextNudge, isNot(equals(timeBeforeReset)));
      });

      test('can nudge again after reset', () {
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 0.5,
          nudgeIntervalMax: 0.5,
        );

        system.update(2.0, mockBody);
        system.reset();
        system.update(2.0, mockBody);

        verify(() => mockBody.applyTorque(any())).called(2);
      });
    });

    group('torque magnitude bounds', () {
      test('torque magnitude is within configured bounds', () {
        final torques = <double>[];
        final system = BeamInstabilitySystem(
          nudgeIntervalMin: 0.1,
          nudgeIntervalMax: 0.1,
          torqueMagnitudeMin: 75.0,
          torqueMagnitudeMax: 125.0,
          onNudgeApplied: (torque) => torques.add(torque),
        );

        for (int i = 0; i < 50; i++) {
          system.update(1.0, mockBody);
        }

        for (final torque in torques) {
          expect(torque.abs(), greaterThanOrEqualTo(75.0));
          expect(torque.abs(), lessThanOrEqualTo(125.0));
        }
      });
    });
  });
}
