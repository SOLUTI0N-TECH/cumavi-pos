import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import 'checkout_state.dart';

/// Payment step: method, cash received and confirmation. [registerSale]
/// stores a counter sale, or charges an online order.
class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit({
    required UseCase<Sale, SaleDraft> registerSale,
    required Cart cart,
    PaymentMethod paymentMethod = PaymentMethod.cash,
  }) : _registerSale = registerSale,
       super(CheckoutState(cart: cart, paymentMethod: paymentMethod));

  final UseCase<Sale, SaleDraft> _registerSale;

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
