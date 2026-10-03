import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/stock_movement.dart';

/// Words and look of each [StockMovementType].
extension StockMovementTypeView on StockMovementType {
  String label(AppLocalizations l10n) => switch (this) {
    StockMovementType.initial => l10n.inventoryTypeInitial,
    StockMovementType.purchase => l10n.inventoryTypePurchase,
    StockMovementType.adjustment => l10n.inventoryTypeAdjustment,
    StockMovementType.sale => l10n.inventoryTypeSale,
    StockMovementType.cancellation => l10n.inventoryTypeCancellation,
    StockMovementType.saleReturn => l10n.inventoryTypeReturn,
  };

  IconData get icon => switch (this) {
    StockMovementType.initial => Icons.inventory_2_outlined,
    StockMovementType.purchase => Icons.move_to_inbox_rounded,
    StockMovementType.adjustment => Icons.tune_rounded,
    StockMovementType.sale => Icons.shopping_bag_outlined,
    StockMovementType.cancellation => Icons.undo_rounded,
    StockMovementType.saleReturn => Icons.assignment_return_outlined,
  };
}

extension AdjustmentReasonView on AdjustmentReason {
  String label(AppLocalizations l10n) => switch (this) {
    AdjustmentReason.count => l10n.inventoryReasonCount,
    AdjustmentReason.damage => l10n.inventoryReasonDamage,
    AdjustmentReason.loss => l10n.inventoryReasonLoss,
    AdjustmentReason.other => l10n.inventoryReasonOther,
  };
}

/// One movement: what, which product, when, who, and the units it moved.
class StockMovementTile extends StatelessWidget {
  const StockMovementTile({
    required this.movement,
    this.showProduct = true,
    super.key,
  });

  final StockMovement movement;

  /// Off on a product's own detail, where the name is already the title.
  final bool showProduct;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isIn = movement.delta > 0;
    final Color tint = isIn ? AppColors.successText : AppColors.errorText;
    final String? variant = movement.variantLabel;
    final String title = showProduct
        ? (variant == null
              ? movement.productName
              : l10n.salesVariantProductName(movement.productName, variant))
        : (variant ?? movement.type.label(l10n));
    final String detail = <String>[
      if (showProduct || variant != null) movement.type.label(l10n),
      if (movement.reason case final AdjustmentReason reason)
        reason.label(l10n),
      if (movement.note case final String note) note,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: isIn ? AppColors.successSurface : AppColors.errorSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(movement.type.icon, size: 20, color: tint),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmallStrong,
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSmall,
                  ),
                Text(
                  l10n.inventoryMovementWhen(
                    DateFormatter.shortDateTime(movement.createdAt),
                    movement.userName,
                  ),
                  style: AppTextStyles.captionSmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                isIn ? '+${movement.delta}' : '${movement.delta}',
                style: AppTextStyles.bodyStrong.copyWith(color: tint),
              ),
              Text(
                l10n.inventoryStockAfter(movement.stockAfter),
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
