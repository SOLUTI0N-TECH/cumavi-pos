import 'package:equatable/equatable.dart';

/// One photo of a product's gallery. Variants point at it by [id].
final class ProductImage extends Equatable {
  const ProductImage({required this.id, required this.path});

  final String id;

  /// Bundled asset while the catalog is mocked, a file after capturing it,
  /// a remote URL once there is a backend.
  final String path;

  @override
  List<Object?> get props => <Object?>[id, path];
}
