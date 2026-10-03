import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/floating_nav_insets.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_code_match.dart';
import '../../domain/entities/stock_level.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../scanner/barcode_camera.dart';
import '../widgets/product_list_tile.dart';

/// Inventory tab: the product list with search, category filter and the
/// entry points to create a product or open one.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    required this.onCreateProduct,
    required this.onOpenProduct,
    required this.onManageCategories,
    this.onScan,
    this.onCreateWithBarcode,
    this.onReceiveStock,
    super.key,
  });

  final VoidCallback onCreateProduct;
  final ValueChanged<Product> onOpenProduct;
  final VoidCallback onManageCategories;

  /// Opens the scanner; without it the search has no scan button.
  final ScanCode? onScan;

  /// Creates a product with a barcode no product has yet.
  final ValueChanged<String>? onCreateWithBarcode;

  /// "Ingreso de mercadería"; without it the header has no button.
  final VoidCallback? onReceiveStock;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().load();
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  /// Opens the scanned product, or offers to create one with that code.
  Future<void> _scan(ScanCode scan) async {
    final CatalogCubit cubit = context.read<CatalogCubit>();
    final String? code = await scan();
    if (code == null || !mounted) return;

    switch (await cubit.findByCode(code)) {
      case Success<ProductCodeMatch>(:final ProductCodeMatch value):
        if (mounted) widget.onOpenProduct(value.product);
      case Failed<ProductCodeMatch>(:final Failure failure):
        if (!mounted) return;
        final ValueChanged<String>? create = widget.onCreateWithBarcode;
        if (failure.code == FailureCode.productCodeNotFound && create != null) {
          final bool? confirmed = await showModalBottomSheet<bool>(
            context: context,
            builder: (BuildContext sheetContext) =>
                _UnknownCodeSheet(code: code),
          );
          if ((confirmed ?? false) && mounted) create(code);
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(failure.localizedMessage(context.l10n))),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CatalogCubit, CatalogState>(
          builder: (BuildContext context, CatalogState state) {
            return Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        0,
                      ),
                      child: ScreenHeader(
                        title: l10n.catalogInventoryTitle,
                        subtitleWidget: _InventorySubtitle(state: state),
                        trailing: switch (widget.onReceiveStock) {
                          final VoidCallback receive => IconButton.filledTonal(
                            tooltip: l10n.inventoryReceiveTitle,
                            onPressed: receive,
                            icon: const Icon(Icons.move_to_inbox_rounded),
                          ),
                          null => null,
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.pageHorizontal,
                      ),
                      child: AppSearchField(
                        hintText: l10n.catalogInventorySearchHint,
                        controller: _queryController,
                        onChanged: context.read<CatalogCubit>().queryChanged,
                        trailing: switch (widget.onScan) {
                          final ScanCode scan => IconButton(
                            tooltip: l10n.commonScanBarcodeTooltip,
                            onPressed: () => _scan(scan),
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 20,
                            ),
                          ),
                          null => null,
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md + 2),
                    FilterChipBar<String?>(
                      selectedValue: state.selectedCategoryId,
                      onSelected: context.read<CatalogCubit>().categorySelected,
                      trailing: ActionChip(
                        onPressed: widget.onManageCategories,
                        avatar: const Icon(Icons.tune_rounded, size: 18),
                        label: Text(l10n.catalogCategoriesManage),
                        backgroundColor: AppColors.surface,
                        side: const BorderSide(color: AppColors.borderSoft),
                        shape: const StadiumBorder(),
                      ),
                      options: <FilterChipOption<String?>>[
                        FilterChipOption<String?>(
                          value: null,
                          label: l10n.catalogInventoryFilterAll,
                        ),
                        for (final ProductCategory category in state.categories)
                          FilterChipOption<String?>(
                            value: category.id,
                            label: category.name,
                            badge: '${state.categoryCounts[category.id] ?? 0}',
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md + 2),
                    Expanded(
                      child: _InventoryList(
                        state: state,
                        onOpenProduct: widget.onOpenProduct,
                      ),
                    ),
                  ],
                ),
                Positioned(
                  right: AppSpacing.pageHorizontal,
                  bottom: context.bottomNavClearance,
                  child: _CreateProductButton(
                    onPressed: widget.onCreateProduct,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// A scanned code no product has: create one with it?
class _UnknownCodeSheet extends StatelessWidget {
  const _UnknownCodeSheet({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(
              Icons.qr_code_2_rounded,
              size: 40,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.catalogScanUnknownTitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLargeStrong,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.catalogScanUnknownMessage(code),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              label: l10n.catalogScanUnknownCreate,
              icon: Icons.add_rounded,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySubtitle extends StatelessWidget {
  const _InventorySubtitle({required this.state});

  final CatalogState state;

  @override
  Widget build(BuildContext context) {
    final int lowStockCount = state.products
        .where((Product product) => product.stockLevel != StockLevel.healthy)
        .length;
    final AppLocalizations l10n = context.l10n;

    return Text.rich(
      TextSpan(
        text: l10n.catalogInventoryProductCount(state.products.length),
        style: AppTextStyles.caption,
        children: <InlineSpan>[
          if (lowStockCount > 0)
            TextSpan(
              text: l10n.catalogInventoryLowStockSuffix(lowStockCount),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.warningText,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Extended action placed above the floating navigation bar.
class _CreateProductButton extends StatelessWidget {
  const _CreateProductButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x4D292526),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
        border: Border.all(color: AppColors.background, width: 4),
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: Text(context.l10n.catalogInventoryCreateProduct),
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 58),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          textStyle: AppTextStyles.bodyLargeStrong.copyWith(fontSize: 17),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
        ),
      ),
    );
  }
}

class _InventoryList extends StatelessWidget {
  const _InventoryList({required this.state, required this.onOpenProduct});

  final CatalogState state;
  final ValueChanged<Product> onOpenProduct;

  @override
  Widget build(BuildContext context) {
    if (state.status == CatalogStatus.loading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.products.isEmpty) {
      final AppLocalizations l10n = context.l10n;
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.inventory_2_outlined,
          title: l10n.catalogInventoryEmptyTitle,
          message: l10n.catalogInventoryEmptyMessage,
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        // Also clears the floating "Crear producto" button.
        context.bottomNavClearance + 60,
      ),
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          child: Column(
            children: <Widget>[
              for (final Product product in state.products) ...<Widget>[
                ProductListTile(
                  product: product,
                  onTap: () => onOpenProduct(product),
                ),
                if (product != state.products.last)
                  const Divider(height: 1, color: AppColors.dividerSoft),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
