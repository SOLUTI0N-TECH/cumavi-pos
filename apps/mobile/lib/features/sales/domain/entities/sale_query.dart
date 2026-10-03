import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';

/// Filters of the sales history. Every field is optional; together they
/// narrow the list.
final class SaleQuery extends Equatable {
  const SaleQuery({this.from, this.to, this.paymentMethod, this.number});

  /// Sales at or after this moment.
  final DateTime? from;

  /// Sales before this moment (exclusive), so a day is `[00:00, next 00:00)`.
  final DateTime? to;
  final PaymentMethod? paymentMethod;

  /// Exact sale number (`#0141` is 141); dates still apply when set.
  final int? number;

  bool matches(DateTime createdAt, PaymentMethod method, int saleNumber) {
    final DateTime? from = this.from;
    final DateTime? to = this.to;
    return (from == null || !createdAt.isBefore(from)) &&
        (to == null || createdAt.isBefore(to)) &&
        (paymentMethod == null || method == paymentMethod) &&
        (number == null || saleNumber == number);
  }

  @override
  List<Object?> get props => <Object?>[from, to, paymentMethod, number];
}
