import 'dart:ui';

import 'constants.dart';
import '../utils/colors.dart';

enum ShapeSize {
  small,
  medium,
  large,
}

extension ShapeSizeExtension on ShapeSize {
  double get size {
    switch (this) {
      case ShapeSize.small:
        return GameConstants.shapeSmallSize;
      case ShapeSize.medium:
        return GameConstants.shapeMediumSize;
      case ShapeSize.large:
        return GameConstants.shapeLargeSize;
    }
  }

  double get density {
    switch (this) {
      case ShapeSize.small:
        return GameConstants.shapeSmallDensity;
      case ShapeSize.medium:
        return GameConstants.shapeMediumDensity;
      case ShapeSize.large:
        return GameConstants.shapeLargeDensity;
    }
  }

  Color get color {
    switch (this) {
      case ShapeSize.small:
        return GameColors.shapeLight;
      case ShapeSize.medium:
        return GameColors.shapeMedium;
      case ShapeSize.large:
        return GameColors.shapeHeavy;
    }
  }
}
