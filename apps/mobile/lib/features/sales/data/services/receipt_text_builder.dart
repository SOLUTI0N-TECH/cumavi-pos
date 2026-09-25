import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';

/// Texts of a receipt outside the app: the plain-text receipt for messaging
/// apps (`*text*` renders bold in WhatsApp and reads fine in an email), the
/// email subject and the exported file name.
final class ReceiptTextBuilder {
  const ReceiptTextBuilder(this._l10n);

  final AppLocalizations _l10n;

  String build(Receipt receipt) {
    final Sale sale = receipt.sale;
    final StringBuffer buffer = StringBuffer()
      ..writeln('*${businessName(receipt)}*')
      ..writeln(_l10n.receiptNumberTitle(receipt.number))
      ..writeln(DateFormatter.receiptStamp(sale.createdAt))
      ..writeln();

    for (final SaleLine line in sale.lines) {
      buffer.writeln(
        '${line.quantity} x ${itemName(line)} — '
        '${MoneyFormatter.format(line.total)}',
      );
    }

    buffer.writeln();
    if (sale.discount > 0) {
      buffer
        ..writeln(
          '${_l10n.receiptSubtotalLabel}: '
          '${MoneyFormatter.format(sale.subtotal)}',
        )
        ..writeln(
          '${_l10n.receiptDiscountLabel}: '
          '− ${MoneyFormatter.format(sale.discount)}',
        );
    }
    buffer
      ..writeln(
        '*${_l10n.receiptTotalLabel}: ${MoneyFormatter.format(sale.total)}*',
      )
      ..writeln(
        '${sale.paymentMethod.localizedName(_l10n)}: '
        '${MoneyFormatter.format(sale.amountReceived)}',
      );
    if (sale.change > 0) {
      buffer.writeln(
        '${_l10n.receiptChangeLabel}: ${MoneyFormatter.format(sale.change)}',
      );
    }
    buffer
      ..writeln()
      ..write(_l10n.receiptThanks);

    return buffer.toString();
  }

  String subject(Receipt receipt) =>
      _l10n.receiptEmailSubject(receipt.number, businessName(receipt));

  /// `comprobante-0019`, without extension.
  String fileName(Receipt receipt) => _l10n.receiptFileName(receipt.number);

  /// `Zapatillas urbanas (Azul · 40)`, or just the name of a simple product.
  String itemName(SaleLine line) => switch (line.variantLabel) {
    final String variantLabel => _l10n.salesVariantProductName(
      line.productName,
      variantLabel,
    ),
    null => line.productName,
  };

  String businessName(Receipt receipt) =>
      receipt.business?.name ?? _l10n.commonDefaultBusinessName;

  /// `La Paz · NIT 1234567`, or `null` when the store has no details yet.
  String? storeDetails(Receipt receipt, {String separator = ' · '}) {
    final List<String> parts = <String>[
      ?receipt.business?.department.displayName,
      if (receipt.business?.taxId case final String taxId)
        _l10n.receiptTaxId(taxId),
    ];
    return parts.isEmpty ? null : parts.join(separator);
  }
}
