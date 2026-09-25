import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_text_styles.dart';

/// Minus / value / plus control.
///
/// When [showRemoveAtOne] is set and the quantity is 1, the minus button turns
/// into a delete action, which is how cart lines are removed.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
    this.onRemove,
    this.showRemoveAtOne = false,
    this.buttonSize = 44,
    super.key,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onRemove;
  final bool showRemoveAtOne;
  final double buttonSize;

  bool get _removeInsteadOfDecrement =>
      showRemoveAtOne && quantity <= 1 && onRemove != null;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      height: buttonSize,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepperButton(
            size: buttonSize,
            icon: _removeInsteadOfDecrement
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: _removeInsteadOfDecrement
                ? AppColors.errorText
                : AppColors.textPrimary,
            tooltip: _removeInsteadOfDecrement
                ? l10n.commonQuantityRemoveTooltip
                : l10n.commonQuantityDecrementTooltip,
            onPressed: _removeInsteadOfDecrement ? onRemove! : onDecrement,
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLargeStrong,
            ),
          ),
          _StepperButton(
            size: buttonSize,
            icon: Icons.add_rounded,
            color: AppColors.white,
            background: AppColors.ink,
            tooltip: l10n.commonQuantityIncrementTooltip,
            onPressed: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.size,
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
    this.background,
  });

  final double size;
  final IconData icon;
  final Color color;
  final Color? background;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: background ?? Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox(
            height: size,
            width: size,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
  }
}
