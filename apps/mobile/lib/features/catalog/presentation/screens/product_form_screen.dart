import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/tinted_banner.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/services/photo_capturer.dart';
import '../cubit/product_form_cubit.dart';
import '../cubit/product_form_state.dart';
import '../widgets/photo_source_sheet.dart';
import '../widgets/product_gallery_field.dart';
import '../widgets/product_photo_field.dart';
import '../widgets/product_stock_section.dart';

/// Product form, to create a product or edit one ([productId]): main photo
/// with background removal, more photos, data, price and cost, and the
/// stock, either single or per variant (talla, color…) with its own photo.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({
    this.productId,
    required this.onClose,
    required this.onSaved,
    required this.onAdjustPhoto,
    super.key,
  });

  /// Product to edit; `null` creates a new one.
  final String? productId;
  final VoidCallback onClose;

  /// Called with the stored product so the caller can refresh the list.
  final void Function(Product product) onSaved;
  final VoidCallback onAdjustPhoto;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  /// Whether the fields already show the product being edited. They are
  /// filled once: afterwards the seller's typing is the source of truth.
  bool _prefilled = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductFormCubit>().load(productId: widget.productId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _prefill(ProductFormState state) {
    String amount(double? value) =>
        value == null ? '' : MoneyFormatter.amountOnly(value);

    _nameController.text = state.name;
    _descriptionController.text = state.description;
    _priceController.text = amount(state.salePrice);
    _costController.text = amount(state.costPrice);
    _prefilled = true;
  }

  /// The product to edit could not be read: there is nothing to show.
  bool _loadFailed(ProductFormState state) =>
      state.isEditing &&
      !_prefilled &&
      state.status == ProductFormStatus.failure;

  Future<void> _pickPhoto(ProductFormCubit cubit) async {
    final PhotoSource? source = await PhotoSourceSheet.show(context);
    if (source != null) await cubit.capturePhoto(source);
  }

  Future<void> _addGalleryPhoto(ProductFormCubit cubit) async {
    final PhotoSource? source = await ProductGalleryField.pickSource(context);
    if (source != null) await cubit.addImage(source);
  }

  void _onStateChanged(BuildContext context, ProductFormState state) {
    if (state.isEditing &&
        !_prefilled &&
        state.status == ProductFormStatus.editing) {
      _prefill(state);
    }
    if (state.status == ProductFormStatus.saved && state.savedProduct != null) {
      widget.onSaved(state.savedProduct!);
    }
    // A failed load already explains itself in place of the form.
    if (state.status == ProductFormStatus.failure &&
        state.failure != null &&
        !_loadFailed(state)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.failure!.localizedMessage(context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ProductFormCubit, ProductFormState>(
          listener: _onStateChanged,
          builder: (BuildContext context, ProductFormState state) {
            final bool isLoading = state.status == ProductFormStatus.loading;
            final bool loadFailed = _loadFailed(state);

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: PushedScreenHeader(
                    title: state.isEditing
                        ? l10n.catalogProductFormEditTitle
                        : l10n.catalogProductFormTitle,
                    onBack: widget.onClose,
                    isCloseAction: true,
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : loadFailed
                      ? _LoadError(
                          state: state,
                          onRetry: () => context.read<ProductFormCubit>().load(
                            productId: widget.productId,
                          ),
                        )
                      : _buildForm(context, state),
                ),
                if (!isLoading && !loadFailed)
                  _FormFooter(
                    label: state.isEditing
                        ? l10n.catalogProductFormSaveChanges
                        : l10n.catalogProductFormSave,
                    isSaving: state.status == ProductFormStatus.submitting,
                    onSave: state.canSubmit
                        ? context.read<ProductFormCubit>().submit
                        : null,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ProductFormState state) {
    final ProductFormCubit cubit = context.read<ProductFormCubit>();
    final AppLocalizations l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        ProductPhotoField(
          photo: state.photo,
          removeBackground: state.removeBackground,
          isProcessing: state.status == ProductFormStatus.removingBackground,
          onCapture: () => _pickPhoto(cubit),
          onAdjust: widget.onAdjustPhoto,
          onToggleBackground: cubit.toggleBackgroundRemoval,
        ),
        const SizedBox(height: AppSpacing.md),
        ProductGalleryField(
          images: state.extraImages,
          onAdd: () => _addGalleryPhoto(cubit),
          onRemove: cubit.removeImage,
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: l10n.catalogProductFormDataSection,
          children: <Widget>[
            LabeledField(
              label: l10n.catalogProductFormNameLabel,
              child: TextField(
                controller: _nameController,
                onChanged: cubit.nameChanged,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.catalogProductFormNameHint,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LabeledField(
              label: l10n.catalogProductFormCategoryLabel,
              child: _CategoryDropdown(
                categories: state.categories,
                selectedId: state.categoryId,
                onChanged: cubit.categorySelected,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LabeledField(
              label: l10n.catalogProductFormDescriptionLabel,
              optionalText: l10n.catalogProductFormOptional,
              child: TextField(
                controller: _descriptionController,
                onChanged: cubit.descriptionChanged,
                minLines: 2,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: l10n.catalogProductFormDescriptionHint,
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.textPlaceholder,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _SectionCard(
          title: l10n.catalogProductFormPriceSection,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: LabeledField(
                    label: l10n.catalogProductFormSalePriceLabel,
                    child: _PriceField(
                      controller: _priceController,
                      onChanged: (String value) => cubit.salePriceChanged(
                        MoneyFormatter.tryParse(value),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: LabeledField(
                    label: l10n.catalogProductFormCostLabel,
                    child: _PriceField(
                      controller: _costController,
                      onChanged: (String value) => cubit.costPriceChanged(
                        MoneyFormatter.tryParse(value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (state.hasProfitInfo) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              TintedBanner(
                title: l10n.catalogProductFormProfitTitle,
                background: AppColors.successSurface,
                foreground: AppColors.successTextStrong,
                trailingText: l10n.catalogProductFormProfitValue(
                  MoneyFormatter.format(state.unitProfit),
                  MoneyFormatter.formatPercent(state.profitMargin),
                ),
                trailingStyle: AppTextStyles.bodyStrong.copyWith(
                  color: AppColors.successTextStrong,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        ProductStockSection(state: state),
      ],
    );
  }
}

/// White card with a title, for each block of the form.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: AppTextStyles.bodyLargeStrong),
          const SizedBox(height: AppSpacing.lg),
          ...children,
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.state, required this.onRetry});

  final ProductFormState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.inventory_2_outlined,
          title: l10n.catalogProductFormLoadErrorTitle,
          message: state.failure?.localizedMessage(l10n) ?? '',
          action: SecondaryButton(
            label: l10n.commonRetry,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ),
      ),
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  const _CategoryDropdown({
    required this.categories,
    required this.selectedId,
    required this.onChanged,
  });

  final List<ProductCategory> categories;
  final String? selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedId,
      isExpanded: true,
      icon: const Icon(Icons.expand_more_rounded),
      style: AppTextStyles.bodyLarge,
      items: categories
          .map(
            (ProductCategory category) => DropdownMenuItem<String>(
              value: category.id,
              child: Text(category.name),
            ),
          )
          .toList(),
      onChanged: (String? value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _PriceField extends StatelessWidget {
  const _PriceField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: AppTextStyles.bodyLargeStrong,
      decoration: InputDecoration(
        hintText: MoneyFormatter.amountOnly(0),
        prefixText: '${MoneyFormatter.currencySymbol} ',
        prefixStyle: AppTextStyles.bodyStrong.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _FormFooter extends StatelessWidget {
  const _FormFooter({
    required this.label,
    required this.isSaving,
    required this.onSave,
  });

  final String label;
  final bool isSaving;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.md,
        AppSpacing.pageHorizontal,
        AppSpacing.xl,
      ),
      child: PrimaryButton(
        label: label,
        icon: Icons.check_rounded,
        isLoading: isSaving,
        onPressed: onSave,
      ),
    );
  }
}
