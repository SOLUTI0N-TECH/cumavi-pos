import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/entities/stock_level.dart';
import '../../domain/entities/cart.dart';
import '../view_data/variant_selection.dart';

/// Variant and number of units chosen in the [VariantPickerSheet].
final class VariantChoice extends Equatable {
  const VariantChoice({required this.variant, required this.quantity});

  final ProductVariant variant;
  final int quantity;

  @override
  List<Object?> get props => <Object?>[variant, quantity];
}

/// Asks which variant of a product to sell, one value per option
/// (`Color Azul` + `Talla 40`), and how many units.
///
/// Values with nothing left to add are struck through, and the stepper stops
/// at the units the cart does not hold yet, so the choice it returns can
/// always be added.
class VariantPickerSheet extends StatefulWidget {
  const VariantPickerSheet({
    required this.product,
    required this.cart,
    super.key,
  });

  final Product product;

  /// Current sale, to discount the units already in it.
  final Cart cart;

  /// Returns the choice, or `null` when dismissed.
  static Future<VariantChoice?> show(
    BuildContext context, {
    required Product product,
    required Cart cart,
  }) {
    return AppBottomSheet.show<VariantChoice>(
      context: context,
      title: context.l10n.salesVariantSheetTitle,
      builder: (_) => VariantPickerSheet(product: product, cart: cart),
    );
  }

  @override
  State<VariantPickerSheet> createState() => _VariantPickerSheetState();
}

class _VariantPickerSheetState extends State<VariantPickerSheet> {
  late VariantSelection _selection = VariantSelection.initial(
    widget.product,
    widget.cart,
  );
  int _quantity = 1;

  void _select(String option, String value) {
    setState(() {
      _selection = _selection.select(option, value);
      // A new variant may have fewer units left than already counted.
      _quantity = _quantity.clamp(1, math.max(1, _selection.remaining));
    });
  }

  void _increment() {
    if (_quantity >= _selection.remaining) return;
    setState(() => _quantity++);
  }

  void _decrement() {
    if (_quantity <= 1) return;
    setState(() => _quantity--);
  }

  void _confirm() {
    final ProductVariant? variant = _selection.variant;
    if (variant == null || !_selection.canAdd) return;
    Navigator.of(context)
        .pop(VariantChoice(variant: variant, quantity: _quantity));
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final Product product = widget.product;
    final bool canAdd = _selection.canAdd;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ProductSummary(selection: _selection),
        const SizedBox(height: AppSpacing.lg),
        const Divider(height: 1, color: AppColors.dividerSoft),
        const SizedBox(height: AppSpacing.lg),
        // Many values could outgrow short phones: only the options scroll,
        // the quantity and the button stay in view.
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.4,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (final VariantOption option in product.options)
                  _OptionGroup(
                    option: option,
                    selection: _selection,
                    onSelected: (String value) => _select(option.name, value),
                  ),
              ],
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                l10n.salesVariantQuantityLabel,
                style: AppTextStyles.label,
              ),
            ),
            // Nothing to count until the choice has units left.
            IgnorePointer(
              ignoring: !canAdd,
              child: Opacity(
                opacity: canAdd ? 1 : 0.4,
                child: QuantityStepper(
                  quantity: _quantity,
                  onIncrement: _increment,
                  onDecrement: _decrement,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.salesVariantAddButton(
            MoneyFormatter.format(product.salePrice * _quantity),
          ),
          icon: Icons.add_shopping_cart_rounded,
          onPressed: canAdd ? _confirm : null,
        ),
      ],
    );
  }
}

/// Photo of the current choice, name, price and what is left of it.
class _ProductSummary extends StatelessWidget {
  const _ProductSummary({required this.selection});

  static const double _photoSize = 104;

  final VariantSelection selection;

  @override
  Widget build(BuildContext context) {
    final Product product = selection.product;

    return Row(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: SizedBox.square(
            dimension: _photoSize,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: AppImage(
                selection.imagePath,
                key: ValueKey<String>(selection.imagePath),
                width: _photoSize,
                height: _photoSize,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLargeStrong,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                MoneyFormatter.format(product.salePrice),
                style: AppTextStyles.amountSm,
              ),
              const SizedBox(height: AppSpacing.sm),
              _StockStatus(selection: selection),
            ],
          ),
        ),
      ],
    );
  }
}

/// What is left of the chosen variant, net of the units already in the cart,
/// or which option is still missing.
class _StockStatus extends StatelessWidget {
  const _StockStatus({required this.selection});

  static const double _pillHeight = 26;

  final VariantSelection selection;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ProductVariant? variant = selection.variant;

    if (variant == null) {
      final VariantOption? missing = selection.missingOption;
      return Text(
        missing == null ? '' : l10n.salesVariantMissingOption(missing.name),
        style: AppTextStyles.caption,
      );
    }
    if (!variant.isAvailable) {
      return StatusPill(
        label: l10n.salesProductSoldOutBadge,
        background: AppColors.errorSurface,
        foreground: AppColors.errorText,
        height: _pillHeight,
      );
    }
    if (!selection.canAdd) {
      return Text(
        l10n.salesVariantAllInCart(variant.stockQuantity),
        style: AppTextStyles.caption.copyWith(color: AppColors.errorText),
      );
    }

    final int remaining = selection.remaining;
    final bool isLow = StockRules.levelFor(remaining) == StockLevel.low;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        StatusPill(
          label: isLow
              ? l10n.catalogStockBadgeLow(remaining)
              : l10n.salesProductInStock(remaining),
          background: isLow ? AppColors.warningSurface : AppColors.divider,
          foreground: isLow ? AppColors.warningText : AppColors.inkSoft,
          height: _pillHeight,
        ),
        if (selection.inCart > 0)
          StatusPill(
            label: l10n.salesVariantInCart(selection.inCart),
            icon: Icons.check_rounded,
            background: AppColors.ink,
            foreground: AppColors.white,
            height: _pillHeight,
          ),
      ],
    );
  }
}

/// Name of an option and its values as chips.
class _OptionGroup extends StatelessWidget {
  const _OptionGroup({
    required this.option,
    required this.selection,
    required this.onSelected,
  });

  final VariantOption option;
  final VariantSelection selection;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(option.name, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final String value in option.values)
                VariantValueChip(
                  label: value,
                  isSelected: selection.values[option.name] == value,
                  availability: selection.availabilityOf(option.name, value),
                  onSelected: () => onSelected(value),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One value of an option (`Azul`, `40`).
///
/// Values that cannot be added with the other choices are struck through but
/// still tappable (choosing one drops the conflicting choices); values with
/// nothing left at all are disabled.
class VariantValueChip extends StatelessWidget {
  const VariantValueChip({
    required this.label,
    required this.isSelected,
    required this.availability,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VariantValueAvailability availability;
  final VoidCallback onSelected;

  bool get isEnabled => availability != VariantValueAvailability.soldOut;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = availability.isAvailable;
    final Color background = isSelected
        ? AppColors.ink
        : isAvailable
        ? AppColors.surface
        : AppColors.surfaceMuted;
    final Color borderColor = isSelected
        ? AppColors.ink
        : isAvailable
        ? AppColors.borderSoft
        : AppColors.divider;
    final Color foreground = isSelected
        ? AppColors.white
        : isAvailable
        ? AppColors.textPrimary
        : AppColors.textPlaceholder;
    final BorderRadius radius = BorderRadius.circular(AppRadius.md);

    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: isAvailable
          ? label
          : context.l10n.salesVariantValueUnavailable(label),
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: isEnabled ? onSelected : null,
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: borderColor),
            ),
            // Sized to the label: the chips flow in a Wrap.
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: foreground,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                  decorationColor: foreground,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
