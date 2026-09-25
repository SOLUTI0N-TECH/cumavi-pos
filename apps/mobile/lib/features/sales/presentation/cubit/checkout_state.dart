import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/sale.dart';

enum CheckoutStatus { editing, submitting, completed, failure }

final class CheckoutState extends Equatable {
  const CheckoutState({
    required this.cart,
    this.paymentMethod = PaymentMethod.cash,
    this.amountReceived,
    this.status = CheckoutStatus.editing,
    this.sale,
    this.failure,
  });

  final Cart cart;
  final PaymentMethod paymentMethod;

  /// Cash handed over. `null` means "exact amount".
  final double? amountReceived;
  final CheckoutStatus status;

  /// Set once the sale is registered.
  final Sale? sale;
  final Failure? failure;

  double get total => cart.total;

  double get effectiveAmountReceived => amountReceived ?? total;

  double get change =>
      (effectiveAmountReceived - total).clamp(0, double.infinity);

  bool get isCashPayment => paymentMethod.affectsCashDrawer;

  bool get hasEnoughCash => effectiveAmountReceived >= total;

  bool get canConfirm =>
      cart.isNotEmpty && hasEnoughCash && status != CheckoutStatus.submitting;

  CheckoutState copyWith({
    Cart? cart,
    PaymentMethod? paymentMethod,
    double? amountReceived,
    bool clearAmountReceived = false,
    CheckoutStatus? status,
    Sale? sale,
    Failure? failure,
  }) {
    return CheckoutState(
      cart: cart ?? this.cart,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountReceived: clearAmountReceived
          ? null
          : amountReceived ?? this.amountReceived,
      status: status ?? this.status,
      sale: sale ?? this.sale,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    cart,
    paymentMethod,
    amountReceived,
    status,
    sale,
    failure,
  ];
}
