import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_background_remover/image_background_remover.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/services/image_background_remover.dart';

/// Removes the background on the device with the same ONNX model Cumavi Shop
/// uses, so it works offline and costs nothing per photo.
///
/// It stores two files next to the original: the transparent PNG cutout and
/// a JPG over white, the default look of the catalog.
final class OnDeviceBackgroundRemover implements ImageBackgroundRemover {
  OnDeviceBackgroundRemover({BackgroundRemover? engine})
    : _engine = engine ?? BackgroundRemover.instance;

  /// Tuned in Cumavi Shop for product photos on busy backgrounds.
  static const double _maskThreshold = 0.35;

  final BackgroundRemover _engine;
  Future<void>? _initialization;

  @override
  Future<Result<ProductPhoto>> removeBackground(ProductPhoto photo) async {
    try {
      await (_initialization ??= _engine.initializeOrt());

      final Uint8List original = await _readBytes(photo.originalPath);
      final Uint8List cutout = await _engine.removeBgBytes(
        original,
        threshold: _maskThreshold,
      );
      final Uint8List overWhite = await _engine.addBackground(
        image: cutout,
        bgColor: Colors.white,
      );

      final Directory directory = await getTemporaryDirectory();
      final String stamp = DateTime.now().microsecondsSinceEpoch.toString();
      final File cutoutFile = File(
        '${directory.path}/product_${stamp}_cutout.png',
      );
      final File whiteFile = File(
        '${directory.path}/product_${stamp}_white.png',
      );
      await cutoutFile.writeAsBytes(cutout, flush: true);
      await whiteFile.writeAsBytes(overWhite, flush: true);

      return Success<ProductPhoto>(
        photo.copyWith(
          cutoutPath: cutoutFile.path,
          whiteBackgroundPath: whiteFile.path,
          background: PhotoBackground.white,
        ),
      );
    } on Object catch (error) {
      debugPrint('Background removal failed: $error');
      return const Failed<ProductPhoto>(
        UnexpectedFailure(FailureCode.backgroundRemovalFailed),
      );
    }
  }

  Future<Uint8List> _readBytes(String path) async {
    if (path.startsWith('assets/')) {
      final ByteData data = await rootBundle.load(path);
      return data.buffer.asUint8List();
    }
    return File(path).readAsBytes();
  }
}
