import 'package:equatable/equatable.dart';

/// Background treatment applied to a product photo.
enum PhotoBackground {
  /// The picture as taken by the camera.
  original,

  /// Cutout composited over a white background (default for the catalog).
  white,

  /// Cutout kept as a transparent PNG.
  transparent,
}

/// Photo attached to a product while it is being created.
///
/// [originalPath] is what the camera produced; [cutoutPath] is the result of
/// the background removal and stays `null` until it runs.
final class ProductPhoto extends Equatable {
  const ProductPhoto({
    required this.originalPath,
    this.cutoutPath,
    this.whiteBackgroundPath,
    this.background = PhotoBackground.original,
  });

  final String originalPath;
  final String? cutoutPath;
  final String? whiteBackgroundPath;
  final PhotoBackground background;

  bool get hasCutout => cutoutPath != null;

  /// Path that should be displayed for the selected [background].
  String get displayPath => switch (background) {
    PhotoBackground.original => originalPath,
    PhotoBackground.white => whiteBackgroundPath ?? originalPath,
    PhotoBackground.transparent => cutoutPath ?? originalPath,
  };

  ProductPhoto copyWith({
    String? originalPath,
    String? cutoutPath,
    String? whiteBackgroundPath,
    PhotoBackground? background,
  }) {
    return ProductPhoto(
      originalPath: originalPath ?? this.originalPath,
      cutoutPath: cutoutPath ?? this.cutoutPath,
      whiteBackgroundPath: whiteBackgroundPath ?? this.whiteBackgroundPath,
      background: background ?? this.background,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    originalPath,
    cutoutPath,
    whiteBackgroundPath,
    background,
  ];
}
