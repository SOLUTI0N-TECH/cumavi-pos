import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_category.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../catalog/presentation/cubit/catalog_state.dart';
import '../../domain/entities/cart.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../views/sale_view.dart';
import '../widgets/product_grid_card.dart';
import '../widgets/variant_picker_sheet.dart';

/// Full-screen catalog opened from the sale search bar: search, filter by
/// category and add products to the cart.
class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({
    required this.onBack,
    this.initialCategoryId,
    super.key,
  });

  final VoidCallback onBack;
  final String? initialCategoryId;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _queryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().load(categoryId: widget.initialCategoryId);
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  /// One tap adds a simple product; a product with variants first asks
  /// which one and how many units.
  Future<void> _addProduct(Product product) async {
    final CartCubit cartCubit = context.read<CartCubit>();
    if (!product.hasVariants) {
      if (!cartCubit.addProduct(product)) {
        showStockLimitMessage(context, product);
      }
      return;
    }

    final VariantChoice? choice = await VariantPickerSheet.show(
      context,
      product: product,
      cart: cartCubit.state.cart,
    );
    if (choice == null || !mounted) return;
    final bool added = cartCubit.addProduct(
      product,
      variant: choice.variant,
      quantity: choice.quantity,
    );
    if (added) {
      showVariantAddedMessage(context, product, choice);
    } else {
      showStockLimitMessage(context, product, variant: choice.variant);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: Row(
                children: <Widget>[
                  CircleActionButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: l10n.salesSearchBackTooltip,
                    onPressed: widget.onBack,
                    size: 56,
                  ),
                  const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: AppSearchField(
                      hintText: l10n.salesSearchHint,
                      controller: _queryController,
                      focused: true,
                      onChanged: context.read<CatalogCubit>().queryChanged,
                      trailing: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            BlocBuilder<CatalogCubit, CatalogState>(
              buildWhen: (CatalogState previous, CatalogState current) =>
                  previous.categories != current.categories ||
                  previous.selectedCategoryId != current.selectedCategoryId ||
                  previous.categoryCounts != current.categoryCounts,
              builder: (BuildContext context, CatalogState state) {
                return FilterChipBar<String?>(
                  selectedValue: state.selectedCategoryId,
                  onSelected: context.read<CatalogCubit>().categorySelected,
                  options: <FilterChipOption<String?>>[
                    FilterChipOption<String?>(
                      value: null,
                      label: l10n.salesSearchAllCategories,
                    ),
                    for (final ProductCategory category in state.categories)
                      FilterChipOption<String?>(
                        value: category.id,
                        label: category.name,
                        badge: '${state.categoryCounts[category.id] ?? 0}',
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: BlocBuilder<CatalogCubit, CatalogState>(
                builder: (BuildContext context, CatalogState state) {
                  if (state.status == CatalogStatus.loading &&
                      state.products.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.products.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: l10n.salesSearchNoResultsTitle,
                        message: l10n.salesSearchNoResultsMessage,
                      ),
                    );
                  }

                  return BlocBuilder<CartCubit, CartState>(
                    builder: (BuildContext context, CartState cartState) {
                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          0,
                          AppSpacing.pageHorizontal,
                          AppSpacing.xxxl,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: AppSpacing.md,
                              crossAxisSpacing: AppSpacing.md,
                              mainAxisExtent: 248,
                            ),
                        itemCount: state.products.length,
                        itemBuilder: (BuildContext context, int index) {
                          final Product product = state.products[index];
                          return ProductGridCard(
                            product: product,
                            quantityInCart: cartState.cart.quantityOf(
                              product.id,
                            ),
                            onAdd: () => _addProduct(product),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (BuildContext context, CartState state) {
          if (state.cart.isEmpty) return const SizedBox.shrink();
          return _ViewSaleBar(cart: state.cart, onTap: widget.onBack);
        },
      ),
    );
  }
}

class _ViewSaleBar extends StatelessWidget {
  const _ViewSaleBar({required this.cart, required this.onTap});

  final Cart cart;
  final VoidCallback onTap;

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
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.md,
            AppSpacing.pageHorizontal,
            AppSpacing.md,
          ),
          child: FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  constraints: const BoxConstraints(minWidth: 30),
                  height: 30,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    '${cart.itemCount}',
                    style: AppTextStyles.bodySmallStrong.copyWith(
                      color: AppColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(context.l10n.salesSearchViewSaleButton)),
                Text(
                  MoneyFormatter.format(cart.total),
                  style: AppTextStyles.amountSm.copyWith(
                    fontSize: 18,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
