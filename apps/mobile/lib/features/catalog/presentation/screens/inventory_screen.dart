import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/floating_nav_insets.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/stock_level.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../widgets/product_list_tile.dart';

/// Inventory tab: the product list with search, category filter and the
/// entry points to create a product or open one.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({
    required this.onCreateProduct,
    required this.onOpenProduct,
    super.key,
  });

  final VoidCallback onCreateProduct;
  final ValueChanged<Product> onOpenProduct;

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
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md + 2),
                    FilterChipBar<String?>(
                      selectedValue: state.selectedCategoryId,
                      onSelected: context.read<CatalogCubit>().categorySelected,
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
