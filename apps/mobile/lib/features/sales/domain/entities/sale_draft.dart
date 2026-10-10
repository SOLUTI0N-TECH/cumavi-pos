import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';
import 'cart.dart';

/// Everything the checkout screen collected to register a sale.
final class SaleDraft extends Equatable {
  const SaleDraft({
    required this.cart,
    required this.paymentMethod,
    required this.amountReceived,
    this.orderId,
    this.orderNumber,
  });

  final Cart cart;
  final PaymentMethod paymentMethod;

  /// For non-cash methods the checkout passes the exact total.
  final double amountReceived;

  /// Set when the sale charges an online order.
  final String? orderId;
  final int? orderNumber;

  /// Same draft, charging online order [orderId].
  SaleDraft forOrder({required String orderId, required int orderNumber}) =>
      SaleDraft(
        cart: cart,
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
        orderId: orderId,
        orderNumber: orderNumber,
      );

  @override
  List<Object?> get props => <Object?>[
    cart,
    paymentMethod,
    amountReceived,
    orderId,
    orderNumber,
  ];
}
