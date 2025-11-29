import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/sandbox_challenges.dart';

void main() {
  group('SandboxChallenges', () {
    group('default values', () {
      test('all toggles are false by default except tiltInverted', () {
        final challenges = SandboxChallenges();

        expect(challenges.tiltControl, false);
        expect(challenges.tiltInverted, true); // Default is true
        expect(challenges.windGusts, false);
        expect(challenges.heavyGravity, false);
        expect(challenges.slipperyBeam, false);
        expect(challenges.beamInstability, false);
        expect(challenges.shapeVariety, false);
      });

      test('numeric values have correct defaults', () {
        final challenges = SandboxChallenges();

        expect(challenges.tiltStrength, SandboxChallenges.defaultTiltStrength);
        expect(challenges.tiltSensitivity, SandboxChallenges.defaultTiltSensitivity);
        expect(challenges.beamDamping, SandboxChallenges.defaultBeamDamping);
        expect(challenges.gravityMultiplier, SandboxChallenges.defaultGravity);
        expect(challenges.windStrength, SandboxChallenges.defaultWindStrength);
        expect(challenges.beamFriction, SandboxChallenges.defaultBeamFriction);
      });
    });

    group('computed wind force values', () {
      test('windForceMin scales with windStrength', () {
        final challenges = SandboxChallenges(windStrength: 2.0);

        expect(
          challenges.windForceMin,
          SandboxChallenges.baseWindForceMin * 2.0,
        );
      });

      test('windForceMax scales with windStrength', () {
        final challenges = SandboxChallenges(windStrength: 1.5);

        expect(
          challenges.windForceMax,
          SandboxChallenges.baseWindForceMax * 1.5,
        );
      });
    });

    group('copyWith', () {
      test('returns new instance with updated toggle values', () {
        final original = SandboxChallenges();
        final updated = original.copyWith(
          tiltControl: true,
          windGusts: true,
        );

        // Original unchanged
        expect(original.tiltControl, false);
        expect(original.windGusts, false);

        // Updated has new values
        expect(updated.tiltControl, true);
        expect(updated.windGusts, true);

        // Non-specified values remain the same
        expect(updated.heavyGravity, original.heavyGravity);
        expect(updated.tiltInverted, original.tiltInverted);
      });

      test('returns new instance with updated numeric values', () {
        final original = SandboxChallenges();
        final updated = original.copyWith(
          tiltStrength: 300.0,
          gravityMultiplier: 15.0,
        );

        // Original unchanged
        expect(original.tiltStrength, SandboxChallenges.defaultTiltStrength);
        expect(original.gravityMultiplier, SandboxChallenges.defaultGravity);

        // Updated has new values
        expect(updated.tiltStrength, 300.0);
        expect(updated.gravityMultiplier, 15.0);
      });

      test('returns identical values when no arguments provided', () {
        final original = SandboxChallenges(
          tiltControl: true,
          windGusts: true,
          tiltStrength: 250.0,
        );
        final copy = original.copyWith();

        expect(copy.tiltControl, original.tiltControl);
        expect(copy.windGusts, original.windGusts);
        expect(copy.tiltStrength, original.tiltStrength);
      });
    });

    group('slider range constants', () {
      test('tilt strength range is valid', () {
        expect(SandboxChallenges.tiltStrengthMin, lessThan(SandboxChallenges.tiltStrengthMax));
        expect(SandboxChallenges.defaultTiltStrength, greaterThanOrEqualTo(SandboxChallenges.tiltStrengthMin));
        expect(SandboxChallenges.defaultTiltStrength, lessThanOrEqualTo(SandboxChallenges.tiltStrengthMax));
      });

      test('gravity range is valid', () {
        expect(SandboxChallenges.gravityMin, lessThan(SandboxChallenges.gravityMax));
        expect(SandboxChallenges.defaultGravity, greaterThanOrEqualTo(SandboxChallenges.gravityMin));
        expect(SandboxChallenges.defaultGravity, lessThanOrEqualTo(SandboxChallenges.gravityMax));
      });

      test('wind strength range is valid', () {
        expect(SandboxChallenges.windStrengthMin, lessThan(SandboxChallenges.windStrengthMax));
        expect(SandboxChallenges.defaultWindStrength, greaterThanOrEqualTo(SandboxChallenges.windStrengthMin));
        expect(SandboxChallenges.defaultWindStrength, lessThanOrEqualTo(SandboxChallenges.windStrengthMax));
      });
    });
  });
}
