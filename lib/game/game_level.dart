/// Defines the level thresholds and which difficulty modifiers are active
enum GameLevel {
  /// Level 1: Just manual placement, learn basics
  basics(
    number: 1,
    minScore: 0,
    challenge: '',
    hasAutoSpawn: false,
    hasIncreasedGravity: false,
    hasWind: false,
    hasShapeVariety: false,
    hasBeamInstability: false,
    hasTimePressure: false,
  ),

  /// Level 2: Auto-spawn begins
  autoSpawn(
    number: 2,
    minScore: 5,
    challenge: 'FALLING SHAPES',
    hasAutoSpawn: true,
    hasIncreasedGravity: false,
    hasWind: false,
    hasShapeVariety: false,
    hasBeamInstability: false,
    hasTimePressure: false,
  ),

  /// Level 3: Gravity increases
  gravity(
    number: 3,
    minScore: 10,
    challenge: 'HEAVY GRAVITY',
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: false,
    hasShapeVariety: false,
    hasBeamInstability: false,
    hasTimePressure: false,
  ),

  /// Level 4: Shape variety (circles, triangles)
  shapes(
    number: 4,
    minScore: 16,
    challenge: 'NEW SHAPES',
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: false,
    hasShapeVariety: true,
    hasBeamInstability: false,
    hasTimePressure: false,
  ),

  /// Level 5: Wind gusts
  wind(
    number: 5,
    minScore: 22,
    challenge: 'WIND GUSTS',
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: true,
    hasShapeVariety: true,
    hasBeamInstability: false,
    hasTimePressure: false,
  ),

  /// Level 6: Beam instability
  instability(
    number: 6,
    minScore: 30,
    challenge: 'UNSTABLE BEAM',
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    hasTimePressure: false,
  ),

  /// Level 7: Time pressure - must place shapes quickly
  timePressure(
    number: 7,
    minScore: 40,
    challenge: 'TIME PRESSURE',
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    hasTimePressure: true,
  );

  final int number;
  final int minScore;
  final String challenge;
  final bool hasAutoSpawn;
  final bool hasIncreasedGravity;
  final bool hasWind;
  final bool hasShapeVariety;
  final bool hasBeamInstability;
  final bool hasTimePressure;

  const GameLevel({
    required this.number,
    required this.minScore,
    required this.challenge,
    required this.hasAutoSpawn,
    required this.hasIncreasedGravity,
    required this.hasWind,
    required this.hasShapeVariety,
    required this.hasBeamInstability,
    required this.hasTimePressure,
  });

  /// Get the current level based on score
  static GameLevel fromScore(int score) {
    // Iterate in reverse to find highest qualifying level
    for (final level in GameLevel.values.reversed) {
      if (score >= level.minScore) {
        return level;
      }
    }
    return GameLevel.basics;
  }
}
