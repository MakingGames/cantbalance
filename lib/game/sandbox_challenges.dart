/// Challenge settings for sandbox mode with toggleable options
class SandboxChallenges {
  // Toggle flags
  bool tiltControl;
  bool tiltInverted;
  bool windGusts;
  bool heavyGravity;
  bool slipperyBeam;
  bool beamInstability;
  bool shapeVariety;

  // Adjustable values (with sliders)
  double tiltStrength;      // Torque multiplier (default 200, range 50-500)
  double tiltSensitivity;   // Angle multiplier (default 0.08, range 0.02-0.2)
  double beamDamping;       // Angular damping (default 0, range 0-5) - higher = less swing
  double gravityMultiplier; // Gravity Y (default 10, range 5-25)
  double windStrength;      // Wind force multiplier (default 1.0, range 0.5-3.0)
  double beamFriction;      // Beam friction (default 0.8, range 0.1-2.0)

  // Default values
  static const double defaultTiltStrength = 200.0;
  static const double defaultTiltSensitivity = 0.08;
  static const double defaultBeamDamping = 3.0; // Higher damping = less swinging
  static const double defaultGravity = 10.0;
  static const double defaultWindStrength = 1.0;
  static const double defaultBeamFriction = 0.8;

  // Ranges for sliders
  static const double tiltStrengthMin = 50.0;
  static const double tiltStrengthMax = 500.0;
  static const double tiltSensitivityMin = 0.02;
  static const double tiltSensitivityMax = 0.20;
  static const double beamDampingMin = 0.0;
  static const double beamDampingMax = 5.0;
  static const double gravityMin = 5.0;
  static const double gravityMax = 25.0;
  static const double windStrengthMin = 0.5;
  static const double windStrengthMax = 3.0;
  static const double beamFrictionMin = 0.1;
  static const double beamFrictionMax = 2.0;

  // Wind settings (base values, scaled by windStrength)
  static const double windGustIntervalMin = 2.0;
  static const double windGustIntervalMax = 5.0;
  static const double baseWindForceMin = 15.0;
  static const double baseWindForceMax = 40.0;
  static const double windGustDuration = 2.5;
  static const double windWarningDuration = 2.0; // Warning before wind hits

  SandboxChallenges({
    this.tiltControl = false,
    this.tiltInverted = true,
    this.windGusts = false,
    this.heavyGravity = false,
    this.slipperyBeam = false,
    this.beamInstability = false,
    this.shapeVariety = false,
    this.tiltStrength = defaultTiltStrength,
    this.tiltSensitivity = defaultTiltSensitivity,
    this.beamDamping = defaultBeamDamping,
    this.gravityMultiplier = defaultGravity,
    this.windStrength = defaultWindStrength,
    this.beamFriction = defaultBeamFriction,
  });

  // Computed wind force values
  double get windForceMin => baseWindForceMin * windStrength;
  double get windForceMax => baseWindForceMax * windStrength;

  SandboxChallenges copyWith({
    bool? tiltControl,
    bool? tiltInverted,
    bool? windGusts,
    bool? heavyGravity,
    bool? slipperyBeam,
    bool? beamInstability,
    bool? shapeVariety,
    double? tiltStrength,
    double? tiltSensitivity,
    double? beamDamping,
    double? gravityMultiplier,
    double? windStrength,
    double? beamFriction,
  }) {
    return SandboxChallenges(
      tiltControl: tiltControl ?? this.tiltControl,
      tiltInverted: tiltInverted ?? this.tiltInverted,
      windGusts: windGusts ?? this.windGusts,
      heavyGravity: heavyGravity ?? this.heavyGravity,
      slipperyBeam: slipperyBeam ?? this.slipperyBeam,
      beamInstability: beamInstability ?? this.beamInstability,
      shapeVariety: shapeVariety ?? this.shapeVariety,
      tiltStrength: tiltStrength ?? this.tiltStrength,
      tiltSensitivity: tiltSensitivity ?? this.tiltSensitivity,
      beamDamping: beamDamping ?? this.beamDamping,
      gravityMultiplier: gravityMultiplier ?? this.gravityMultiplier,
      windStrength: windStrength ?? this.windStrength,
      beamFriction: beamFriction ?? this.beamFriction,
    );
  }
}
