import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/money_formatter.dart';

/// Label + input + optional helper text, the standard form row.
class LabeledField extends StatelessWidget {
  const LabeledField({
    required this.label,
    required this.child,
    this.helperText,
    this.optionalText,
    super.key,
  });

  final String label;
  final Widget child;
  final String? helperText;

  /// Rendered right after the label in a lighter weight, e.g. "(opcional)".
  final String? optionalText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: label,
            style: AppTextStyles.label,
            children: <InlineSpan>[
              if (optionalText != null)
                TextSpan(text: ' $optionalText', style: AppTextStyles.caption),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
        if (helperText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(helperText!, style: AppTextStyles.captionSmall),
        ],
      ],
    );
  }
}

/// Amount input with a fixed `Bs` prefix and oversized figures.
class AmountInputField extends StatelessWidget {
  const AmountInputField({
    required this.controller,
    this.fontSize = 32,
    this.height = 68,
    this.underlinedStyle = false,
    this.autofocus = false,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final double fontSize;
  final double height;

  /// Uses the bottom-border treatment of the cash-drawer screen instead of a
  /// full box.
  final bool underlinedStyle;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final Widget row = Row(
      crossAxisAlignment: underlinedStyle
          ? CrossAxisAlignment.baseline
          : CrossAxisAlignment.center,
      textBaseline: underlinedStyle ? TextBaseline.alphabetic : null,
      children: <Widget>[
        Text(
          MoneyFormatter.currencySymbol,
          style: AppTextStyles.amountMd.copyWith(
            fontSize: underlinedStyle ? 24 : 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: TextField(
            controller: controller,
            autofocus: autofocus,
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTextStyles.amountLg.copyWith(fontSize: fontSize),
            decoration: InputDecoration(
              isCollapsed: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              hintText: MoneyFormatter.amountOnly(0),
            ),
          ),
        ),
      ],
    );

    if (underlinedStyle) {
      return Container(
        padding: const EdgeInsets.only(top: 4, bottom: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.ink, width: 2)),
        ),
        child: row,
      );
    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.input,
        border: Border.all(color: AppColors.ink, width: 2),
      ),
      child: row,
    );
  }
}
