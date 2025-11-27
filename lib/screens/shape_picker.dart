import 'package:flutter/material.dart';
import '../game/shape_size.dart';
import '../utils/colors.dart';

class ShapePicker extends StatelessWidget {
  final ShapeSize selectedSize;
  final ValueChanged<ShapeSize> onSizeChanged;

  const ShapePicker({
    super.key,
    required this.selectedSize,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ShapeButton(
          size: ShapeSize.small,
          isSelected: selectedSize == ShapeSize.small,
          onTap: () => onSizeChanged(ShapeSize.small),
        ),
        const SizedBox(width: 12),
        _ShapeButton(
          size: ShapeSize.medium,
          isSelected: selectedSize == ShapeSize.medium,
          onTap: () => onSizeChanged(ShapeSize.medium),
        ),
        const SizedBox(width: 12),
        _ShapeButton(
          size: ShapeSize.large,
          isSelected: selectedSize == ShapeSize.large,
          onTap: () => onSizeChanged(ShapeSize.large),
        ),
      ],
    );
  }
}

class _ShapeButton extends StatelessWidget {
  final ShapeSize size;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShapeButton({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  double get _buttonSize {
    switch (size) {
      case ShapeSize.small:
        return 28;
      case ShapeSize.medium:
        return 36;
      case ShapeSize.large:
        return 44;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _buttonSize,
        height: _buttonSize,
        decoration: BoxDecoration(
          color: size.color,
          border: isSelected
              ? Border.all(color: GameColors.beam, width: 2)
              : null,
        ),
      ),
    );
  }
}
