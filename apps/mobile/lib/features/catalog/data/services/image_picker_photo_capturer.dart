import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/services/photo_capturer.dart';

/// Camera and gallery access through `image_picker`.
final class ImagePickerPhotoCapturer implements PhotoCapturer {
  ImagePickerPhotoCapturer({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  /// Large enough for the catalog, small enough for fast background removal.
  static const double _maxDimension = 1600;
  static const int _jpegQuality = 88;

  final ImagePicker _picker;

  @override
  Future<Result<ProductPhoto?>> capture(PhotoSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source == PhotoSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _maxDimension,
        maxHeight: _maxDimension,
        imageQuality: _jpegQuality,
      );
      if (file == null) return const Success<ProductPhoto?>(null);
      return Success<ProductPhoto?>(ProductPhoto(originalPath: file.path));
    } on PlatformException catch (error) {
      return Failed<ProductPhoto?>(
        ConflictFailure(
          error.code.contains('access_denied')
              ? FailureCode.cameraPermissionDenied
              : FailureCode.cameraUnavailable,
        ),
      );
    }
  }
}
