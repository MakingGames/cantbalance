import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/systems/wind_system.dart';

void main() {
  group('WindSystem', () {
    group('initial state', () {
      test('starts inactive', () {
        final windSystem = WindSystem();
        expect(windSystem.isActive, false);
      });

      test('starts not in warning', () {
        final windSystem = WindSystem();
        expect(windSystem.isWarning, false);
      });

      test('starts with zero wind force', () {
        final windSystem = WindSystem();
        expect(windSystem.currentWindForce, 0);
      });

      test('direction is zero when inactive', () {
        final windSystem = WindSystem();
        expect(windSystem.direction, 0);
      });

      test('windStrengthMultiplier defaults to 1.0', () {
        final windSystem = WindSystem();
        expect(windSystem.windStrengthMultiplier, 1.0);
      });
    });

    group('configuration', () {
      test('accepts custom windStrengthMultiplier', () {
        final windSystem = WindSystem(windStrengthMultiplier: 2.0);
        expect(windSystem.windStrengthMultiplier, 2.0);
      });

      test('windStrengthMultiplier can be modified', () {
        final windSystem = WindSystem();
        windSystem.windStrengthMultiplier = 3.0;
        expect(windSystem.windStrengthMultiplier, 3.0);
      });
    });

    group('callbacks', () {
      test('onWindWarning is called when warning starts', () {
        double? warningDirection;
        final windSystem = WindSystem(
          onWindWarning: (direction) => warningDirection = direction,
        );

        // Fast forward past waiting phase (default 3 seconds)
        windSystem.update(4.0, []);

        expect(warningDirection, isNotNull);
        expect(warningDirection == 1.0 || warningDirection == -1.0, true);
      });

      test('onWindChanged is called when wind activates', () {
        double? changedForce;
        bool? changedIsActive;
        final windSystem = WindSystem(
          onWindChanged: (force, isActive) {
            changedForce = force;
            changedIsActive = isActive;
          },
        );

        // Fast forward to trigger warning
        windSystem.update(4.0, []);
        expect(windSystem.isWarning, true);

        // Fast forward past warning phase (2 seconds default)
        windSystem.update(3.0, []);

        expect(changedForce, isNotNull);
        expect(changedForce != 0, true);
        expect(changedIsActive, true);
      });

      test('onWindChanged is called with zero force when wind ends', () {
        double? lastForce;
        bool? lastIsActive;
        final windSystem = WindSystem(
          onWindChanged: (force, isActive) {
            lastForce = force;
            lastIsActive = isActive;
          },
        );

        // Trigger warning then active
        windSystem.update(4.0, []);
        windSystem.update(3.0, []);
        expect(windSystem.isActive, true);

        // Fast forward past active phase (2.5 seconds default)
        windSystem.update(3.0, []);

        expect(lastForce, 0);
        expect(lastIsActive, false);
      });
    });

    group('state transitions', () {
      test('transitions from waiting to warning', () {
        final windSystem = WindSystem();

        expect(windSystem.isWarning, false);
        windSystem.update(4.0, []);
        expect(windSystem.isWarning, true);
      });

      test('transitions from warning to active', () {
        final windSystem = WindSystem();

        windSystem.update(4.0, []);
        expect(windSystem.isWarning, true);
        expect(windSystem.isActive, false);

        windSystem.update(3.0, []);
        expect(windSystem.isWarning, false);
        expect(windSystem.isActive, true);
      });

      test('transitions from active to waiting', () {
        final windSystem = WindSystem();

        // Go through full cycle
        windSystem.update(4.0, []); // waiting -> warning
        windSystem.update(3.0, []); // warning -> active
        expect(windSystem.isActive, true);

        windSystem.update(3.0, []); // active -> waiting
        expect(windSystem.isActive, false);
        expect(windSystem.isWarning, false);
      });

      test('direction is set when active', () {
        final windSystem = WindSystem();

        windSystem.update(4.0, []);
        windSystem.update(3.0, []);

        expect(windSystem.isActive, true);
        expect(windSystem.direction == 1.0 || windSystem.direction == -1.0, true);
      });

      test('wind force is non-zero when active', () {
        final windSystem = WindSystem();

        windSystem.update(4.0, []);
        windSystem.update(3.0, []);

        expect(windSystem.isActive, true);
        expect(windSystem.currentWindForce, isNot(0));
      });
    });

    group('reset', () {
      test('reset clears all state', () {
        final windSystem = WindSystem();

        // Get to active state
        windSystem.update(4.0, []);
        windSystem.update(3.0, []);
        expect(windSystem.isActive, true);

        windSystem.reset();

        expect(windSystem.isActive, false);
        expect(windSystem.isWarning, false);
        expect(windSystem.currentWindForce, 0);
        expect(windSystem.direction, 0);
      });

      test('can cycle again after reset', () {
        final windSystem = WindSystem();

        // First cycle
        windSystem.update(4.0, []);
        windSystem.update(3.0, []);
        windSystem.reset();

        // Should start fresh
        expect(windSystem.isActive, false);

        // Can cycle again
        windSystem.update(4.0, []);
        expect(windSystem.isWarning, true);
      });
    });

    group('windStrengthMultiplier effect', () {
      test('higher multiplier produces stronger wind on average', () {
        // Test with double strength - run multiple times to get average
        double totalStrongForce = 0;
        double totalNormalForce = 0;
        const runs = 20;

        for (int i = 0; i < runs; i++) {
          final strongWind = WindSystem(windStrengthMultiplier: 2.0);
          strongWind.update(4.0, []);
          strongWind.update(3.0, []);
          totalStrongForce += strongWind.currentWindForce.abs();

          final normalWind = WindSystem(windStrengthMultiplier: 1.0);
          normalWind.update(4.0, []);
          normalWind.update(3.0, []);
          totalNormalForce += normalWind.currentWindForce.abs();
        }

        // Average strong force should be higher than average normal force
        expect(totalStrongForce / runs, greaterThan(totalNormalForce / runs));
      });
    });
  });
}
