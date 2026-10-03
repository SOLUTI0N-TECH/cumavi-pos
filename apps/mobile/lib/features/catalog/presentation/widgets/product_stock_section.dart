import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/tinted_banner.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/services/photo_capturer.dart';
import '../cubit/product_form_cubit.dart';
import '../cubit/product_form_state.dart';
import '../scanner/barcode_camera.dart';
import 'product_gallery_field.dart';
import 'variant_codes_sheet.dart';
import 'variant_image_sheet.dart';
import 'variant_list_editor.dart';
import 'variant_options_editor.dart';
import 'variant_type_sheet.dart';

/// "Stock y variantes" card of the product form.
///
/// A simple product has a single stock. Once the seller adds variant types
/// (talla, color…), every combination of their values gets its own stock
/// and photo, and the product's stock is their sum.
class ProductStockSection extends StatelessWidget {
  const ProductStockSection({
    required this.state,
    this.onScanBarcode,
    super.key,
  });

  /// More types multiply the combinations beyond what a seller can manage
  /// from the phone (3 × 5 × 4 = 60 rows).
  static const int maxVariantTypes = 3;

  final ProductFormState state;

  /// Scans a variant's barcode in its codes sheet.
  final ScanCode? onScanBarcode;

  Future<void> _editCodes(
    BuildContext context,
    ProductFormCubit cubit,
    ProductVariant variant,
  ) async {
    final VariantCodes? codes = await VariantCodesSheet.show(
      context,
      variant: variant,
      onScan: onScanBarcode,
    );
    if (codes == null) return;
    cubit.variantCodesChanged(
      variant.id,
      sku: codes.sku,
      barcode: codes.barcode,
    );
  }

  Future<void> _addType(BuildContext context, ProductFormCubit cubit) async {
    final String? name = await VariantTypeSheet.showAdd(
      context,
      existingNames: state.options
          .map((VariantOption option) => option.name)
          .toList(),
    );
    if (name != null) cubit.addOption(name);
  }

  Future<void> _pickVariantImage(
    BuildContext context,
    ProductFormCubit cubit,
    ProductVariant variant,
  ) async {
    final String? groupingOption = state.groupingOption;
    final VariantImageChoice? choice = await VariantImageSheet.show(
      context,
      variantLabel: variant.label,
      mainImagePath: state.photo?.displayPath,
      mainImageId: state.mainImageId,
      extraImages: state.extraImages,
      selectedImageId: variant.imageId,
      groupValue: groupingOption == null
          ? null
          : variant.optionValues[groupingOption],
    );
    if (choice == null) return;
    final String? sharedOption = choice.applyToGroup ? groupingOption : null;

    if (!choice.addNew) {
      cubit.variantImageSelected(
        variant.id,
        choice.imageId,
        sharedOption: sharedOption,
      );
      return;
    }

    if (!context.mounted) return;
    final PhotoSource? source = await ProductGalleryField.pickSource(context);
    if (source == null) return;
    final int photosBefore = cubit.state.extraImages.length;
    await cubit.addImage(source);
    // The new photo goes to the end of the gallery.
    if (cubit.state.extraImages.length > photosBefore) {
      cubit.variantImageSelected(
        variant.id,
        cubit.state.extraImages.last.id,
        sharedOption: sharedOption,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ProductFormCubit cubit = context.read<ProductFormCubit>();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  l10n.catalogProductFormStockSection,
                  style: AppTextStyles.bodyLargeStrong,
                ),
              ),
              if (state.hasVariants)
                StatusPill(
                  label: l10n.catalogProductFormTotalStock(state.totalStock),
                  background: AppColors.successSurface,
                  foreground: AppColors.successTextStrong,
                  height: 28,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (state.isEditing) ...<Widget>[
            TintedBanner(
              title: l10n.catalogProductFormStockLockedTitle,
              subtitle: l10n.catalogProductFormStockLockedCaption,
              background: AppColors.infoSurface,
              foreground: AppColors.infoText,
              icon: Icons.lock_outline_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (state.options.isEmpty) ...<Widget>[
            _SimpleStockRow(
              quantity: state.stockQuantity,
              readOnly: state.isEditing,
              onIncrement: cubit.incrementQuantity,
              onDecrement: cubit.decrementQuantity,
            ),
            const SizedBox(height: AppSpacing.lg),
            TintedBanner(
              title: l10n.catalogProductFormAddVariants,
              subtitle: l10n.catalogProductFormAddVariantsCaption,
              background: AppColors.background,
              foreground: AppColors.textPrimary,
              icon: Icons.layers_outlined,
              onTap: () => _addType(context, cubit),
              showChevron: true,
            ),
          ] else ...<Widget>[
            VariantOptionsEditor(
              options: state.options,
              onAddValue: cubit.addOptionValue,
              onRemoveValue: cubit.removeOptionValue,
              onRename: cubit.renameOption,
              onRemove: cubit.removeOption,
            ),
            if (state.options.length < maxVariantTypes)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _addType(context, cubit),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.catalogVariantAddAnotherType),
                ),
              ),
            if (state.hasVariants) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              VariantListEditor(
                variants: state.variants,
                groupBy: state.groupingOption,
                imagePathOf: state.imagePathOf,
                onPickImage: (ProductVariant variant) =>
                    _pickVariantImage(context, cubit, variant),
                onEditCodes: (ProductVariant variant) =>
                    _editCodes(context, cubit, variant),
                onIncrement: cubit.incrementVariantStock,
                onDecrement: cubit.decrementVariantStock,
                stockReadOnly: state.isEditing,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Stock of a product without variants.
class _SimpleStockRow extends StatelessWidget {
  const _SimpleStockRow({
    required this.quantity,
    required this.readOnly,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final bool readOnly;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.catalogProductFormQuantityLabel,
                style: AppTextStyles.label,
              ),
              Text(
                l10n.catalogProductFormQuantityCaption,
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ),
        if (readOnly)
          Text(
            l10n.catalogStockBadgeUnits(quantity),
            style: AppTextStyles.bodyLargeStrong,
          )
        else
          QuantityStepper(
            quantity: quantity,
            onIncrement: onIncrement,
            onDecrement: onDecrement,
          ),
      ],
    );
  }
}
