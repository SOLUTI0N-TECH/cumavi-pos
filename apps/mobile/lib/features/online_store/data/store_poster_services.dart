import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/error/failure.dart';
import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/result.dart';
import '../domain/services/store_poster_service.dart';

/// Renders the poster as an A5 PDF (fits a counter or a door) and shares or
/// prints it.
final class PdfStorePosterService implements StorePosterService {
  const PdfStorePosterService(this._l10n);

  final AppLocalizations _l10n;

  static const PdfColor _ink = PdfColor.fromInt(0xFF292526);
  static const PdfColor _muted = PdfColor.fromInt(0xFF6B6E72);

  @override
  Future<Result<void>> share(StorePoster poster) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final File file = File(
        '${directory.path}/${_l10n.onlineStorePosterFileName}.pdf',
      );
      await file.writeAsBytes(await render(poster), flush: true);
      await SharePlus.instance.share(
        ShareParams(
          files: <XFile>[XFile(file.path, mimeType: 'application/pdf')],
          subject: poster.businessName,
        ),
      );
      return const Success<void>(null);
    } on Object catch (error) {
      debugPrint('Sharing the poster failed: $error');
      return const Failed<void>(UnexpectedFailure(FailureCode.shareFailed));
    }
  }

  @override
  Future<Result<void>> print(StorePoster poster) async {
    try {
      await Printing.layoutPdf(
        name: _l10n.onlineStorePosterFileName,
        onLayout: (_) => render(poster),
      );
      return const Success<void>(null);
    } on Object catch (error) {
      debugPrint('Printing the poster failed: $error');
      return const Failed<void>(UnexpectedFailure(FailureCode.printFailed));
    }
  }

  Future<Uint8List> render(StorePoster poster) async {
    final pw.Font regular = pw.Font.ttf(
      await rootBundle.load(AppFonts.files[400]!),
    );
    final pw.Font bold = pw.Font.ttf(
      await rootBundle.load(AppFonts.files[700]!),
    );
    final pw.Document document = pw.Document(
      title: _l10n.onlineStorePosterTitle,
      author: poster.businessName,
    );
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => pw.Center(
          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: <pw.Widget>[
              pw.Text(
                poster.businessName,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: 26,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
              if (poster.tagline.isNotEmpty) ...<pw.Widget>[
                pw.SizedBox(height: 6),
                pw.Text(
                  poster.tagline,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 13, color: _muted),
                ),
              ],
              pw.SizedBox(height: 28),
              pw.Text(
                _l10n.onlineStorePosterTitle,
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                  color: _ink,
                ),
              ),
              pw.SizedBox(height: 18),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: poster.url,
                width: 220,
                height: 220,
                color: _ink,
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                _l10n.onlineStorePosterSubtitle,
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 13, color: _muted),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                poster.url.replaceFirst(RegExp('^https?://'), ''),
                style: const pw.TextStyle(fontSize: 11, color: _muted),
              ),
            ],
          ),
        ),
      ),
    );
    return document.save();
  }
}

/// Stand-in for tests, desktop and web.
final class DemoStorePosterService implements StorePosterService {
  const DemoStorePosterService();

  @override
  Future<Result<void>> share(StorePoster poster) async =>
      const Success<void>(null);

  @override
  Future<Result<void>> print(StorePoster poster) async =>
      const Success<void>(null);
}
