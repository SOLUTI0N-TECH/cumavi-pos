import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/usecases/product_code_rules.dart';

/// A product and, when it varies, the variant picked.
typedef PickedProduct = ({Product product, ProductVariant? variant});

/// Picks a product to receive: search by name or code, then the variant.
abstract final class ProductPickerSheet {
  static Future<PickedProduct?> show(
    BuildContext context, {
    required List<Product> products,
  }) async {
    final Product? product = await AppBottomSheet.show<Product>(
      context: context,
      title: context.l10n.inventoryPickProductTitle,
      builder: (_) => _ProductSearch(products: products),
    );
    if (product == null || !context.mounted) return null;
    if (!product.hasVariants) return (product: product, variant: null);
    final ProductVariant? variant = await pickVariant(context, product);
    return variant == null ? null : (product: product, variant: variant);
  }

  /// Asks which variant of [product].
  static Future<ProductVariant?> pickVariant(
    BuildContext context,
    Product product,
  ) {
    final AppLocalizations l10n = context.l10n;
    return AppBottomSheet.show<ProductVariant>(
      context: context,
      title: product.name,
      subtitle: l10n.inventoryPickVariantSubtitle,
      builder: (BuildContext sheetContext) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.55,
        ),
        // The sheet paints its own background: the tiles' ripples need a
        // Material above it.
        child: Material(
          type: MaterialType.transparency,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              for (final ProductVariant variant in product.variants)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(variant.label, style: AppTextStyles.bodyStrong),
                  trailing: Text(
                    l10n.catalogStockBadgeUnits(variant.stockQuantity),
                    style: AppTextStyles.captionSmall,
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(variant),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSearch extends StatefulWidget {
  const _ProductSearch({required this.products});

  final List<Product> products;

  @override
  State<_ProductSearch> createState() => _ProductSearchState();
}

class _ProductSearchState extends State<_ProductSearch> {
  String _query = '';

  List<Product> get _matches {
    final String text = TextNormalizer.normalize(_query);
    final String code = ProductCodeRules.normalize(_query);
    if (text.isEmpty) return widget.products;
    return widget.products
        .where(
          (Product product) =>
              TextNormalizer.normalize(product.name).contains(text) ||
              (product.sku?.contains(code) ?? false) ||
              (product.barcode?.contains(code) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final List<Product> matches = _matches;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            autofocus: true,
            onChanged: (String value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: l10n.inventoryPickProductHint,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.45,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final Product product in matches)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox.square(
                          dimension: 44,
                          child: AppImage(product.imagePath),
                        ),
                      ),
                      title: Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyStrong,
                      ),
                      subtitle: Text(
                        l10n.catalogStockBadgeUnits(product.stockQuantity),
                        style: AppTextStyles.captionSmall,
                      ),
                      trailing: product.hasVariants
                          ? const Icon(Icons.chevron_right_rounded)
                          : null,
                      onTap: () => Navigator.of(context).pop(product),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
