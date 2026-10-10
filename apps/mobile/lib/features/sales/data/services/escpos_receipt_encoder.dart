import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';
import 'receipt_text_builder.dart';

/// Turns a receipt into ESC/POS commands for 58/80 mm thermal printers.
///
/// The layout mirrors the on-screen receipt: store header, sale data, items,
/// totals and payment.
final class EscPosReceiptEncoder {
  EscPosReceiptEncoder(this._l10n) : _texts = ReceiptTextBuilder(_l10n);

  final AppLocalizations _l10n;
  final ReceiptTextBuilder _texts;

  /// Western European code page: covers á, é, ñ, ¡, ¿ and °.
  static const String _codeTable = 'CP1252';

  Future<List<int>> encode(Receipt receipt, ReceiptPaperWidth width) async {
    final CapabilityProfile profile = await CapabilityProfile.load();
    final Generator ticket = Generator(
      width == ReceiptPaperWidth.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );
    final Sale sale = receipt.sale;

    final List<int> bytes = <int>[
      ...ticket.reset(),
      ...ticket.setGlobalCodeTable(_codeTable),
      ...ticket.text(
        _printable(_texts.businessName(receipt)),
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1,
      ),
      if (_texts.storeDetails(receipt, separator: ' - ')
          case final String details)
        ...ticket.text(
          _printable(details),
          styles: const PosStyles(align: PosAlign.center),
        ),
      ...ticket.hr(),
      if (receipt.markLabel(_l10n) case final String mark)
        ...ticket.text(
          _printable(mark),
          styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
          ),
          linesAfter: 1,
        ),
      if (receipt.referenceLabel(_l10n) case final String reference)
        ...ticket.text(
          _printable(reference),
          styles: const PosStyles(align: PosAlign.center),
        ),
      ..._pair(ticket, _l10n.receiptNumberLabel, receipt.number),
      ..._pair(
        ticket,
        _l10n.receiptDateLabel,
        DateFormatter.receiptStamp(sale.createdAt),
      ),
      ..._pair(ticket, _l10n.receiptCashierLabel, sale.cashierName),
      ...ticket.hr(),
    ];

    for (final SaleLine line in sale.lines) {
      bytes.addAll(ticket.text(_printable(line.productName)));
      // The variant goes on its own line, like on the screen: narrow paper
      // would cut `Zapatillas urbanas (Azul · 40)` anywhere.
      if (line.variantLabel case final String variantLabel) {
        bytes.addAll(ticket.text(_printable('  $variantLabel')));
      }
      bytes.addAll(
        _pair(
          ticket,
          '  ${line.quantity} x ${MoneyFormatter.format(line.unitPrice)}',
          MoneyFormatter.format(line.total),
        ),
      );
    }

    bytes.addAll(ticket.hr());
    if (sale.discount > 0 || sale.deliveryFee > 0) {
      bytes.addAll(
        _pair(
          ticket,
          _l10n.receiptSubtotalLabel,
          MoneyFormatter.format(sale.subtotal),
        ),
      );
    }
    if (sale.discount > 0) {
      bytes.addAll(
        _pair(
          ticket,
          _l10n.receiptDiscountLabel,
          '- ${MoneyFormatter.format(sale.discount)}',
        ),
      );
    }
    if (sale.deliveryFee > 0) {
      bytes.addAll(
        _pair(
          ticket,
          _l10n.receiptDeliveryLabel,
          MoneyFormatter.format(sale.deliveryFee),
        ),
      );
    }
    bytes
      ..addAll(
        _pair(
          ticket,
          receipt.totalLabel(_l10n),
          MoneyFormatter.format(sale.total),
          styles: const PosStyles(bold: true, height: PosTextSize.size2),
        ),
      )
      ..addAll(
        _pair(
          ticket,
          sale.paymentMethod.localizedName(_l10n),
          MoneyFormatter.format(sale.amountReceived),
        ),
      );
    if (sale.change > 0) {
      bytes.addAll(
        _pair(
          ticket,
          _l10n.receiptChangeLabel,
          MoneyFormatter.format(sale.change),
        ),
      );
    }

    bytes
      ..addAll(ticket.hr())
      ..addAll(
        ticket.text(
          _printable(receipt.closingLine(_l10n)),
          styles: const PosStyles(align: PosAlign.center, bold: true),
        ),
      )
      ..addAll(
        ticket.text(
          _printable(_l10n.receiptMadeWith),
          styles: const PosStyles(align: PosAlign.center),
        ),
      )
      ..addAll(ticket.feed(3))
      ..addAll(ticket.cut());

    return bytes;
  }

  /// Label on the left, value aligned right.
  List<int> _pair(
    Generator ticket,
    String label,
    String value, {
    PosStyles styles = const PosStyles(),
  }) {
    return ticket.row(<PosColumn>[
      PosColumn(text: _printable(label), width: 7, styles: styles),
      PosColumn(
        text: _printable(value),
        width: 5,
        styles: PosStyles(
          align: PosAlign.right,
          bold: styles.bold,
          height: styles.height,
        ),
      ),
    ]);
  }

  /// The printer encodes text as Latin-1; anything outside it (typographic
  /// dashes, ellipsis) would crash the encoder, so it is replaced.
  String _printable(String text) {
    final StringBuffer buffer = StringBuffer();
    for (final int rune in text.runes) {
      if (rune <= 0xFF) {
        buffer.writeCharCode(rune);
        continue;
      }
      buffer.write(switch (rune) {
        0x2212 || 0x2013 || 0x2014 => '-',
        0x2026 => '...',
        0x201C || 0x201D => '"',
        0x2018 || 0x2019 => "'",
        _ => '?',
      });
    }
    return buffer.toString();
  }
}
