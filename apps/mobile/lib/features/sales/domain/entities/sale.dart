import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';
import 'sale_line.dart';

/// A completed sale, the source of the receipt and of the daily totals.
final class Sale extends Equatable {
  const Sale({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.lines,
    required this.discount,
    required this.paymentMethod,
    required this.amountReceived,
    required this.cashierName,
  });

  final String id;

  /// Sequential number shown to the customer (`#0019`).
  final int number;
  final DateTime createdAt;
  final List<SaleLine> lines;
  final double discount;
  final PaymentMethod paymentMethod;

  /// Money handed over by the customer; equals [total] for non-cash payments.
  final double amountReceived;
  final String cashierName;

  int get itemCount =>
      lines.fold(0, (int total, SaleLine line) => total + line.quantity);

  double get subtotal =>
      lines.fold(0, (double total, SaleLine line) => total + line.total);

  double get total => (subtotal - discount).clamp(0, double.infinity);

  /// Change to give back, never negative.
  double get change => (amountReceived - total).clamp(0, double.infinity);

  /// `#0019`
  String get formattedNumber => '#${number.toString().padLeft(4, '0')}';

  @override
  List<Object?> get props => <Object?>[
    id,
    number,
    createdAt,
    lines,
    discount,
    paymentMethod,
    amountReceived,
    cashierName,
  ];
}
