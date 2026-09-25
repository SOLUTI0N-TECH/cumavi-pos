import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../domain/entities/cart.dart';
import '../../domain/usecases/get_next_sale_number.dart';
import 'cart_state.dart';

/// Holds the sale in progress. Lives as long as the app session so moving
/// between the cart, the catalog and the checkout keeps the same cart.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._getNextSaleNumber) : super(const CartState());

  final GetNextSaleNumber _getNextSaleNumber;

  Future<void> loadSaleNumber() async {
    if (await _getNextSaleNumber(const NoParams()) case Success<int>(
      :final int value,
    )) {
      emit(state.copyWith(nextSaleNumber: value));
    }
  }

  /// Adds [quantity] units of [product], in [variant] when the product has
  /// variants. Returns `false` when the stock does not allow it, so the
  /// caller can explain why nothing happened.
  bool addProduct(
    Product product, {
    ProductVariant? variant,
    int quantity = 1,
  }) {
    final Cart next = state.cart.addProduct(
      product,
      variant: variant,
      quantity: quantity,
    );
    if (next == state.cart) return false;
    emit(state.copyWith(cart: next));
    return true;
  }

  /// Adds one unit to a line already in the cart. Returns `false` when the
  /// stock is exhausted.
  bool increment(String lineKey) {
    final Cart next = state.cart.incrementLine(lineKey);
    if (next == state.cart) return false;
    emit(state.copyWith(cart: next));
    return true;
  }

  void decrement(String lineKey) {
    emit(state.copyWith(cart: state.cart.decrementLine(lineKey)));
  }

  void remove(String lineKey) {
    emit(state.copyWith(cart: state.cart.removeLine(lineKey)));
  }

  void applyDiscount(double amount) {
    emit(state.copyWith(cart: state.cart.applyDiscount(amount)));
  }

  /// Empties the cart and asks for the next sale number.
  Future<void> startNewSale() async {
    emit(CartState(nextSaleNumber: state.nextSaleNumber));
    await loadSaleNumber();
  }

  void clear() => emit(CartState(nextSaleNumber: state.nextSaleNumber));
}
