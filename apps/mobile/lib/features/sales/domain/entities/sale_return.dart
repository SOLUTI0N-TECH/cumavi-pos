import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';

/// Units of one line of a sale that came back, and what was refunded.
final class SaleReturnLine extends Equatable {
  const SaleReturnLine({
    required this.lineIndex,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.amount,
    required this.restock,
    this.variantId,
    this.variantLabel,
  });

  /// Position of the line in [Sale.lines].
  final int lineIndex;
  final String productId;
  final String productName;
  final String? variantId;
  final String? variantLabel;
  final int quantity;

  /// Money refunded for these units, discount already prorated.
  final double amount;

  /// Whether the units went back to the shelf (off for damaged items).
  final bool restock;

  @override
  List<Object?> get props => <Object?>[
    lineIndex,
    productId,
    productName,
    variantId,
    variantLabel,
    quantity,
    amount,
    restock,
  ];
}

/// A return of some units of a sale, with its own number and receipt.
final class SaleReturn extends Equatable {
  const SaleReturn({
    required this.id,
    required this.number,
    required this.saleId,
    required this.lines,
    required this.refundMethod,
    required this.reason,
    required this.createdAt,
    required this.cashierName,
  });

  final String id;

  /// Sequential among returns: `D-0001`.
  final int number;
  final String saleId;
  final List<SaleReturnLine> lines;

  /// Same method as the sale, or cash.
  final PaymentMethod refundMethod;
  final String reason;
  final DateTime createdAt;
  final String cashierName;

  double get amount =>
      lines.fold(0, (double sum, SaleReturnLine line) => sum + line.amount);

  int get units =>
      lines.fold(0, (int sum, SaleReturnLine line) => sum + line.quantity);

  /// `D-0001`
  String get formattedNumber => 'D-${number.toString().padLeft(4, '0')}';

  @override
  List<Object?> get props => <Object?>[
    id,
    number,
    saleId,
    lines,
    refundMethod,
    reason,
    createdAt,
    cashierName,
  ];
}

/// Who cancelled a sale, when and why.
final class SaleCancellation extends Equatable {
  const SaleCancellation({
    required this.reason,
    required this.cancelledAt,
    required this.cancelledBy,
  });

  final String reason;
  final DateTime cancelledAt;
  final String cancelledBy;

  @override
  List<Object?> get props => <Object?>[reason, cancelledAt, cancelledBy];
}

/// A return to store; the store numbers it and adds who and when.
final class SaleReturnDraft extends Equatable {
  const SaleReturnDraft({
    required this.saleId,
    required this.lines,
    required this.refundMethod,
    required this.reason,
  });

  final String saleId;
  final List<SaleReturnLine> lines;
  final PaymentMethod refundMethod;
  final String reason;

  @override
  List<Object?> get props => <Object?>[saleId, lines, refundMethod, reason];
}
