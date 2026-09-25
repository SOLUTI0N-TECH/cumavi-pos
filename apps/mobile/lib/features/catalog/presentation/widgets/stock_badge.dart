import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/stock_level.dart';
import '../view_data/stock_level_view_data.dart';

/// Stock indicator: units left, "Quedan n" or "Agotado", tinted by level.
class StockBadge extends StatelessWidget {
  /// Stock of the whole product (the sum of its variants when it has them).
  StockBadge({required Product product, this.height = 22, super.key})
    : quantity = product.stockQuantity;

  /// Any stock count: one variant or a group of them.
  const StockBadge.quantity({
    required this.quantity,
    this.height = 22,
    super.key,
  });

  final int quantity;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final StockLevel level = StockRules.levelFor(quantity);

    return StatusPill(
      label: switch (level) {
        StockLevel.healthy => l10n.catalogStockBadgeUnits(quantity),
        StockLevel.low => l10n.catalogStockBadgeLow(quantity),
        StockLevel.outOfStock => l10n.catalogStockBadgeOutOfStock,
      },
      background: level.badgeSurface,
      foreground: level.badgeText,
      height: height,
    );
  }
}
