import '../../../../core/utils/result.dart';
import '../entities/product_photo.dart';

/// Removes the background of a product photo.
///
/// The real implementation will call the same service the Cumavi seller
/// onboarding uses; the mock returns a pre-processed asset.
abstract interface class ImageBackgroundRemover {
  Future<Result<ProductPhoto>> removeBackground(ProductPhoto photo);
}
