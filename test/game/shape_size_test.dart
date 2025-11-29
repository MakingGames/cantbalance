import 'package:flutter_test/flutter_test.dart';
import 'package:cant/game/shape_size.dart';
import 'package:cant/game/constants.dart';
import 'package:cant/utils/colors.dart';

void main() {
  group('ShapeSize', () {
    group('enum values', () {
      test('has 3 sizes', () {
        expect(ShapeSize.values.length, equals(3));
      });

      test('includes small, medium, large', () {
        expect(ShapeSize.values, contains(ShapeSize.small));
        expect(ShapeSize.values, contains(ShapeSize.medium));
        expect(ShapeSize.values, contains(ShapeSize.large));
      });
    });

    group('size property', () {
      test('small returns shapeSmallSize', () {
        expect(ShapeSize.small.size, equals(GameConstants.shapeSmallSize));
      });

      test('medium returns shapeMediumSize', () {
        expect(ShapeSize.medium.size, equals(GameConstants.shapeMediumSize));
      });

      test('large returns shapeLargeSize', () {
        expect(ShapeSize.large.size, equals(GameConstants.shapeLargeSize));
      });

      test('sizes are progressively larger', () {
        expect(ShapeSize.small.size, lessThan(ShapeSize.medium.size));
        expect(ShapeSize.medium.size, lessThan(ShapeSize.large.size));
      });
    });

    group('density property', () {
      test('small returns shapeSmallDensity', () {
        expect(ShapeSize.small.density, equals(GameConstants.shapeSmallDensity));
      });

      test('medium returns shapeMediumDensity', () {
        expect(ShapeSize.medium.density, equals(GameConstants.shapeMediumDensity));
      });

      test('large returns shapeLargeDensity', () {
        expect(ShapeSize.large.density, equals(GameConstants.shapeLargeDensity));
      });

      test('densities are progressively heavier', () {
        expect(ShapeSize.small.density, lessThan(ShapeSize.medium.density));
        expect(ShapeSize.medium.density, lessThan(ShapeSize.large.density));
      });
    });

    group('color property', () {
      test('small returns shapeLight', () {
        expect(ShapeSize.small.color, equals(GameColors.shapeLight));
      });

      test('medium returns shapeMedium', () {
        expect(ShapeSize.medium.color, equals(GameColors.shapeMedium));
      });

      test('large returns shapeHeavy', () {
        expect(ShapeSize.large.color, equals(GameColors.shapeHeavy));
      });

      test('each size has a unique color', () {
        expect(ShapeSize.small.color, isNot(equals(ShapeSize.medium.color)));
        expect(ShapeSize.medium.color, isNot(equals(ShapeSize.large.color)));
        expect(ShapeSize.small.color, isNot(equals(ShapeSize.large.color)));
      });
    });
  });
}
