import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/entities/receipt_share_target.dart';
import '../../domain/services/receipt_sharer.dart';
import 'receipt_document_renderer.dart';
import 'receipt_text_builder.dart';

/// Sends receipts with the apps installed on the phone.
///
/// WhatsApp links can carry text but not files, so the customer's chat opens
/// with the receipt as a message; the file formats go through the share
/// sheet or the gallery.
final class DeviceReceiptSharer implements ReceiptSharer {
  const DeviceReceiptSharer({
    required ReceiptDocumentRenderer renderer,
    required ReceiptTextBuilder textBuilder,
  }) : _renderer = renderer,
       _textBuilder = textBuilder;

  final ReceiptDocumentRenderer _renderer;
  final ReceiptTextBuilder _textBuilder;

  @override
  Future<Result<void>> share(ReceiptShareRequest request) async {
    try {
      return switch (request.target) {
        WhatsAppShareTarget(:final String phoneNumber) => await _openWhatsApp(
          request.receipt,
          phoneNumber,
        ),
        EmailShareTarget() => await _openEmail(request.receipt),
        DeviceStorageShareTarget() => await _save(
          request.receipt,
          request.format,
        ),
        SystemShareTarget() => await _shareFile(
          request.receipt,
          request.format,
        ),
      };
    } on Object catch (error) {
      debugPrint('Sharing the receipt failed: $error');
      return const Failed<void>(UnexpectedFailure(FailureCode.shareFailed));
    }
  }

  Future<Result<void>> _openWhatsApp(Receipt receipt, String phone) async {
    final Uri uri = Uri.https(
      'wa.me',
      '/${BolivianPhoneNumber.toInternational(phone)}',
      <String, String>{'text': _textBuilder.build(receipt)},
    );
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    return opened
        ? const Success<void>(null)
        : const Failed<void>(ConflictFailure(FailureCode.whatsAppUnavailable));
  }

  Future<Result<void>> _openEmail(Receipt receipt) async {
    // Encoded by hand: `queryParameters` turns spaces into `+`, which mail
    // apps show literally.
    final Uri uri = Uri(
      scheme: 'mailto',
      query:
          'subject=${Uri.encodeComponent(_textBuilder.subject(receipt))}'
          '&body=${Uri.encodeComponent(_textBuilder.build(receipt))}',
    );
    final bool opened = await launchUrl(uri);
    return opened
        ? const Success<void>(null)
        : const Failed<void>(ConflictFailure(FailureCode.emailAppUnavailable));
  }

  Future<Result<void>> _save(Receipt receipt, ReceiptFileFormat format) async {
    if (format == ReceiptFileFormat.pdf) {
      // PDFs do not belong in the gallery: the share sheet offers
      // "Guardar en Archivos" / "Drive" instead.
      return _shareFile(receipt, format);
    }
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
      return const Failed<void>(
        ConflictFailure(FailureCode.photoLibraryPermissionDenied),
      );
    }
    await Gal.putImageBytes(
      await _renderer.renderPng(receipt),
      name: _textBuilder.fileName(receipt),
    );
    return const Success<void>(null);
  }

  Future<Result<void>> _shareFile(
    Receipt receipt,
    ReceiptFileFormat format,
  ) async {
    final bool isPdf = format == ReceiptFileFormat.pdf;
    final Uint8List bytes = isPdf
        ? await _renderer.renderPdf(receipt)
        : await _renderer.renderPng(receipt);

    final Directory directory = await getTemporaryDirectory();
    final File file = File(
      '${directory.path}/${_textBuilder.fileName(receipt)}.'
      '${isPdf ? 'pdf' : 'png'}',
    );
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[
          XFile(file.path, mimeType: isPdf ? 'application/pdf' : 'image/png'),
        ],
        subject: _textBuilder.subject(receipt),
      ),
    );
    return const Success<void>(null);
  }
}
