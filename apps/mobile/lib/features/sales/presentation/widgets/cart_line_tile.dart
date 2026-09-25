import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../domain/entities/cart_line.dart';

/// One cart row: photo, name, unit price, line total and the stepper.
///
/// A line of a variant shows that variant's photo and its label
/// (`Azul · 40`) under the name, so two sizes of the same product read as two
/// different lines.
class CartLineTile extends StatelessWidget {
  const CartLineTile({
    required this.line,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    super.key,
  });

  final CartLine line;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String? variantLabel = line.variant?.label;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md + 2),
            child: AppImage(line.imagePath, height: 60, width: 60),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  line.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyStrong,
                ),
                if (variantLabel != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  VariantLabelTag(label: variantLabel),
                ],
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.l10n.salesCartLineUnitPrice(
                    MoneyFormatter.format(line.unitPrice),
                  ),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                MoneyFormatter.format(line.lineTotal),
                style: AppTextStyles.amountSm,
              ),
              const SizedBox(height: 6),
              QuantityStepper(
                quantity: line.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
                onRemove: onRemove,
                showRemoveAtOne: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small tag with the values of a variant (`Azul · 40`).
class VariantLabelTag extends StatelessWidget {
  const VariantLabelTag({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.captionSmallStrong.copyWith(
          color: AppColors.inkSoft,
        ),
      ),
    );
  }
}

/// Divider between cart rows.
class CartLineDivider extends StatelessWidget {
  const CartLineDivider({super.key});

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.dividerSoft);
}
