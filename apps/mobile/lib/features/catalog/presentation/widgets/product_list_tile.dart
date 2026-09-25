import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';
import 'stock_badge.dart';

/// Inventory row: photo, name, category and cost, the variants when the
/// product has them, price and stock badge.
class ProductListTile extends StatelessWidget {
  const ProductListTile({required this.product, this.onTap, super.key});

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 16, 10),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md + 2),
              child: AppImage(product.imagePath, height: 56, width: 56),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.l10n.catalogProductTileSubtitle(
                      product.category.name,
                      MoneyFormatter.formatCompact(product.costPrice),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSmall,
                  ),
                  if (product.hasVariants) _VariantSummary(product: product),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  MoneyFormatter.format(product.salePrice),
                  style: AppTextStyles.amountSm.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppSpacing.xs),
                StockBadge(product: product),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// `15 variantes · Color, Talla`. Its line box is as tall as the text, so
/// the three lines still fit next to the photo and rows with variants keep
/// the height of the others.
class _VariantSummary extends StatelessWidget {
  const _VariantSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Icon(
          Icons.layers_outlined,
          size: 12,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            context.l10n.catalogProductTileVariantSummary(
              product.variants.length,
              product.options
                  .map((VariantOption option) => option.name)
                  .join(', '),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.micro.copyWith(height: 1),
          ),
        ),
      ],
    );
  }
}
