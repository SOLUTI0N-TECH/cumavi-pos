import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// One segment of a [SegmentedSelector].
class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Equal-width single-choice control (email/phone, paper size, file format).
class SegmentedSelector<T> extends StatelessWidget {
  const SegmentedSelector({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.height = 52,
    this.selectedColor = AppColors.surface,
    this.selectedTextColor = AppColors.textPrimary,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double height;
  final Color selectedColor;
  final Color selectedTextColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        // Each segment fills the track's height; otherwise the selected
        // pill shrinks to the height of its label.
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: options.map((SegmentOption<T> option) {
          final bool isSelected = option.value == selectedValue;
          return Expanded(
            child: Material(
              color: isSelected ? selectedColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: InkWell(
                onTap: () => onSelected(option.value),
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (option.icon != null) ...<Widget>[
                      Icon(
                        option.icon,
                        size: 18,
                        color: isSelected
                            ? selectedTextColor
                            : AppColors.inkSoft,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      option.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? selectedTextColor
                            : AppColors.inkSoft,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
