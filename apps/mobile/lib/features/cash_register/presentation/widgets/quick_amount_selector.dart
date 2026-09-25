import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';

/// Row of preset amounts (opening float, cash received).
class QuickAmountSelector extends StatelessWidget {
  const QuickAmountSelector({
    required this.amounts,
    required this.selectedAmount,
    required this.onAmountSelected,
    this.leadingLabel,
    this.onLeadingSelected,
    super.key,
  });

  final List<double> amounts;
  final double? selectedAmount;
  final ValueChanged<double> onAmountSelected;

  /// Optional first chip with its own action, e.g. "Exacto".
  final String? leadingLabel;
  final VoidCallback? onLeadingSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (leadingLabel != null) ...<Widget>[
          Expanded(
            child: _AmountChip(
              label: leadingLabel!,
              isSelected: false,
              onTap: onLeadingSelected ?? () {},
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        for (int index = 0; index < amounts.length; index++) ...<Widget>[
          Expanded(
            child: _AmountChip(
              label: MoneyFormatter.formatCompact(amounts[index]),
              isSelected: selectedAmount == amounts[index],
              onTap: () => onAmountSelected(amounts[index]),
            ),
          ),
          if (index != amounts.length - 1) const SizedBox(width: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  const _AmountChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.ink : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.md + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        child: Container(
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md + 2),
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.divider,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
