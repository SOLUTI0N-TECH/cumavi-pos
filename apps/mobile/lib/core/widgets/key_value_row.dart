import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// `label ............ value` row used in every summary block.
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({
    required this.label,
    required this.value,
    this.labelStyle,
    this.valueStyle,
    this.emphasize = false,
    super.key,
  });

  final String label;
  final String value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  /// Renders both sides in the strong style used for totals.
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style:
                labelStyle ??
                (emphasize
                    ? AppTextStyles.bodyStrong
                    : AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      )),
          ),
        ),
        Text(
          value,
          style:
              valueStyle ??
              (emphasize
                  ? AppTextStyles.amountSm.copyWith(fontSize: 20)
                  : AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
        ),
      ],
    );
  }
}
