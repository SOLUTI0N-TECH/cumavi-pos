import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/business_profile.dart';
import 'sale.dart';
import 'sale_line.dart';
import 'sale_return.dart';

/// Stamp printed over a receipt that is not a plain sale.
enum ReceiptMark { cancelled, partiallyReturned, returned, refund }

/// What gets printed or shared: a sale (or a return) plus the store it
/// belongs to.
final class Receipt extends Equatable {
  const Receipt({required this.sale, this.business, this.refundOf});

  /// Receipt of a return: its lines are the units given back, priced at
  /// what was refunded, and the payment is the refund.
  Receipt.refund({
    required Sale original,
    required SaleReturn refund,
    BusinessProfile? business,
  }) : this(
         sale: Sale(
           id: refund.id,
           number: refund.number,
           createdAt: refund.createdAt,
           lines: <SaleLine>[
             for (final SaleReturnLine line in refund.lines)
               SaleLine(
                 productId: line.productId,
                 productName: line.productName,
                 variantId: line.variantId,
                 variantLabel: line.variantLabel,
                 unitPrice: line.amount / line.quantity,
                 quantity: line.quantity,
               ),
           ],
           discount: 0,
           paymentMethod: refund.refundMethod,
           amountReceived: refund.amount,
           cashierName: refund.cashierName,
         ),
         business: business,
         refundOf: original,
       );

  /// The document printed: the sale, or the return shaped as one.
  final Sale sale;

  /// `null` only if the session has no business yet; the receipt then shows
  /// a generic header.
  final BusinessProfile? business;

  /// The original sale, when this is the receipt of a return.
  final Sale? refundOf;

  bool get isRefund => refundOf != null;

  /// `0019`, or `D-0001` for a return.
  String get number {
    final String digits = sale.number.toString().padLeft(4, '0');
    return isRefund ? 'D-$digits' : digits;
  }

  ReceiptMark? get mark {
    if (isRefund) return ReceiptMark.refund;
    return switch (sale.status) {
      SaleStatus.completed => null,
      SaleStatus.cancelled => ReceiptMark.cancelled,
      SaleStatus.partiallyReturned => ReceiptMark.partiallyReturned,
      SaleStatus.returned => ReceiptMark.returned,
    };
  }

  Receipt withBusiness(BusinessProfile? business) =>
      Receipt(sale: sale, business: business, refundOf: refundOf);

  @override
  List<Object?> get props => <Object?>[sale, business, refundOf];
}
