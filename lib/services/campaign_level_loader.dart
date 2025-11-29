import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../game/campaign_level.dart';

/// Service to load campaign levels from JSON asset file
class CampaignLevelLoader {
  static const String _assetPath = 'assets/data/campaign_levels.json';

  static CampaignLevelLoader? _instance;
  static List<CampaignLevel>? _levels;

  CampaignLevelLoader._();

  static CampaignLevelLoader get instance {
    _instance ??= CampaignLevelLoader._();
    return _instance!;
  }

  /// Reset singleton for testing
  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
    _levels = null;
  }

  /// Get all loaded levels (must call loadLevels first)
  List<CampaignLevel> get levels {
    if (_levels == null) {
      throw StateError('Levels not loaded. Call loadLevels() first.');
    }
    return _levels!;
  }

  /// Check if levels have been loaded
  bool get isLoaded => _levels != null;

  /// Load levels from JSON asset
  Future<List<CampaignLevel>> loadLevels() async {
    if (_levels != null) return _levels!;

    final jsonString = await rootBundle.loadString(_assetPath);
    final jsonData = json.decode(jsonString) as Map<String, dynamic>;
    final levelsJson = jsonData['levels'] as List<dynamic>;

    _levels = levelsJson.map((levelJson) => _parseLevelJson(levelJson as Map<String, dynamic>)).toList();
    return _levels!;
  }

  /// Parse JSON into CampaignLevel
  CampaignLevel _parseLevelJson(Map<String, dynamic> json) {
    return CampaignLevel(
      number: json['number'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      targetHeight: (json['targetHeight'] as num).toDouble(),
      hasAutoSpawn: json['hasAutoSpawn'] as bool? ?? false,
      hasIncreasedGravity: json['hasIncreasedGravity'] as bool? ?? false,
      hasWind: json['hasWind'] as bool? ?? false,
      hasShapeVariety: json['hasShapeVariety'] as bool? ?? false,
      hasBeamInstability: json['hasBeamInstability'] as bool? ?? false,
      hasTimePressure: json['hasTimePressure'] as bool? ?? false,
      spawnInterval: (json['spawnInterval'] as num?)?.toDouble() ?? 5.0,
      gravityY: (json['gravityY'] as num?)?.toDouble() ?? 10.0,
      beamDamping: (json['beamDamping'] as num?)?.toDouble(),
      beamFriction: (json['beamFriction'] as num?)?.toDouble(),
    );
  }

  /// Get level by number (1-indexed)
  CampaignLevel? getLevelByNumber(int number) {
    if (_levels == null) return null;
    try {
      return _levels!.firstWhere((l) => l.number == number);
    } catch (_) {
      return null;
    }
  }

  /// Validate loaded levels match expected structure
  List<String> validateLevels() {
    final errors = <String>[];
    if (_levels == null) {
      errors.add('Levels not loaded');
      return errors;
    }

    // Check level count
    if (_levels!.length != 40) {
      errors.add('Expected 40 levels, got ${_levels!.length}');
    }

    // Check sequential numbering
    for (int i = 0; i < _levels!.length; i++) {
      if (_levels![i].number != i + 1) {
        errors.add('Level at index $i has number ${_levels![i].number}, expected ${i + 1}');
      }
    }

    // Validate each level
    for (final level in _levels!) {
      if (level.name.isEmpty) {
        errors.add('Level ${level.number} has empty name');
      }
      if (level.description.isEmpty) {
        errors.add('Level ${level.number} has empty description');
      }
      if (level.targetHeight <= 0) {
        errors.add('Level ${level.number} has invalid targetHeight: ${level.targetHeight}');
      }
      if (level.spawnInterval <= 0) {
        errors.add('Level ${level.number} has invalid spawnInterval: ${level.spawnInterval}');
      }
      if (level.gravityY <= 0) {
        errors.add('Level ${level.number} has invalid gravityY: ${level.gravityY}');
      }
    }

    return errors;
  }
}
