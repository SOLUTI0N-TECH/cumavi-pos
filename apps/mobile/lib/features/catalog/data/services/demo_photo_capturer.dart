import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/services/photo_capturer.dart';

/// Returns the bundled demo photo. Used in tests and on platforms without a
/// camera (desktop, web).
final class DemoPhotoCapturer implements PhotoCapturer {
  const DemoPhotoCapturer();

  @override
  Future<Result<ProductPhoto?>> capture(PhotoSource source) async {
    return const Success<ProductPhoto?>(
      ProductPhoto(originalPath: AppAssets.demoPhotoOriginal),
    );
  }
}
