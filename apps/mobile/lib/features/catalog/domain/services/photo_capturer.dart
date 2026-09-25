import '../../../../core/utils/result.dart';
import '../entities/product_photo.dart';

/// Where the product photo comes from.
enum PhotoSource { camera, gallery }

/// Obtains a product photo from the device.
abstract interface class PhotoCapturer {
  /// The captured photo, or `null` when the user cancelled.
  Future<Result<ProductPhoto?>> capture(PhotoSource source);
}
