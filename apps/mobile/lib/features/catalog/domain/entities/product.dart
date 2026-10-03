import 'package:equatable/equatable.dart';

import 'product_category.dart';
import 'product_image.dart';
import 'product_variant.dart';
import 'stock_level.dart';

/// A sellable item of the store.
///
/// A product either has its own stock or, when it varies (color, size...),
/// one stock per [ProductVariant]; its [stockQuantity] is then their sum.
final class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.salePrice,
    required this.costPrice,
    required this.images,
    required this.createdAt,
    int stockQuantity = 0,
    this.description = '',
    this.options = const <VariantOption>[],
    this.variants = const <ProductVariant>[],
    this.sku,
    this.barcode,
  }) : _ownStock = stockQuantity;

  final String id;
  final String name;
  final ProductCategory category;
  final double salePrice;
  final double costPrice;

  /// Gallery; the first one is the main photo.
  final List<ProductImage> images;
  final DateTime createdAt;
  final String description;

  /// Ways the product varies (`Color`, `Talla`); empty for simple products.
  final List<VariantOption> options;
  final List<ProductVariant> variants;

  /// The seller's own code (`CAL-001`); variants may have theirs.
  final String? sku;

  /// Code on the label (EAN-13, UPC, Code 128…); variants may have theirs.
  final String? barcode;

  /// Stock of a product without variants.
  final int _ownStock;

  bool get hasVariants => variants.isNotEmpty;

  int get stockQuantity => hasVariants
      ? variants.fold(
          0,
          (int total, ProductVariant variant) => total + variant.stockQuantity,
        )
      : _ownStock;

  /// Main photo.
  String get imagePath => images.isEmpty ? '' : images.first.path;

  /// Photo of [variant], falling back to the main one.
  String imagePathOf(ProductVariant? variant) =>
      imageById(variant?.imageId)?.path ?? imagePath;

  ProductImage? imageById(String? imageId) => imageId == null
      ? null
      : images.where((ProductImage image) => image.id == imageId).firstOrNull;

  /// Whether the product or any variant has a SKU or barcode.
  bool get hasCodes =>
      sku != null ||
      barcode != null ||
      variants.any((ProductVariant variant) => variant.hasCodes);

  ProductVariant? variantById(String variantId) => variants
      .where((ProductVariant variant) => variant.id == variantId)
      .firstOrNull;

  StockLevel get stockLevel => StockRules.levelFor(stockQuantity);

  bool get isSellable => stockLevel.isSellable;

  /// Money earned per unit sold.
  double get unitProfit => salePrice - costPrice;

  /// Profit over the sale price, `0` when the price is not set yet.
  double get profitMargin => salePrice <= 0 ? 0 : unitProfit / salePrice;

  Product copyWith({
    String? name,
    ProductCategory? category,
    double? salePrice,
    double? costPrice,
    int? stockQuantity,
    List<ProductImage>? images,
    String? description,
    List<VariantOption>? options,
    List<ProductVariant>? variants,
    String? sku,
    String? barcode,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      salePrice: salePrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? _ownStock,
      images: images ?? this.images,
      createdAt: createdAt,
      description: description ?? this.description,
      options: options ?? this.options,
      variants: variants ?? this.variants,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    category,
    salePrice,
    costPrice,
    _ownStock,
    images,
    createdAt,
    description,
    options,
    variants,
    sku,
    barcode,
  ];
}
