import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';
import 'sale_line.dart';
import 'sale_return.dart';

/// Where a sale stands after it was made.
enum SaleStatus { completed, cancelled, partiallyReturned, returned }

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
    this.cancellation,
    this.returns = const <SaleReturn>[],
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

  /// Set when the whole sale was cancelled ("Anulada").
  final SaleCancellation? cancellation;

  /// Returns of some of its units, oldest first.
  final List<SaleReturn> returns;

  int get itemCount =>
      lines.fold(0, (int total, SaleLine line) => total + line.quantity);

  double get subtotal =>
      lines.fold(0, (double total, SaleLine line) => total + line.total);

  double get total => (subtotal - discount).clamp(0, double.infinity);

  /// Change to give back, never negative.
  double get change => (amountReceived - total).clamp(0, double.infinity);

  /// `#0019`
  String get formattedNumber => '#${number.toString().padLeft(4, '0')}';

  bool get isCancelled => cancellation != null;

  SaleStatus get status {
    if (isCancelled) return SaleStatus.cancelled;
    final int returned = returns.fold(
      0,
      (int sum, SaleReturn saleReturn) => sum + saleReturn.units,
    );
    if (returned == 0) return SaleStatus.completed;
    return returned >= itemCount
        ? SaleStatus.returned
        : SaleStatus.partiallyReturned;
  }

  /// Units of line [index] already returned.
  int returnedQuantity(int index) =>
      _returnedLines(index)
          .fold(0, (int sum, SaleReturnLine line) => sum + line.quantity);

  /// Units of line [index] that can still be returned.
  int returnableQuantity(int index) =>
      lines[index].quantity - returnedQuantity(index);

  double get refundedTotal => returns.fold(
    0,
    (double sum, SaleReturn saleReturn) => sum + saleReturn.amount,
  );

  /// What line [index] finally cost: its total minus its share of the
  /// sale's discount.
  double lineNetTotal(int index) {
    final double lineTotal = lines[index].total;
    if (discount <= 0 || subtotal <= 0) return lineTotal;
    return _round(lineTotal - discount * lineTotal / subtotal);
  }

  /// Money to refund for [quantity] more units of line [index]. The last
  /// units refund exactly what is left of the line, so rounding never makes
  /// the refunds add up to more (or less) than was paid.
  double refundFor(int index, int quantity) {
    final int remaining = returnableQuantity(index);
    if (quantity <= 0 || remaining <= 0) return 0;
    final double alreadyRefunded = _returnedLines(index)
        .fold(0, (double sum, SaleReturnLine line) => sum + line.amount);
    final double left = lineNetTotal(index) - alreadyRefunded;
    if (quantity >= remaining) return _round(left);
    return _round(lineNetTotal(index) * quantity / lines[index].quantity);
  }

  Iterable<SaleReturnLine> _returnedLines(int index) => returns
      .expand((SaleReturn saleReturn) => saleReturn.lines)
      .where((SaleReturnLine line) => line.lineIndex == index);

  static double _round(double amount) => (amount * 100).roundToDouble() / 100;

  Sale copyWith({SaleCancellation? cancellation, List<SaleReturn>? returns}) =>
      Sale(
        id: id,
        number: number,
        createdAt: createdAt,
        lines: lines,
        discount: discount,
        paymentMethod: paymentMethod,
        amountReceived: amountReceived,
        cashierName: cashierName,
        cancellation: cancellation ?? this.cancellation,
        returns: returns ?? this.returns,
      );

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
    cancellation,
    returns,
  ];
}
