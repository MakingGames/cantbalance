/// Defines discrete campaign levels with specific win conditions
class CampaignLevel {
  final int number;
  final String name;
  final String description;
  final int targetShapes; // Win condition: place this many shapes

  // Mechanics enabled for this level
  final bool hasAutoSpawn;
  final bool hasIncreasedGravity;
  final bool hasWind;
  final bool hasShapeVariety;
  final bool hasBeamInstability;
  final bool hasTimePressure;

  // Difficulty tuning (fixed, not progressive)
  final double spawnInterval;
  final double gravityY;

  const CampaignLevel({
    required this.number,
    required this.name,
    required this.description,
    required this.targetShapes,
    this.hasAutoSpawn = false,
    this.hasIncreasedGravity = false,
    this.hasWind = false,
    this.hasShapeVariety = false,
    this.hasBeamInstability = false,
    this.hasTimePressure = false,
    this.spawnInterval = 5.0,
    this.gravityY = 10.0,
  });

  /// All campaign levels
  static const List<CampaignLevel> all = [
    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 1: THE BASICS (Levels 1-5)
    // Manual placement only - learn balance fundamentals
    // ═══════════════════════════════════════════════════════════════
    level1,
    level2,
    level3,
    level4,
    level5,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 2: FALLING OBJECTS (Levels 6-10)
    // Auto-spawn introduced - shapes fall from above
    // ═══════════════════════════════════════════════════════════════
    level6,
    level7,
    level8,
    level9,
    level10,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 3: HEAVY WORLD (Levels 11-15)
    // Increased gravity - things fall faster and hit harder
    // ═══════════════════════════════════════════════════════════════
    level11,
    level12,
    level13,
    level14,
    level15,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 4: SHAPE MASTERY (Levels 16-20)
    // Shape variety - circles roll, triangles tip
    // ═══════════════════════════════════════════════════════════════
    level16,
    level17,
    level18,
    level19,
    level20,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 5: WIND & WEATHER (Levels 21-25)
    // Wind gusts push shapes around
    // ═══════════════════════════════════════════════════════════════
    level21,
    level22,
    level23,
    level24,
    level25,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 6: UNSTABLE GROUND (Levels 26-30)
    // Beam instability - slippery surface and random nudges
    // ═══════════════════════════════════════════════════════════════
    level26,
    level27,
    level28,
    level29,
    level30,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 7: TIME CRUNCH (Levels 31-35)
    // Time pressure - place shapes quickly or lose
    // ═══════════════════════════════════════════════════════════════
    level31,
    level32,
    level33,
    level34,
    level35,

    // ═══════════════════════════════════════════════════════════════
    // CHAPTER 8: MASTERY (Levels 36-40)
    // Combined mechanics - everything together
    // ═══════════════════════════════════════════════════════════════
    level36,
    level37,
    level38,
    level39,
    level40,
  ];

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 1: THE BASICS
  // ═══════════════════════════════════════════════════════════════════

  static const level1 = CampaignLevel(
    number: 1,
    name: 'First Steps',
    description: 'Place 3 shapes on the beam',
    targetShapes: 3,
  );

  static const level2 = CampaignLevel(
    number: 2,
    name: 'Finding Balance',
    description: 'Place 5 shapes',
    targetShapes: 5,
  );

  static const level3 = CampaignLevel(
    number: 3,
    name: 'Steady Hands',
    description: 'Place 7 shapes',
    targetShapes: 7,
  );

  static const level4 = CampaignLevel(
    number: 4,
    name: 'Building Higher',
    description: 'Place 10 shapes',
    targetShapes: 10,
  );

  static const level5 = CampaignLevel(
    number: 5,
    name: 'Balance Master',
    description: 'Place 12 shapes',
    targetShapes: 12,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 2: FALLING OBJECTS
  // ═══════════════════════════════════════════════════════════════════

  static const level6 = CampaignLevel(
    number: 6,
    name: 'First Rain',
    description: 'Shapes begin to fall',
    targetShapes: 5,
    hasAutoSpawn: true,
    spawnInterval: 8.0,
  );

  static const level7 = CampaignLevel(
    number: 7,
    name: 'Light Drizzle',
    description: 'Place 7 shapes',
    targetShapes: 7,
    hasAutoSpawn: true,
    spawnInterval: 6.0,
  );

  static const level8 = CampaignLevel(
    number: 8,
    name: 'Steady Rain',
    description: 'Place 10 shapes',
    targetShapes: 10,
    hasAutoSpawn: true,
    spawnInterval: 5.0,
  );

  static const level9 = CampaignLevel(
    number: 9,
    name: 'Downpour',
    description: 'Place 12 shapes',
    targetShapes: 12,
    hasAutoSpawn: true,
    spawnInterval: 4.0,
  );

  static const level10 = CampaignLevel(
    number: 10,
    name: 'Torrential',
    description: 'Place 15 shapes',
    targetShapes: 15,
    hasAutoSpawn: true,
    spawnInterval: 3.0,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 3: HEAVY WORLD
  // ═══════════════════════════════════════════════════════════════════

  static const level11 = CampaignLevel(
    number: 11,
    name: 'Weighty Matters',
    description: 'Gravity increases',
    targetShapes: 6,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    spawnInterval: 6.0,
    gravityY: 12.0,
  );

  static const level12 = CampaignLevel(
    number: 12,
    name: 'Heavy Burden',
    description: 'Place 8 shapes',
    targetShapes: 8,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    spawnInterval: 5.0,
    gravityY: 13.0,
  );

  static const level13 = CampaignLevel(
    number: 13,
    name: 'Crushing Weight',
    description: 'Place 10 shapes',
    targetShapes: 10,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    spawnInterval: 4.5,
    gravityY: 14.0,
  );

  static const level14 = CampaignLevel(
    number: 14,
    name: 'Dense Atmosphere',
    description: 'Place 12 shapes',
    targetShapes: 12,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    spawnInterval: 4.0,
    gravityY: 15.0,
  );

  static const level15 = CampaignLevel(
    number: 15,
    name: 'Jupiter\'s Pull',
    description: 'Place 15 shapes',
    targetShapes: 15,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    spawnInterval: 3.5,
    gravityY: 16.0,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 4: SHAPE MASTERY
  // ═══════════════════════════════════════════════════════════════════

  static const level16 = CampaignLevel(
    number: 16,
    name: 'Rolling In',
    description: 'Circles and triangles appear',
    targetShapes: 6,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    spawnInterval: 6.0,
  );

  static const level17 = CampaignLevel(
    number: 17,
    name: 'Mixed Bag',
    description: 'Place 8 shapes',
    targetShapes: 8,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    spawnInterval: 5.0,
  );

  static const level18 = CampaignLevel(
    number: 18,
    name: 'Shape Shifter',
    description: 'Place 10 shapes',
    targetShapes: 10,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    spawnInterval: 4.5,
  );

  static const level19 = CampaignLevel(
    number: 19,
    name: 'Geometry Class',
    description: 'Place 12 shapes',
    targetShapes: 12,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    spawnInterval: 4.0,
  );

  static const level20 = CampaignLevel(
    number: 20,
    name: 'Shape Master',
    description: 'Place 15 shapes',
    targetShapes: 15,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    spawnInterval: 3.5,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 5: WIND & WEATHER
  // ═══════════════════════════════════════════════════════════════════

  static const level21 = CampaignLevel(
    number: 21,
    name: 'Light Breeze',
    description: 'Wind gusts begin',
    targetShapes: 6,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasWind: true,
    spawnInterval: 6.0,
  );

  static const level22 = CampaignLevel(
    number: 22,
    name: 'Gusty Day',
    description: 'Place 8 shapes',
    targetShapes: 8,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasWind: true,
    spawnInterval: 5.0,
  );

  static const level23 = CampaignLevel(
    number: 23,
    name: 'Strong Winds',
    description: 'Place 10 shapes',
    targetShapes: 10,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasWind: true,
    spawnInterval: 4.5,
  );

  static const level24 = CampaignLevel(
    number: 24,
    name: 'Gale Force',
    description: 'Place 12 shapes',
    targetShapes: 12,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasWind: true,
    spawnInterval: 4.0,
  );

  static const level25 = CampaignLevel(
    number: 25,
    name: 'Hurricane',
    description: 'Place 15 shapes',
    targetShapes: 15,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasWind: true,
    spawnInterval: 3.5,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 6: UNSTABLE GROUND
  // ═══════════════════════════════════════════════════════════════════

  static const level26 = CampaignLevel(
    number: 26,
    name: 'Slippery Surface',
    description: 'The beam becomes unstable',
    targetShapes: 6,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    spawnInterval: 6.0,
  );

  static const level27 = CampaignLevel(
    number: 27,
    name: 'Shaky Ground',
    description: 'Place 8 shapes',
    targetShapes: 8,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    spawnInterval: 5.0,
  );

  static const level28 = CampaignLevel(
    number: 28,
    name: 'Tremors',
    description: 'Place 10 shapes',
    targetShapes: 10,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    spawnInterval: 4.5,
  );

  static const level29 = CampaignLevel(
    number: 29,
    name: 'Earthquake',
    description: 'Place 12 shapes',
    targetShapes: 12,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    spawnInterval: 4.0,
  );

  static const level30 = CampaignLevel(
    number: 30,
    name: 'Fault Line',
    description: 'Place 15 shapes',
    targetShapes: 15,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasBeamInstability: true,
    spawnInterval: 3.5,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 7: TIME CRUNCH
  // ═══════════════════════════════════════════════════════════════════

  static const level31 = CampaignLevel(
    number: 31,
    name: 'Tick Tock',
    description: 'Place shapes before time runs out',
    targetShapes: 6,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasTimePressure: true,
    spawnInterval: 6.0,
  );

  static const level32 = CampaignLevel(
    number: 32,
    name: 'Racing Clock',
    description: 'Place 8 shapes',
    targetShapes: 8,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasTimePressure: true,
    spawnInterval: 5.0,
  );

  static const level33 = CampaignLevel(
    number: 33,
    name: 'Time Trial',
    description: 'Place 10 shapes',
    targetShapes: 10,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasTimePressure: true,
    spawnInterval: 4.5,
  );

  static const level34 = CampaignLevel(
    number: 34,
    name: 'Speed Run',
    description: 'Place 12 shapes',
    targetShapes: 12,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasTimePressure: true,
    spawnInterval: 4.0,
  );

  static const level35 = CampaignLevel(
    number: 35,
    name: 'Time Master',
    description: 'Place 15 shapes',
    targetShapes: 15,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasTimePressure: true,
    spawnInterval: 3.5,
  );

  // ═══════════════════════════════════════════════════════════════════
  // CHAPTER 8: MASTERY - Combined Mechanics
  // ═══════════════════════════════════════════════════════════════════

  static const level36 = CampaignLevel(
    number: 36,
    name: 'Heavy Storm',
    description: 'Gravity + Wind',
    targetShapes: 10,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasShapeVariety: true,
    hasWind: true,
    spawnInterval: 4.5,
    gravityY: 14.0,
  );

  static const level37 = CampaignLevel(
    number: 37,
    name: 'Chaos Theory',
    description: 'Wind + Instability',
    targetShapes: 12,
    hasAutoSpawn: true,
    hasShapeVariety: true,
    hasWind: true,
    hasBeamInstability: true,
    spawnInterval: 4.0,
  );

  static const level38 = CampaignLevel(
    number: 38,
    name: 'Perfect Storm',
    description: 'Gravity + Wind + Instability',
    targetShapes: 15,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasShapeVariety: true,
    hasWind: true,
    hasBeamInstability: true,
    spawnInterval: 3.5,
    gravityY: 14.0,
  );

  static const level39 = CampaignLevel(
    number: 39,
    name: 'Against All Odds',
    description: 'Everything except time pressure',
    targetShapes: 18,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasShapeVariety: true,
    hasWind: true,
    hasBeamInstability: true,
    spawnInterval: 3.0,
    gravityY: 15.0,
  );

  static const level40 = CampaignLevel(
    number: 40,
    name: 'The Final Balance',
    description: 'Master all mechanics',
    targetShapes: 20,
    hasAutoSpawn: true,
    hasIncreasedGravity: true,
    hasShapeVariety: true,
    hasWind: true,
    hasBeamInstability: true,
    hasTimePressure: true,
    spawnInterval: 2.5,
    gravityY: 16.0,
  );
}
