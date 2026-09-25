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
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../catalog/presentation/cubit/catalog_state.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_line.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/cart_line_tile.dart';
import '../widgets/cart_summary_panel.dart';
import '../widgets/category_shortcut_tiles.dart';
import '../widgets/discount_sheet.dart';
import '../widgets/variant_picker_sheet.dart';

/// Ventas tab while the drawer is open: the cart is the screen, and the
/// search bar opens the full catalog.
class SaleView extends StatelessWidget {
  const SaleView({
    required this.onOpenCatalog,
    required this.onCheckout,
    required this.onManageCashRegister,
    super.key,
  });

  /// Space the floating summary panel (subtotal + "Cobrar") takes above the
  /// navigation bar, so the cart's last line can scroll clear of it.
  static const double summaryPanelRoom = 176;

  /// [categoryId] preselects a category when the seller taps a shortcut.
  final void Function({String? categoryId}) onOpenCatalog;
  final VoidCallback onCheckout;
  final VoidCallback onManageCashRegister;

  Future<void> _editDiscount(BuildContext context, Cart cart) async {
    final double? discount = await DiscountSheet.show(
      context,
      currentDiscount: cart.discount,
    );
    if (discount == null || !context.mounted) return;
    context.read<CartCubit>().applyDiscount(discount);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return BlocBuilder<CartCubit, CartState>(
      builder: (BuildContext context, CartState state) {
        final Cart cart = state.cart;

        return SafeArea(
          bottom: false,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.pageHorizontal,
                      0,
                    ),
                    child: ScreenHeader(
                      title: l10n.salesSaleTitle,
                      subtitle: state.nextSaleNumber == null
                          ? null
                          : l10n.salesSaleNumber(state.formattedSaleNumber),
                      trailing: StatusPill(
                        label: l10n.salesCashRegisterOpenStatus,
                        dotColor: AppColors.success,
                        background: AppColors.successSurface,
                        foreground: AppColors.successText,
                        trailingIcon: Icons.expand_more_rounded,
                        height: 40,
                        onTap: onManageCashRegister,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: SearchFieldButton(
                      hintText: l10n.salesSearchProductHint,
                      onTap: () => onOpenCatalog(),
                      onScanTap: () => onOpenCatalog(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: cart.isEmpty
                        ? _EmptyCart(onOpenCatalog: onOpenCatalog)
                        : _CartList(cart: cart),
                  ),
                ],
              ),
              Positioned(
                left: AppSpacing.pageHorizontal,
                right: AppSpacing.pageHorizontal,
                bottom: context.bottomNavHeight + AppSpacing.md,
                child: CartSummaryPanel(
                  cart: cart,
                  onCharge: cart.isEmpty ? null : onCheckout,
                  onAddDiscount: () => _editDiscount(context, cart),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CartList extends StatelessWidget {
  const _CartList({required this.cart});

  final Cart cart;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final CartCubit cubit = context.read<CartCubit>();

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        // Leaves room for the summary panel and the navigation bar.
        context.bottomNavHeight + SaleView.summaryPanelRoom,
      ),
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xxl),
          ),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: AppSpacing.lg,
                  right: AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: l10n.salesCartTitle,
                          style: AppTextStyles.bodyStrong,
                          children: <InlineSpan>[
                            TextSpan(
                              text: l10n.salesCartItemCountSuffix(
                                l10n.itemCount(cart.itemCount),
                              ),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: cubit.clear,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.errorText,
                      ),
                      child: Text(l10n.salesCartClearButton),
                    ),
                  ],
                ),
              ),
              const CartLineDivider(),
              for (final CartLine line in cart.lines) ...<Widget>[
                CartLineTile(
                  line: line,
                  onIncrement: () => _increment(context, line),
                  onDecrement: () => cubit.decrement(line.key),
                  onRemove: () => cubit.remove(line.key),
                ),
                if (line != cart.lines.last) const CartLineDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _increment(BuildContext context, CartLine line) {
    final bool added = context.read<CartCubit>().increment(line.key);
    if (added) return;
    showStockLimitMessage(context, line.product, variant: line.variant);
  }
}

class _EmptyCart extends StatefulWidget {
  const _EmptyCart({required this.onOpenCatalog});

  final void Function({String? categoryId}) onOpenCatalog;

  @override
  State<_EmptyCart> createState() => _EmptyCartState();
}

class _EmptyCartState extends State<_EmptyCart> {
  @override
  void initState() {
    super.initState();
    context.read<CatalogCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
        AppSpacing.pageHorizontal,
        context.bottomNavHeight + SaleView.summaryPanelRoom,
      ),
      children: <Widget>[
        EmptyStateView(
          icon: Icons.shopping_cart_outlined,
          title: l10n.salesCartEmptyTitle,
          message: l10n.salesCartEmptyMessage,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs),
          child: Text(
            l10n.salesCartBrowseByCategory,
            style: AppTextStyles.bodyStrong.copyWith(color: AppColors.inkSoft),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        BlocBuilder<CatalogCubit, CatalogState>(
          builder: (BuildContext context, CatalogState state) {
            if (state.products.isEmpty) {
              return const SizedBox(height: 132);
            }
            final List<CategoryShortcutTile> tiles =
                CategoryShortcutTile.fromProducts(
                  state.products,
                  onCategoryTap: (String categoryId) =>
                      widget.onOpenCatalog(categoryId: categoryId),
                );
            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Fixed height: a ratio would squeeze the tile on narrow phones.
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: AppSpacing.sm + 2,
                mainAxisSpacing: AppSpacing.sm + 2,
                mainAxisExtent: 152,
              ),
              children: tiles,
            );
          },
        ),
      ],
    );
  }
}

/// Shown when a product (or its [variant]) cannot be added because the cart
/// already holds all its stock, or there is none.
void showStockLimitMessage(
  BuildContext context,
  Product product, {
  ProductVariant? variant,
}) {
  final AppLocalizations l10n = context.l10n;
  final int stock = variant?.stockQuantity ?? product.stockQuantity;
  final String name = _displayName(l10n, product, variant);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          stock > 0
              ? l10n.salesStockLimitMessage(stock, name)
              : l10n.salesProductSoldOutMessage(name),
        ),
      ),
    );
}

/// Confirms which variant went into the sale, since the picker that chose it
/// has just closed.
void showVariantAddedMessage(
  BuildContext context,
  Product product,
  VariantChoice choice,
) {
  final AppLocalizations l10n = context.l10n;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          l10n.salesVariantAddedMessage(
            choice.quantity,
            _displayName(l10n, product, choice.variant),
          ),
        ),
      ),
    );
}

/// `Zapatillas urbanas (Azul · 40)`, or just the name of a simple product.
String _displayName(
  AppLocalizations l10n,
  Product product,
  ProductVariant? variant,
) => variant == null
    ? product.name
    : l10n.salesVariantProductName(product.name, variant.label);
