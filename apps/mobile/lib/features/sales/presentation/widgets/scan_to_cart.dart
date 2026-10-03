import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_code_match.dart';
import '../../../catalog/presentation/cubit/catalog_cubit.dart';
import '../../../catalog/presentation/scanner/barcode_camera.dart';
import '../cubit/cart_cubit.dart';
import '../views/sale_view.dart';
import 'variant_picker_sheet.dart';

/// Adds [product] to the sale from the catalog: a simple product goes in
/// with one tap; a product with variants first asks which one and how many.
Future<void> addProductToCart(BuildContext context, Product product) async {
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
  if (choice == null || !context.mounted) return;
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

/// Scans a code and puts what it points at in the sale. A variant's code
/// adds that exact variant; a product's code adds it, or asks for the
/// variant when it has several. Every outcome is confirmed, since the
/// seller is looking at the product, not the phone.
Future<void> scanIntoCart(BuildContext context, ScanCode scan) async {
  final CatalogCubit catalogCubit = context.read<CatalogCubit>();
  final String? code = await scan();
  if (code == null || !context.mounted) return;

  final Result<ProductCodeMatch> result = await catalogCubit.findByCode(code);
  if (!context.mounted) return;
  if (result case Failed<ProductCodeMatch>(:final failure)) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context.l10n))),
      );
    return;
  }

  final ProductCodeMatch match = result.valueOrNull!;
  final Product product = match.product;
  if (product.hasVariants && match.variant == null) {
    await addProductToCart(context, product);
    return;
  }
  if (context.read<CartCubit>().addProduct(product, variant: match.variant)) {
    showAddedToSaleMessage(context, product, variant: match.variant);
  } else {
    showStockLimitMessage(context, product, variant: match.variant);
  }
}
