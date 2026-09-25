import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../catalog/domain/entities/product.dart';

/// Category card with a sample photo, shown on the empty cart so the seller
/// can jump straight into the catalog filtered by category.
class CategoryShortcutTile extends StatelessWidget {
  const CategoryShortcutTile({
    required this.name,
    required this.productCount,
    required this.imagePath,
    required this.onTap,
    super.key,
  });

  final String name;
  final int productCount;
  final String imagePath;
  final VoidCallback onTap;

  /// Builds a tile per category out of [products], using the first product of
  /// each category as the cover.
  static List<CategoryShortcutTile> fromProducts(
    List<Product> products, {
    required void Function(String categoryId) onCategoryTap,
  }) {
    final Map<String, List<Product>> grouped = <String, List<Product>>{};
    for (final Product product in products) {
      grouped.putIfAbsent(product.category.id, () => <Product>[]).add(product);
    }

    return grouped.entries.map((MapEntry<String, List<Product>> entry) {
      final List<Product> categoryProducts = entry.value;
      return CategoryShortcutTile(
        name: categoryProducts.first.category.name,
        productCount: categoryProducts.length,
        imagePath: categoryProducts.first.imagePath,
        onTap: () => onCategoryTap(entry.key),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
                child: AppImage(imagePath, height: 78),
              ),
              const SizedBox(height: AppSpacing.sm + 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                    Text(
                      context.l10n.salesCategoryProductCount(productCount),
                      style: AppTextStyles.captionSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
