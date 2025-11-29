import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cant/game/shape_size.dart';
import 'package:cant/screens/shape_picker.dart';

void main() {
  group('ShapePicker', () {
    Widget buildWidget({
      ShapeSize selectedSize = ShapeSize.medium,
      ValueChanged<ShapeSize>? onSizeChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: ShapePicker(
              selectedSize: selectedSize,
              onSizeChanged: onSizeChanged ?? (_) {},
            ),
          ),
        ),
      );
    }

    testWidgets('renders three shape buttons', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(ShapePicker), findsOneWidget);
      // Should have 3 GestureDetector buttons
      expect(find.byType(GestureDetector), findsNWidgets(3));
    });

    testWidgets('shows small button selected', (tester) async {
      await tester.pumpWidget(buildWidget(selectedSize: ShapeSize.small));

      final containers = tester.widgetList<Container>(find.byType(Container));
      // The selected button should have a border
      final smallContainer = containers.first;
      expect(smallContainer.decoration, isNotNull);
    });

    testWidgets('shows medium button selected', (tester) async {
      await tester.pumpWidget(buildWidget(selectedSize: ShapeSize.medium));

      expect(find.byType(ShapePicker), findsOneWidget);
    });

    testWidgets('shows large button selected', (tester) async {
      await tester.pumpWidget(buildWidget(selectedSize: ShapeSize.large));

      expect(find.byType(ShapePicker), findsOneWidget);
    });

    testWidgets('calls onSizeChanged when small button tapped', (tester) async {
      ShapeSize? selectedSize;
      await tester.pumpWidget(buildWidget(
        selectedSize: ShapeSize.medium,
        onSizeChanged: (size) => selectedSize = size,
      ));

      // Tap the first (smallest) button
      final gestures = find.byType(GestureDetector);
      await tester.tap(gestures.first);
      await tester.pump();

      expect(selectedSize, ShapeSize.small);
    });

    testWidgets('calls onSizeChanged when medium button tapped', (tester) async {
      ShapeSize? selectedSize;
      await tester.pumpWidget(buildWidget(
        selectedSize: ShapeSize.small,
        onSizeChanged: (size) => selectedSize = size,
      ));

      // Tap the middle button
      final gestures = find.byType(GestureDetector);
      await tester.tap(gestures.at(1));
      await tester.pump();

      expect(selectedSize, ShapeSize.medium);
    });

    testWidgets('calls onSizeChanged when large button tapped', (tester) async {
      ShapeSize? selectedSize;
      await tester.pumpWidget(buildWidget(
        selectedSize: ShapeSize.small,
        onSizeChanged: (size) => selectedSize = size,
      ));

      // Tap the last (largest) button
      final gestures = find.byType(GestureDetector);
      await tester.tap(gestures.last);
      await tester.pump();

      expect(selectedSize, ShapeSize.large);
    });

    testWidgets('buttons have different sizes', (tester) async {
      await tester.pumpWidget(buildWidget());

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(GestureDetector),
          matching: find.byType(Container),
        ),
      ).toList();

      // Small: 28, Medium: 36, Large: 44
      expect(containers[0].constraints?.maxWidth, 28);
      expect(containers[1].constraints?.maxWidth, 36);
      expect(containers[2].constraints?.maxWidth, 44);
    });
  });
}
