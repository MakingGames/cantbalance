import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/stacking_physics.dart';

void main() {
  group('StackingPhysics', () {
    group('default values', () {
      test('all toggles are false by default', () {
        final physics = StackingPhysics();

        expect(physics.highFriction, false);
        expect(physics.highDamping, false);
        expect(physics.magneticAttraction, false);
        expect(physics.stickyContacts, false);
      });
    });

    group('friction', () {
      test('returns normal friction when no toggles enabled', () {
        final physics = StackingPhysics();

        expect(physics.friction, StackingPhysics.normalFriction);
      });

      test('returns high friction when highFriction enabled', () {
        final physics = StackingPhysics(highFriction: true);

        expect(physics.friction, StackingPhysics.highFrictionValue);
      });

      test('returns sticky friction when stickyContacts enabled', () {
        final physics = StackingPhysics(stickyContacts: true);

        expect(physics.friction, StackingPhysics.stickyFriction);
      });

      test('sticky contacts takes priority over high friction', () {
        final physics = StackingPhysics(
          highFriction: true,
          stickyContacts: true,
        );

        expect(physics.friction, StackingPhysics.stickyFriction);
      });
    });

    group('damping', () {
      test('returns normal damping when highDamping disabled', () {
        final physics = StackingPhysics();

        expect(physics.linearDamping, StackingPhysics.normalLinearDamping);
        expect(physics.angularDamping, StackingPhysics.normalAngularDamping);
      });

      test('returns high damping when highDamping enabled', () {
        final physics = StackingPhysics(highDamping: true);

        expect(physics.linearDamping, StackingPhysics.highLinearDamping);
        expect(physics.angularDamping, StackingPhysics.highAngularDamping);
      });
    });

    group('copyWith', () {
      test('returns new instance with updated values', () {
        final original = StackingPhysics();
        final updated = original.copyWith(
          highFriction: true,
          magneticAttraction: true,
        );

        // Original unchanged
        expect(original.highFriction, false);
        expect(original.magneticAttraction, false);

        // Updated has new values
        expect(updated.highFriction, true);
        expect(updated.magneticAttraction, true);

        // Non-specified values remain the same
        expect(updated.highDamping, original.highDamping);
        expect(updated.stickyContacts, original.stickyContacts);
      });

      test('returns identical values when no arguments provided', () {
        final original = StackingPhysics(
          highFriction: true,
          highDamping: true,
        );
        final copy = original.copyWith();

        expect(copy.highFriction, original.highFriction);
        expect(copy.highDamping, original.highDamping);
        expect(copy.magneticAttraction, original.magneticAttraction);
        expect(copy.stickyContacts, original.stickyContacts);
      });
    });

    group('constants', () {
      test('friction values are ordered correctly', () {
        expect(StackingPhysics.normalFriction, lessThan(StackingPhysics.highFrictionValue));
        expect(StackingPhysics.highFrictionValue, lessThan(StackingPhysics.stickyFriction));
      });

      test('high damping values are greater than normal', () {
        expect(StackingPhysics.highLinearDamping, greaterThan(StackingPhysics.normalLinearDamping));
        expect(StackingPhysics.highAngularDamping, greaterThan(StackingPhysics.normalAngularDamping));
      });
    });
  });
}
