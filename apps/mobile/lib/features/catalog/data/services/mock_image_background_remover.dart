import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/services/image_background_remover.dart';

/// Stands in for the real background-removal service.
///
/// It waits like a network call and returns the bundled cutout assets, so the
/// UI can show the before/after comparison exactly as it will once the
/// backend exists.
final class MockImageBackgroundRemover implements ImageBackgroundRemover {
  const MockImageBackgroundRemover({
    this.latency = const Duration(milliseconds: 1400),
  });

  final Duration latency;

  @override
  Future<Result<ProductPhoto>> removeBackground(ProductPhoto photo) async {
    await Future<void>.delayed(latency);
    return Success<ProductPhoto>(
      photo.copyWith(
        cutoutPath: AppAssets.demoPhotoTransparent,
        whiteBackgroundPath: AppAssets.demoPhotoWhite,
        background: PhotoBackground.white,
      ),
    );
  }
}
