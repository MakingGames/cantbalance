/// Defines the level thresholds and which difficulty modifiers are active
enum GameLevel {
  /// Level 1: Just manual placement, learn basics
  basics(
    number: 1,
    minScore: 0,
    hasAutoSpawn: false,
    hasIncreasedGravity: false,
    hasWind: false,
  ),

  /// Level 2: Auto-spawn begins
  autoSpawn(
    number: 2,
    minScore: 10,
    hasAutoSpawn: true,
    hasIncreasedGravity: false,
    hasWind: false,
  ),

  /// Level 3: Gravity increases
  gravity(
    number: 3,
    minScore: 20,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: false,
  ),

  /// Level 4: Wind gusts (future)
  wind(
    number: 4,
    minScore: 35,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasWind: true,
  );

  final int number;
  final int minScore;
  final bool hasAutoSpawn;
  final bool hasIncreasedGravity;
  final bool hasWind;

  const GameLevel({
    required this.number,
    required this.minScore,
    required this.hasAutoSpawn,
    required this.hasIncreasedGravity,
    required this.hasWind,
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
