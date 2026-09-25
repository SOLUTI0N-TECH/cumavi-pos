import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_photo.dart';
import '../services/image_background_remover.dart';

/// Runs background removal on the photo captured for a product.
final class RemovePhotoBackground
    implements UseCase<ProductPhoto, ProductPhoto> {
  const RemovePhotoBackground(this._remover);

  final ImageBackgroundRemover _remover;

  @override
  Future<Result<ProductPhoto>> call(ProductPhoto input) =>
      _remover.removeBackground(input);
}
