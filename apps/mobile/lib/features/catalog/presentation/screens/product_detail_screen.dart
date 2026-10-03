import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../../core/widgets/tinted_banner.dart';
import '../../../inventory/domain/entities/stock_movement.dart';
import '../../../inventory/presentation/widgets/stock_movement_tile.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/stock_level.dart';
import '../cubit/product_detail_cubit.dart';
import '../view_data/stock_level_view_data.dart';
import '../widgets/stock_badge.dart';

/// Everything about one product: photos, prices, stock and variants, with
/// the way into its edit form.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({
    required this.onBack,
    required this.onEdit,
    required this.onReceiveStock,
    required this.onAdjustStock,
    required this.onOpenMovements,
    super.key,
  });

  final VoidCallback onBack;

  /// Opens the edit form; completes when the seller comes back.
  final Future<void> Function() onEdit;

  /// "Ingreso": a goods receipt with this product.
  final VoidCallback onReceiveStock;

  /// "Ajustar": add, remove or count units with a reason.
  final VoidCallback onAdjustStock;

  /// Every stock movement of this product.
  final VoidCallback onOpenMovements;

  void _edit() => unawaited(onEdit());

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocConsumer<ProductDetailCubit, ProductDetailState>(
          // A failed refresh keeps the product on screen, so it is reported
          // with a snack bar instead of the empty state.
          listenWhen:
              (ProductDetailState previous, ProductDetailState current) =>
                  current.status == ProductDetailStatus.failure &&
                  current.product != null,
          listener: (BuildContext context, ProductDetailState state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
            );
          },
          builder: (BuildContext context, ProductDetailState state) {
            final Product? product = state.product;

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
                    title: l10n.catalogDetailTitle,
                    onBack: onBack,
                    trailing: product == null
                        ? null
                        : _HeaderActions(
                            isRefreshing:
                                state.status == ProductDetailStatus.loading,
                            onEdit: _edit,
                          ),
                  ),
                ),
                Expanded(
                  child: product == null
                      ? _MissingProduct(state: state)
                      : _ProductDetails(
                          product: product,
                          movements: state.movements,
                          actions: _StockActions(
                            onReceive: onReceiveStock,
                            onAdjust: onAdjustStock,
                            onOpenMovements: onOpenMovements,
                          ),
                        ),
                ),
                if (product != null) _EditFooter(onEdit: _edit),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Pencil shortcut to the edit form, with a small spinner while the product
/// refreshes (after coming back from editing it).
class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.isRefreshing, required this.onEdit});

  final bool isRefreshing;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (isRefreshing) ...<Widget>[
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        CircleActionButton(
          icon: Icons.edit_outlined,
          tooltip: context.l10n.catalogDetailEdit,
          onPressed: onEdit,
        ),
      ],
    );
  }
}

/// First load in progress, or the product could not be loaded at all.
class _MissingProduct extends StatelessWidget {
  const _MissingProduct({required this.state});

  final ProductDetailState state;

  @override
  Widget build(BuildContext context) {
    if (state.status != ProductDetailStatus.failure) {
      return const Center(child: CircularProgressIndicator());
    }

    final AppLocalizations l10n = context.l10n;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.inventory_2_outlined,
          title: l10n.catalogDetailLoadErrorTitle,
          message:
              state.failure?.localizedMessage(l10n) ?? l10n.failureUnexpected,
          action: OutlinedButton.icon(
            onPressed: () =>
                unawaited(context.read<ProductDetailCubit>().load()),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(l10n.commonRetry),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(180, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the stock card and the movements card can open.
final class _StockActions {
  const _StockActions({
    required this.onReceive,
    required this.onAdjust,
    required this.onOpenMovements,
  });

  final VoidCallback onReceive;
  final VoidCallback onAdjust;
  final VoidCallback onOpenMovements;
}

class _ProductDetails extends StatelessWidget {
  const _ProductDetails({
    required this.product,
    required this.movements,
    required this.actions,
  });

  final Product product;
  final List<StockMovement> movements;
  final _StockActions actions;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _PhotoGallery(images: product.images),
          const SizedBox(height: AppSpacing.lg),
          _OverviewCard(product: product),
          const SizedBox(height: AppSpacing.md),
          _PricesCard(product: product),
          const SizedBox(height: AppSpacing.md),
          _StockCard(product: product, actions: actions),
          const SizedBox(height: AppSpacing.md),
          _MovementsCard(movements: movements, actions: actions),
          if (product.sku != null || product.barcode != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _CodesCard(product: product),
          ],
          if (product.description.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _SectionCard(
              title: context.l10n.catalogDetailDescriptionTitle,
              child: Text(
                product.description.trim(),
                style: AppTextStyles.body.copyWith(height: 1.45),
              ),
            ),
          ],
          if (product.hasVariants) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            _VariantsCard(product: product),
          ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            context.l10n.catalogDetailCreatedAt(product.createdAt),
            textAlign: TextAlign.center,
            style: AppTextStyles.captionSmall,
          ),
        ],
      ),
    );
  }
}

/// Swipeable main photo with page dots and, when there are several photos,
/// thumbnails that jump to each one.
class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.images});

  final List<ProductImage> images;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void didUpdateWidget(covariant _PhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);
    // An edit may remove photos; the page view then settles on the last
    // one, so the dots and thumbnails follow it.
    if (widget.images.isNotEmpty && _page >= widget.images.length) {
      _page = widget.images.length - 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show(int index) {
    unawaited(
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductImage> images = widget.images;
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          child: ColoredBox(
            color: AppColors.surface,
            child: AspectRatio(
              aspectRatio: 1,
              child: images.isEmpty
                  ? const Icon(
                      Icons.image_not_supported_outlined,
                      size: 40,
                      color: AppColors.textSecondary,
                    )
                  : Stack(
                      children: <Widget>[
                        PageView.builder(
                          controller: _controller,
                          itemCount: images.length,
                          onPageChanged: (int page) =>
                              setState(() => _page = page),
                          itemBuilder: (BuildContext context, int index) =>
                              AppImage(images[index].path),
                        ),
                        if (images.length > 1)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: AppSpacing.md,
                            child: Center(
                              child: _PageDots(
                                count: images.length,
                                current: _page,
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ),
        if (images.length > 1) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: _Thumbnail.size,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) => _Thumbnail(
                path: images[index].path,
                label: l10n.catalogDetailPhotoLabel(index + 1, images.length),
                isSelected: index == _page,
                onTap: () => _show(index),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Current photo of the gallery, drawn over the photo itself.
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (int index = 0; index < count; index++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 6,
                width: index == current ? 16 : 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: index == current
                      ? AppColors.white
                      : AppColors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  static const double size = 64;

  final String path;

  /// "Foto 2 de 3", read by screen readers.
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: size,
          width: size,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.divider,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: AppImage(path),
          ),
        ),
      ),
    );
  }
}

/// Category, name and stock at a glance.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(product.category.name, style: AppTextStyles.captionSmallStrong),
          const SizedBox(height: AppSpacing.xxs),
          Text(product.name, style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              StockBadge(product: product, height: 28),
              if (product.hasVariants)
                StatusPill(
                  label: context.l10n.catalogDetailVariantCount(
                    product.variants.length,
                  ),
                  icon: Icons.layers_outlined,
                  background: AppColors.surfaceMuted,
                  height: 28,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// White block with a section title, used by every part of the detail.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(title, style: AppTextStyles.bodyLargeStrong),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: AppSpacing.md + 2),
          child,
        ],
      ),
    );
  }
}

/// SKU and barcode of the product; each variant shows its own in the
/// variants card.
class _CodesCard extends StatelessWidget {
  const _CodesCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    Widget line(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SelectableText(value, style: AppTextStyles.bodySmallStrong),
        ],
      ),
    );

    return _SectionCard(
      title: l10n.catalogProductFormCodesSection,
      child: Column(
        children: <Widget>[
          if (product.sku case final String sku)
            line(l10n.catalogProductFormSkuLabel, sku),
          if (product.barcode case final String barcode)
            line(l10n.catalogProductFormBarcodeLabel, barcode),
        ],
      ),
    );
  }
}

/// Sale price and cost side by side, then the profit per unit and margin.
class _PricesCard extends StatelessWidget {
  const _PricesCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return _SectionCard(
      title: l10n.catalogDetailPricesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: _PriceFigure(
                  label: l10n.catalogProductFormSalePriceLabel,
                  amount: product.salePrice,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _PriceFigure(
                  label: l10n.catalogProductFormCostLabel,
                  amount: product.costPrice,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TintedBanner(
            title: l10n.catalogProductFormProfitTitle,
            background: AppColors.successSurface,
            foreground: AppColors.successTextStrong,
            trailingText: l10n.catalogProductFormProfitValue(
              MoneyFormatter.format(product.unitProfit),
              MoneyFormatter.formatPercent(product.profitMargin),
            ),
            trailingStyle: AppTextStyles.bodyStrong.copyWith(
              color: AppColors.successTextStrong,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceFigure extends StatelessWidget {
  const _PriceFigure({required this.label, required this.amount});

  final String label;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.captionSmall,
            ),
            const SizedBox(height: AppSpacing.xxs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                MoneyFormatter.format(amount),
                style: AppTextStyles.amountSm.copyWith(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Units in stock, tinted by level, and how many variants are sold out.
class _StockCard extends StatelessWidget {
  const _StockCard({required this.product, required this.actions});

  final Product product;
  final _StockActions actions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final int units = product.stockQuantity;
    final int soldOut = product.variants
        .where((ProductVariant variant) => !variant.isAvailable)
        .length;

    return _SectionCard(
      title: l10n.catalogDetailStockTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '$units',
                style: AppTextStyles.amountLg.copyWith(
                  color: product.stockLevel == StockLevel.healthy
                      ? AppColors.textPrimary
                      : product.stockLevel.badgeText,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.catalogDetailStockUnits(units),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (product.hasVariants) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            KeyValueRow(
              label: l10n.catalogDetailStockSoldOutLabel,
              value: '$soldOut',
              valueStyle: soldOut == 0
                  ? null
                  : AppTextStyles.bodySmallStrong.copyWith(
                      color: AppColors.errorText,
                    ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: actions.onReceive,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.inventoryAddStock),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: actions.onAdjust,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: Text(l10n.inventoryAdjust),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The latest movements of the product and a way to see them all.
class _MovementsCard extends StatelessWidget {
  const _MovementsCard({required this.movements, required this.actions});

  final List<StockMovement> movements;
  final _StockActions actions;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return _SectionCard(
      title: l10n.inventoryMovementsTitle,
      trailing: movements.isEmpty
          ? null
          : TextButton(
              onPressed: actions.onOpenMovements,
              child: Text(l10n.inventorySeeAll),
            ),
      child: movements.isEmpty
          ? Text(
              l10n.inventoryNoMovements,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : Column(
              children: <Widget>[
                for (int i = 0; i < movements.length; i++) ...<Widget>[
                  if (i > 0) const Divider(height: 1),
                  StockMovementTile(movement: movements[i], showProduct: false),
                ],
              ],
            ),
    );
  }
}

/// The ways the product varies and every variant with its stock. With two
/// or more options the variants are grouped by the first one (a color with
/// its photo, then its sizes); otherwise they form a single list.
class _VariantsCard extends StatelessWidget {
  const _VariantsCard({required this.product});

  final Product product;

  /// `SKU · barcode` of a variant, empty without codes.
  static String _codesOf(ProductVariant variant) =>
      <String?>[variant.sku, variant.barcode].whereType<String>().join(' · ');

  /// Values shown on a row: all of them, or the ones after the group's.
  static String _rowLabel(ProductVariant variant, {String? groupedBy}) =>
      variant.optionValues.entries
          .where((MapEntry<String, String> entry) => entry.key != groupedBy)
          .map((MapEntry<String, String> entry) => entry.value)
          .join(' · ');

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    // Photos only tell variants apart when some of them have their own.
    final bool showPhotos = product.variants.any(
      (ProductVariant variant) => variant.imageId != null,
    );
    final String? groupedBy = product.options.length >= 2
        ? product.options.first.name
        : null;

    return _SectionCard(
      title: l10n.catalogDetailVariantsTitle,
      trailing: Text(
        l10n.catalogDetailVariantCount(product.variants.length),
        style: AppTextStyles.captionSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (product.options.isNotEmpty) ...<Widget>[
            _OptionsSummary(product: product),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (groupedBy == null)
            _VariantRows(
              children: <Widget>[
                for (final ProductVariant variant in product.variants)
                  _VariantRow(
                    label: _rowLabel(variant),
                    quantity: variant.stockQuantity,
                    photoPath: showPhotos ? product.imagePathOf(variant) : null,
                    codes: _codesOf(variant),
                  ),
              ],
            )
          else
            for (final (int index, MapEntry<String, List<ProductVariant>> group)
                in _groupBy(groupedBy).entries.indexed) ...<Widget>[
              if (index > 0) const SizedBox(height: AppSpacing.lg),
              _VariantGroup(
                value: group.key,
                photoPath: showPhotos
                    ? product.imagePathOf(group.value.first)
                    : null,
                variants: group.value,
                rows: <Widget>[
                  for (final ProductVariant variant in group.value)
                    _VariantRow(
                      label: _rowLabel(variant, groupedBy: groupedBy),
                      quantity: variant.stockQuantity,
                      codes: _codesOf(variant),
                    ),
                ],
              ),
            ],
        ],
      ),
    );
  }

  /// Variants by their value of [optionName], in the product's order.
  Map<String, List<ProductVariant>> _groupBy(String optionName) {
    final Map<String, List<ProductVariant>> groups =
        <String, List<ProductVariant>>{};
    for (final ProductVariant variant in product.variants) {
      (groups[variant.optionValues[optionName] ?? ''] ??= <ProductVariant>[])
          .add(variant);
    }
    return groups;
  }
}

/// `Color  Rojo, Azul, Negro` / `Talla  38, 39, 40`, names aligned.
class _OptionsSummary extends StatelessWidget {
  const _OptionsSummary({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
        child: Table(
          columnWidths: const <int, TableColumnWidth>{
            0: IntrinsicColumnWidth(),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <TableRow>[
            for (final VariantOption option in product.options)
              TableRow(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      right: AppSpacing.lg,
                      bottom: 6,
                    ),
                    child: Text(option.name, style: AppTextStyles.label),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      option.values.join(', '),
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// One value of the first option (a color): its photo, how many of its
/// variants are sold out and its subtotal, then a row per variant.
class _VariantGroup extends StatelessWidget {
  const _VariantGroup({
    required this.value,
    required this.photoPath,
    required this.variants,
    required this.rows,
  });

  final String value;
  final String? photoPath;
  final List<ProductVariant> variants;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final int subtotal = variants.fold(
      0,
      (int total, ProductVariant variant) => total + variant.stockQuantity,
    );
    final int soldOut = variants
        .where((ProductVariant variant) => !variant.isAvailable)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            if (photoPath != null) ...<Widget>[
              _VariantPhoto(path: photoPath!, caption: value, size: 48),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyStrong,
                  ),
                  Text(
                    context.l10n.catalogDetailGroupSoldOut(soldOut),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StockBadge.quantity(quantity: subtotal, height: 26),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _VariantRows(children: rows),
      ],
    );
  }
}

/// Muted block holding variant rows separated by hairlines.
class _VariantRows extends StatelessWidget {
  const _VariantRows({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: <Widget>[
            for (int index = 0; index < children.length; index++) ...<Widget>[
              if (index > 0) const Divider(color: AppColors.divider),
              children[index],
            ],
          ],
        ),
      ),
    );
  }
}

/// A variant's values with a dot and a badge tinted by its stock level.
class _VariantRow extends StatelessWidget {
  const _VariantRow({
    required this.label,
    required this.quantity,
    this.photoPath,
    this.codes = '',
  });

  final String label;
  final int quantity;
  final String? photoPath;

  /// `SKU · barcode`, empty when the variant has none.
  final String codes;

  @override
  Widget build(BuildContext context) {
    final StockLevel level = StockRules.levelFor(quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: <Widget>[
          if (photoPath != null) ...<Widget>[
            _VariantPhoto(path: photoPath!, caption: label, size: 40),
            const SizedBox(width: AppSpacing.md),
          ],
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: level.indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmallStrong.copyWith(
                    color: level.isSellable
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (codes.isNotEmpty)
                  Text(
                    codes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSmall,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          StockBadge.quantity(quantity: quantity),
        ],
      ),
    );
  }
}

/// Small photo of a variant; tapping it shows the photo larger.
class _VariantPhoto extends StatelessWidget {
  const _VariantPhoto({
    required this.path,
    required this.caption,
    required this.size,
  });

  final String path;

  /// Shown under the enlarged photo: `Rojo`, `Roja`, `Rojo · 40`.
  final String caption;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.catalogDetailViewPhotoTooltip,
      child: GestureDetector(
        onTap: () => unawaited(
          showDialog<void>(
            context: context,
            builder: (BuildContext context) =>
                _PhotoPreviewDialog(path: path, caption: caption),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AppImage(path, height: size, width: size),
        ),
      ),
    );
  }
}

class _PhotoPreviewDialog extends StatelessWidget {
  const _PhotoPreviewDialog({required this.path, required this.caption});

  final String path;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AspectRatio(aspectRatio: 1, child: AppImage(path)),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(caption, style: AppTextStyles.bodyLargeStrong),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: context.l10n.commonCloseTooltip,
                  icon: const Icon(Icons.close_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.background,
                    minimumSize: const Size(44, 44),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed bottom bar with the main action, above the phone's gesture area.
class _EditFooter extends StatelessWidget {
  const _EditFooter({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: AppSpacing.xl),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            0,
          ),
          child: PrimaryButton(
            label: context.l10n.catalogDetailEdit,
            icon: Icons.edit_outlined,
            onPressed: onEdit,
          ),
        ),
      ),
    );
  }
}
