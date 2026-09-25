import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/stock_level.dart';

/// Catalog card used while selling: photo, stock, price and the add button.
///
/// Products already in the cart show a charcoal badge with their quantity
/// (all their variants together). Products sold in variants say how many
/// they have, since their add button asks which one first.
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    required this.product,
    required this.quantityInCart,
    required this.onAdd,
    super.key,
  });

  final Product product;
  final int quantityInCart;
  final VoidCallback onAdd;

  bool get _isInCart => quantityInCart > 0;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isSellable = product.isSellable;

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl - 2),
        border: Border.all(
          color: _isInCart ? AppColors.ink : AppColors.surface,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: _ProductImage(
                      imagePath: product.imagePath,
                      // Out-of-stock products are greyed out so they read as
                      // unavailable without hiding them.
                      isDimmed: !isSellable,
                    ),
                  ),
                ),
                if (_isInCart)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _Badge(
                      label: '$quantityInCart',
                      icon: Icons.check_rounded,
                      background: AppColors.ink,
                      foreground: AppColors.white,
                    ),
                  ),
                if (!isSellable)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: _Badge(
                      label: l10n.salesProductSoldOutBadge,
                      background: AppColors.errorSurface,
                      foreground: AppColors.errorText,
                    ),
                  ),
                if (product.hasVariants)
                  Positioned(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.sm,
                    child: _Badge(
                      label: l10n.salesVariantCount(product.variants.length),
                      icon: Icons.tune_rounded,
                      background: AppColors.surface,
                      foreground: AppColors.inkSoft,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmallStrong.copyWith(
                    color: isSellable
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  isSellable
                      ? l10n.salesProductInStock(product.stockQuantity)
                      : l10n.salesProductOutOfStock,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: product.stockLevel == StockLevel.low
                        ? AppColors.warningText
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              const SizedBox(width: 6),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    MoneyFormatter.formatCompact(product.salePrice),
                    style: AppTextStyles.amountSm.copyWith(
                      fontSize: 18,
                      color: isSellable
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: isSellable ? onAdd : null,
                tooltip: product.hasVariants
                    ? l10n.salesVariantChooseTooltip(product.name)
                    : l10n.salesProductAddTooltip(product.name),
                icon: const Icon(Icons.add_rounded, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.ink,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.divider,
                  disabledForegroundColor: AppColors.textPlaceholder,
                  minimumSize: const Size(40, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md + 2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.imagePath, required this.isDimmed});

  final String imagePath;
  final bool isDimmed;

  @override
  Widget build(BuildContext context) {
    final Widget image = AppImage(imagePath);
    if (!isDimmed) return image;

    return Opacity(
      opacity: 0.45,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 1, 0, //
        ]),
        child: image,
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: AppTextStyles.captionSmallStrong.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}
