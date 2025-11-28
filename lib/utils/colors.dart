import 'dart:ui';

import '../services/theme_service.dart';

class GameColors {
  // Dark mode colors
  static const _darkBackground = Color(0xFF0A0A0A);
  static const _darkBeam = Color(0xFFE8E8E8);
  static const _darkFulcrum = Color(0xFFE8E8E8);
  static const _darkShapeLight = Color(0xFF888888);
  static const _darkShapeMedium = Color(0xFF555555);
  static const _darkShapeHeavy = Color(0xFF333333);

  // Light mode colors
  static const _lightBackground = Color(0xFFF5F5F5);
  static const _lightBeam = Color(0xFF2A2A2A);
  static const _lightFulcrum = Color(0xFF2A2A2A);
  static const _lightShapeLight = Color(0xFFB0B0B0);
  static const _lightShapeMedium = Color(0xFF808080);
  static const _lightShapeHeavy = Color(0xFF505050);

  // Accent colors (same for both modes)
  static const accent = Color(0xFFC4A052);
  static const danger = Color(0xFF8B4049);

  // Dynamic getters based on current theme
  static Color get background => _isDark ? _darkBackground : _lightBackground;
  static Color get beam => _isDark ? _darkBeam : _lightBeam;
  static Color get fulcrum => _isDark ? _darkFulcrum : _lightFulcrum;
  static Color get shapeLight => _isDark ? _darkShapeLight : _lightShapeLight;
  static Color get shapeMedium => _isDark ? _darkShapeMedium : _lightShapeMedium;
  static Color get shapeHeavy => _isDark ? _darkShapeHeavy : _lightShapeHeavy;

  static bool get _isDark {
    try {
      return ThemeService.instance.isDarkMode;
    } catch (_) {
      // ThemeService not initialized yet, default to dark
      return true;
    }
  }
}
