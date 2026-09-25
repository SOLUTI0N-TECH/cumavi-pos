import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';
import 'cart.dart';

/// Everything the checkout screen collected to register a sale.
final class SaleDraft extends Equatable {
  const SaleDraft({
    required this.cart,
    required this.paymentMethod,
    required this.amountReceived,
  });

  final Cart cart;
  final PaymentMethod paymentMethod;

  /// For non-cash methods the checkout passes the exact total.
  final double amountReceived;

  @override
  List<Object?> get props => <Object?>[cart, paymentMethod, amountReceived];
}
