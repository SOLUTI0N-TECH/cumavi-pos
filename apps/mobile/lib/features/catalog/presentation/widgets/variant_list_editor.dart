import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../domain/entities/product_variant.dart';

/// Stock and photo of every variant, one row per combination of values.
///
/// With [groupBy] (`Color` in `Color × Talla`) the rows are grouped by that
/// type's values, so 3 colors × 5 sizes read as three short lists instead of
/// fifteen loose rows.
class VariantListEditor extends StatelessWidget {
  const VariantListEditor({
    required this.variants,
    required this.imagePathOf,
    required this.onPickImage,
    required this.onEditCodes,
    required this.onIncrement,
    required this.onDecrement,
    this.groupBy,
    this.stockReadOnly = false,
    super.key,
  });

  final List<ProductVariant> variants;

  /// Shows the stock without steppers (editing a product).
  final bool stockReadOnly;

  /// Photo a variant shows; `null` when the product has none yet.
  final String? Function(ProductVariant variant) imagePathOf;
  final ValueChanged<ProductVariant> onPickImage;

  /// Opens the SKU and barcode of a variant.
  final ValueChanged<ProductVariant> onEditCodes;

  /// Called with the id of the variant.
  final ValueChanged<String> onIncrement;
  final ValueChanged<String> onDecrement;
  final String? groupBy;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? groupBy = this.groupBy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          l10n.catalogVariantListTitle(variants.length),
          style: AppTextStyles.bodyStrong,
        ),
        Text(l10n.catalogVariantListCaption, style: AppTextStyles.captionSmall),
        const SizedBox(height: AppSpacing.md),
        if (groupBy == null)
          _VariantGroup(
            variants: variants,
            labelOf: (ProductVariant variant) => variant.label,
            row: _row,
          )
        else
          for (final (int index, MapEntry<String, List<ProductVariant>> group)
              in _groups(groupBy).entries.indexed) ...<Widget>[
            if (index > 0) const SizedBox(height: AppSpacing.md),
            _VariantGroup(
              title: group.key,
              variants: group.value,
              // The group title already says the grouped value.
              labelOf: (ProductVariant variant) => variant.optionValues.entries
                  .where(
                    (MapEntry<String, String> entry) => entry.key != groupBy,
                  )
                  .map((MapEntry<String, String> entry) => entry.value)
                  .join(' · '),
              row: _row,
            ),
          ],
      ],
    );
  }

  /// Variants per value of [option], in the order of the values.
  Map<String, List<ProductVariant>> _groups(String option) {
    final Map<String, List<ProductVariant>> groups =
        <String, List<ProductVariant>>{};
    for (final ProductVariant variant in variants) {
      final String value = variant.optionValues[option] ?? '';
      (groups[value] ??= <ProductVariant>[]).add(variant);
    }
    return groups;
  }

  Widget _row(ProductVariant variant, String label) {
    return _VariantRow(
      label: label,
      fullLabel: variant.label,
      imagePath: imagePathOf(variant),
      stock: variant.stockQuantity,
      codes: <String?>[
        variant.sku,
        variant.barcode,
      ].whereType<String>().join(' · '),
      onPickImage: () => onPickImage(variant),
      onEditCodes: () => onEditCodes(variant),
      onIncrement: () => onIncrement(variant.id),
      onDecrement: () => onDecrement(variant.id),
      stockReadOnly: stockReadOnly,
    );
  }
}

/// Tinted box with the rows of one group and, when grouped, its value and
/// stock as a header.
class _VariantGroup extends StatelessWidget {
  const _VariantGroup({
    required this.variants,
    required this.labelOf,
    required this.row,
    this.title,
  });

  final String? title;
  final List<ProductVariant> variants;
  final String Function(ProductVariant variant) labelOf;
  final Widget Function(ProductVariant variant, String label) row;

  @override
  Widget build(BuildContext context) {
    final int stock = variants.fold(
      0,
      (int total, ProductVariant variant) => total + variant.stockQuantity,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(title!, style: AppTextStyles.bodySmallStrong),
                  ),
                  Text(
                    context.l10n.catalogStockBadgeUnits(stock),
                    style: AppTextStyles.captionSmallStrong,
                  ),
                ],
              ),
            ),
          for (int index = 0; index < variants.length; index++) ...<Widget>[
            if (index > 0) const Divider(),
            row(variants[index], labelOf(variants[index])),
          ],
        ],
      ),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.label,
    required this.fullLabel,
    required this.imagePath,
    required this.stock,
    required this.codes,
    required this.onPickImage,
    required this.onEditCodes,
    required this.onIncrement,
    required this.onDecrement,
    required this.stockReadOnly,
  });

  /// What the row shows (without the grouped value).
  final String label;

  /// Every value, for the photo tooltip.
  final String fullLabel;
  final String? imagePath;
  final int stock;

  /// `SKU · barcode`, empty when the variant has none.
  final String codes;
  final VoidCallback onPickImage;
  final VoidCallback onEditCodes;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool stockReadOnly;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          _VariantThumbnail(
            path: imagePath,
            tooltip: context.l10n.catalogVariantPhotoTooltip(fullLabel),
            onTap: onPickImage,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: InkWell(
              onTap: onEditCodes,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyStrong,
                    ),
                    Text(
                      codes.isEmpty
                          ? context.l10n.catalogVariantAddCodes
                          : codes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: codes.isEmpty
                            ? AppColors.infoText
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (stockReadOnly)
            Text(
              context.l10n.catalogStockBadgeUnits(stock),
              style: AppTextStyles.bodyStrong,
            )
          else
            QuantityStepper(
              quantity: stock,
              buttonSize: 38,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
        ],
      ),
    );
  }
}

class _VariantThumbnail extends StatelessWidget {
  const _VariantThumbnail({
    required this.path,
    required this.tooltip,
    required this.onTap,
  });

  static const double _size = 44;

  final String? path;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String? path = this.path;
    final BorderRadius radius = BorderRadius.circular(AppRadius.md);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            height: _size,
            width: _size,
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: AppColors.divider),
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: path == null
                  ? const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    )
                  : AppImage(path),
            ),
          ),
        ),
      ),
    );
  }
}
