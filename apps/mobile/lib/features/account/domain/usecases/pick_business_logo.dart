import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product_photo.dart';
import '../../../catalog/domain/services/photo_capturer.dart';

/// Takes or picks the business logo with the same camera/gallery service
/// the product photos use. `null` when the seller cancels.
final class PickBusinessLogo implements UseCase<String?, PhotoSource> {
  const PickBusinessLogo(this._capturer);

  final PhotoCapturer _capturer;

  @override
  Future<Result<String?>> call(PhotoSource source) async {
    return switch (await _capturer.capture(source)) {
      Success<ProductPhoto?>(:final ProductPhoto? value) => Success<String?>(
        value?.originalPath,
      ),
      Failed<ProductPhoto?>(:final failure) => Failed<String?>(failure),
    };
  }
}
