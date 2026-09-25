import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_photo.dart';
import '../services/photo_capturer.dart';

/// Takes a product photo with the camera or picks one from the gallery.
final class CaptureProductPhoto implements UseCase<ProductPhoto?, PhotoSource> {
  const CaptureProductPhoto(this._capturer);

  final PhotoCapturer _capturer;

  @override
  Future<Result<ProductPhoto?>> call(PhotoSource input) =>
      _capturer.capture(input);
}
