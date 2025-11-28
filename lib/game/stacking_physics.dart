/// Physics settings for stacking mode with toggleable options
class StackingPhysics {
  // Toggle flags
  bool highFriction;
  bool highDamping;
  bool magneticAttraction;
  bool stickyContacts;

  // Friction settings
  static const double normalFriction = 0.8;
  static const double highFrictionValue = 2.0;

  // Damping settings
  static const double normalLinearDamping = 0.0;
  static const double normalAngularDamping = 0.0;
  static const double highLinearDamping = 2.0;
  static const double highAngularDamping = 3.0;

  // Magnetic attraction settings
  static const double attractionForce = 5.0;
  static const double attractionRange = 1.5; // World units

  // Sticky contact settings
  static const double stickyFriction = 5.0;

  StackingPhysics({
    this.highFriction = false,
    this.highDamping = false,
    this.magneticAttraction = false,
    this.stickyContacts = false,
  });

  double get friction {
    if (stickyContacts) return stickyFriction;
    if (highFriction) return highFrictionValue;
    return normalFriction;
  }

  double get linearDamping => highDamping ? highLinearDamping : normalLinearDamping;
  double get angularDamping => highDamping ? highAngularDamping : normalAngularDamping;

  StackingPhysics copyWith({
    bool? highFriction,
    bool? highDamping,
    bool? magneticAttraction,
    bool? stickyContacts,
  }) {
    return StackingPhysics(
      highFriction: highFriction ?? this.highFriction,
      highDamping: highDamping ?? this.highDamping,
      magneticAttraction: magneticAttraction ?? this.magneticAttraction,
      stickyContacts: stickyContacts ?? this.stickyContacts,
    );
  }
}
