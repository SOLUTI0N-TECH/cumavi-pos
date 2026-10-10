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
    this.sku,
    this.barcode,
    this.showOnline = true,
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

  /// Optional codes of the product; each variant carries its own.
  final String? sku;
  final String? barcode;

  /// Listed in the online catalog.
  final bool showOnline;

  bool get hasVariants => variants.isNotEmpty;

  /// Same draft with no units: a new product gets its stock as
  /// "Inventario inicial" movements.
  ProductDraft withoutStock() => ProductDraft(
    name: name,
    categoryId: categoryId,
    salePrice: salePrice,
    costPrice: costPrice,
    description: description,
    images: images,
    options: options,
    variants: <ProductVariant>[
      for (final ProductVariant variant in variants)
        variant.copyWith(stockQuantity: 0),
    ],
    sku: sku,
    barcode: barcode,
    showOnline: showOnline,
  );

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
    sku,
    barcode,
    showOnline,
  ];
}
