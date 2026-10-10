import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';
import 'receipt_text_builder.dart';

/// Renders the receipt as a PDF (80 mm roll) and, from that same PDF, as a
/// PNG. One source keeps both formats identical.
final class ReceiptDocumentRenderer {
  ReceiptDocumentRenderer(this._l10n) : _texts = ReceiptTextBuilder(_l10n);

  final AppLocalizations _l10n;
  final ReceiptTextBuilder _texts;

  static const PdfColor _ink = PdfColor.fromInt(0xFF292526);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B6E72);
  static const PdfColor _line = PdfColor.fromInt(0xFFD5DAE1);

  /// Resolution of the PNG export; sharp on phones, light enough for chats.
  static const double _imageDpi = 220;

  Future<Uint8List> renderPdf(Receipt receipt) async {
    final pw.Font regular = await _font(400);
    final pw.Font bold = await _font(700);
    final pw.Document document = pw.Document(
      title: _l10n.receiptDocumentTitle(receipt.number),
      author: _texts.businessName(receipt),
    );

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80.copyWith(
          marginLeft: 0,
          marginRight: 0,
          marginTop: 0,
          marginBottom: 0,
        ),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => _ReceiptLayout(
          receipt: receipt,
          l10n: _l10n,
          texts: _texts,
        ).build(),
      ),
    );
    return document.save();
  }

  Future<Uint8List> renderPng(Receipt receipt) async {
    final Uint8List pdf = await renderPdf(receipt);
    final PdfRaster page = await Printing.raster(pdf, dpi: _imageDpi).first;
    return page.toPng();
  }

  Future<pw.Font> _font(int weight) async {
    final ByteData data = await rootBundle.load(AppFonts.files[weight]!);
    return pw.Font.ttf(data);
  }
}

/// PDF version of the on-screen receipt.
final class _ReceiptLayout {
  const _ReceiptLayout({
    required this.receipt,
    required this.l10n,
    required this.texts,
  });

  final Receipt receipt;
  final AppLocalizations l10n;
  final ReceiptTextBuilder texts;

  pw.Widget build() {
    final Sale sale = receipt.sale;

    return pw.Container(
      color: PdfColors.white,
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          pw.Center(
            child: pw.Text(
              texts.businessName(receipt),
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: ReceiptDocumentRenderer._ink,
              ),
            ),
          ),
          if (texts.storeDetails(receipt) case final String details)
            pw.Center(child: pw.Text(details, style: _muted(8))),
          _divider(),
          if (receipt.markLabel(l10n) case final String mark)
            pw.Center(
              child: pw.Text(
                mark,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: ReceiptDocumentRenderer._ink,
                ),
              ),
            ),
          if (receipt.referenceLabel(l10n) case final String reference)
            pw.Center(child: pw.Text(reference, style: _muted(8))),
          _pair(l10n.receiptNumberLabel, receipt.number),
          _pair(
            l10n.receiptDateLabel,
            DateFormatter.receiptStamp(sale.createdAt),
          ),
          _pair(l10n.receiptCashierLabel, sale.cashierName),
          _divider(),
          for (final SaleLine line in sale.lines) ...<pw.Widget>[
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: <pw.Widget>[
                      pw.Text(line.productName, style: _body(9)),
                      if (line.variantLabel case final String variantLabel)
                        pw.Text(variantLabel, style: _body(8)),
                      pw.Text(
                        '${line.quantity} × '
                        '${MoneyFormatter.format(line.unitPrice)}',
                        style: _muted(8),
                      ),
                    ],
                  ),
                ),
                pw.Text(
                  MoneyFormatter.format(line.total),
                  style: _body(9, bold: true),
                ),
              ],
            ),
            pw.SizedBox(height: 5),
          ],
          _divider(),
          if (sale.discount > 0 || sale.deliveryFee > 0)
            _pair(
              l10n.receiptSubtotalLabel,
              MoneyFormatter.format(sale.subtotal),
            ),
          if (sale.discount > 0)
            _pair(
              l10n.receiptDiscountLabel,
              '− ${MoneyFormatter.format(sale.discount)}',
            ),
          if (sale.deliveryFee > 0)
            _pair(
              l10n.receiptDeliveryLabel,
              MoneyFormatter.format(sale.deliveryFee),
            ),
          pw.Row(
            children: <pw.Widget>[
              pw.Expanded(
                child: pw.Text(
                  receipt.totalLabel(l10n),
                  style: _body(11, bold: true),
                ),
              ),
              pw.Text(
                MoneyFormatter.format(sale.total),
                style: _body(13, bold: true),
              ),
            ],
          ),
          pw.SizedBox(height: 3),
          _pair(
            sale.paymentMethod.localizedName(l10n),
            MoneyFormatter.format(sale.amountReceived),
          ),
          if (sale.change > 0)
            _pair(l10n.receiptChangeLabel, MoneyFormatter.format(sale.change)),
          _divider(),
          pw.Center(
            child: pw.Text(
              receipt.closingLine(l10n),
              style: _body(9, bold: true),
            ),
          ),
          pw.SizedBox(height: 2),
          pw.Center(child: pw.Text(l10n.receiptMadeWith, style: _muted(7))),
        ],
      ),
    );
  }

  pw.Widget _pair(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        children: <pw.Widget>[
          pw.Expanded(child: pw.Text(label, style: _muted(8.5))),
          pw.Text(value, style: _body(8.5)),
        ],
      ),
    );
  }

  pw.Widget _divider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 7),
      child: pw.Divider(
        height: 1,
        thickness: 1,
        color: ReceiptDocumentRenderer._line,
        borderStyle: pw.BorderStyle.dashed,
      ),
    );
  }

  pw.TextStyle _body(double size, {bool bold = false}) => pw.TextStyle(
    fontSize: size,
    color: ReceiptDocumentRenderer._ink,
    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
  );

  pw.TextStyle _muted(double size) =>
      pw.TextStyle(fontSize: size, color: ReceiptDocumentRenderer._muted);
}
