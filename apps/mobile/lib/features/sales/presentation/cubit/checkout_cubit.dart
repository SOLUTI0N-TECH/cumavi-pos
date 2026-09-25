import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/usecases/register_sale.dart';
import 'checkout_state.dart';

/// Payment step: method, cash received and confirmation.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({required RegisterSale registerSale, required Cart cart})
    : _registerSale = registerSale,
      super(CheckoutState(cart: cart));

  final RegisterSale _registerSale;

  void paymentMethodSelected(PaymentMethod method) {
    emit(
      state.copyWith(
        paymentMethod: method,
        // Non-cash payments are always for the exact amount.
        clearAmountReceived: !method.affectsCashDrawer,
        status: CheckoutStatus.editing,
      ),
    );
  }

  void amountReceivedChanged(double? amount) {
    emit(
      CheckoutState(
        cart: state.cart,
        paymentMethod: state.paymentMethod,
        amountReceived: amount,
      ),
    );
  }

  Future<void> confirm() async {
    if (!state.canConfirm) return;
    emit(state.copyWith(status: CheckoutStatus.submitting));

    final Result<Sale> result = await _registerSale(
      SaleDraft(
        cart: state.cart,
        paymentMethod: state.paymentMethod,
        amountReceived: state.effectiveAmountReceived,
      ),
    );

    switch (result) {
      case Success<Sale>(:final Sale value):
        emit(state.copyWith(status: CheckoutStatus.completed, sale: value));
      case Failed<Sale>(:final failure):
        emit(state.copyWith(status: CheckoutStatus.failure, failure: failure));
    }
  }
}
