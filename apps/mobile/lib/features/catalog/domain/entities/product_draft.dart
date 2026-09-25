import 'package:equatable/equatable.dart';

import 'product_image.dart';
import 'product_variant.dart';

/// Data captured by the product form, to create or edit a product.
final class ProductDraft extends Equatable {
  const ProductDraft({
    required this.name,
    required this.categoryId,
    required this.salePrice,
    required this.costPrice,
    this.description = '',
    this.stockQuantity = 0,
    this.images = const <ProductImage>[],
    this.options = const <VariantOption>[],
    this.variants = const <ProductVariant>[],
  });

  final String name;
  final String categoryId;
  final double salePrice;
  final double costPrice;
  final String description;

  /// Stock of a product without variants; ignored when [variants] exist.
  final int stockQuantity;

  /// Gallery; the first one is the main photo.
  final List<ProductImage> images;
  final List<VariantOption> options;
  final List<ProductVariant> variants;

  bool get hasVariants => variants.isNotEmpty;

  @override
  List<Object?> get props => <Object?>[
    name,
    categoryId,
    salePrice,
    costPrice,
    description,
    stockQuantity,
    images,
    options,
    variants,
  ];
}
