import '../../features/sales/domain/entities/receipt.dart';
import '../../l10n/generated/app_localizations.dart';

/// Stamp and reference line of a receipt, the same on screen, on paper and
/// in shared text.
extension ReceiptMarkL10n on Receipt {
  /// `ANULADA`, `DEVOLUCIÓN`… or `null` for a plain sale.
  String? markLabel(AppLocalizations l10n) => switch (mark) {
    null => null,
    ReceiptMark.cancelled => l10n.receiptMarkCancelled,
    ReceiptMark.partiallyReturned => l10n.receiptMarkPartiallyReturned,
    ReceiptMark.returned => l10n.receiptMarkReturned,
    ReceiptMark.refund => l10n.receiptMarkRefund,
  };

  /// `TOTAL`, or `TOTAL DEVUELTO` on a return.
  String totalLabel(AppLocalizations l10n) =>
      isRefund ? l10n.receiptRefundTotalLabel : l10n.receiptTotalLabel;

  /// Last line: thanks for the purchase, or a plain goodbye on a return.
  String closingLine(AppLocalizations l10n) =>
      isRefund ? l10n.receiptRefundClosing : l10n.receiptThanks;

  /// `De la venta #0104`, only for a return.
  String? referenceLabel(AppLocalizations l10n) => switch (refundOf) {
    final original? => l10n.receiptRefundOf(original.formattedNumber),
    null => null,
  };
}
