import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/usecases/product_code_rules.dart';
import '../../domain/usecases/product_draft_rules.dart';

enum ProductFormStatus {
  /// Edit mode, while the product is being read.
  loading,
  editing,
  removingBackground,
  submitting,
  saved,
  failure,
}

enum ProductFormMode { create, edit }

final class ProductFormState extends Equatable {
  const ProductFormState({
    this.mode = ProductFormMode.create,
    this.productId,
    this.status = ProductFormStatus.editing,
    this.categories = const <ProductCategory>[],
    this.name = '',
    this.description = '',
    this.categoryId,
    this.salePrice,
    this.costPrice,
    this.stockQuantity = 1,
    this.photo,
    this.mainImageId = mainImageDefaultId,
    this.removeBackground = false,
    this.extraImages = const <ProductImage>[],
    this.options = const <VariantOption>[],
    this.variants = const <ProductVariant>[],
    this.sku = '',
    this.barcode = '',
    this.savedProduct,
    this.failure,
  });

  static const String mainImageDefaultId = 'img-main';

  final ProductFormMode mode;

  /// Product being edited; `null` when creating one.
  final String? productId;
  final ProductFormStatus status;
  final List<ProductCategory> categories;
  final String name;
  final String description;
  final String? categoryId;
  final double? salePrice;
  final double? costPrice;

  /// Stock of a product without variants.
  final int stockQuantity;

  /// Main photo, with its background removal.
  final ProductPhoto? photo;

  /// Id the main photo keeps in the gallery, so variants can point at it.
  final String mainImageId;

  /// Whether the "Quitar fondo" switch is on.
  final bool removeBackground;

  /// Photos after the main one.
  final List<ProductImage> extraImages;

  /// Variant types (`Color`, `Talla`) and their values.
  final List<VariantOption> options;

  /// One per combination of [options]' values, with its stock and photo.
  final List<ProductVariant> variants;

  /// Codes of the product as typed; each variant keeps its own.
  final String sku;
  final String barcode;

  /// Set once the product is stored.
  final Product? savedProduct;
  final Failure? failure;

  bool get isEditing => mode == ProductFormMode.edit;

  /// Gallery as it will be stored: main photo first.
  List<ProductImage> get images => <ProductImage>[
    if (photo case final ProductPhoto photo)
      ProductImage(id: mainImageId, path: photo.displayPath),
    ...extraImages,
  ];

  bool get hasVariants => variants.isNotEmpty;

  /// Photo [variant] shows: its own or, without one, the main photo;
  /// `null` while the product has no photo at all.
  String? imagePathOf(ProductVariant variant) {
    final String? mainPath = photo?.displayPath;
    final String? imageId = variant.imageId;
    if (imageId == null) return mainPath;
    return images
            .where((ProductImage image) => image.id == imageId)
            .firstOrNull
            ?.path ??
        mainPath;
  }

  /// Type the variants are grouped by and share a photo by (`Color` in
  /// `Color × Talla`: every red size shows the red photo); `null` with fewer
  /// than two types with values.
  String? get groupingOption {
    final List<VariantOption> withValues = options
        .where((VariantOption option) => option.values.isNotEmpty)
        .toList();
    return withValues.length < 2 ? null : withValues.first.name;
  }

  int get totalStock => hasVariants
      ? variants.fold(
          0,
          (int total, ProductVariant variant) => total + variant.stockQuantity,
        )
      : stockQuantity;

  /// Types still waiting for their first value.
  bool get hasIncompleteOptions => options.any(
    (VariantOption option) =>
        option.name.trim().isEmpty || option.values.isEmpty,
  );

  double get unitProfit => (salePrice ?? 0) - (costPrice ?? 0);

  double get profitMargin =>
      (salePrice ?? 0) <= 0 ? 0 : unitProfit / salePrice!;

  bool get hasProfitInfo =>
      salePrice != null && costPrice != null && salePrice! > 0;

  bool get isBusy =>
      status == ProductFormStatus.loading ||
      status == ProductFormStatus.submitting ||
      status == ProductFormStatus.removingBackground;

  bool get hasValidCodes =>
      ProductCodeRules.isValidSku(sku) &&
      ProductCodeRules.isValidBarcode(barcode);

  bool get canSubmit =>
      hasValidCodes &&
      name.trim().length >= ProductDraftRules.minNameLength &&
      categoryId != null &&
      (salePrice ?? 0) > 0 &&
      costPrice != null &&
      !hasIncompleteOptions &&
      !isBusy;

  ProductFormState copyWith({
    ProductFormMode? mode,
    String? productId,
    ProductFormStatus? status,
    List<ProductCategory>? categories,
    String? name,
    String? description,
    String? categoryId,
    double? salePrice,
    double? costPrice,
    int? stockQuantity,
    ProductPhoto? photo,
    String? mainImageId,
    bool? removeBackground,
    List<ProductImage>? extraImages,
    List<VariantOption>? options,
    List<ProductVariant>? variants,
    String? sku,
    String? barcode,
    Product? savedProduct,
    Failure? failure,
  }) {
    return ProductFormState(
      mode: mode ?? this.mode,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      categories: categories ?? this.categories,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      salePrice: salePrice ?? this.salePrice,
      costPrice: costPrice ?? this.costPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      photo: photo ?? this.photo,
      mainImageId: mainImageId ?? this.mainImageId,
      removeBackground: removeBackground ?? this.removeBackground,
      extraImages: extraImages ?? this.extraImages,
      options: options ?? this.options,
      variants: variants ?? this.variants,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      savedProduct: savedProduct ?? this.savedProduct,
      failure: failure,
    );
  }

  /// Same state with a cleared price or cost (typing an empty field).
  ProductFormState withPrices({
    required double? salePrice,
    required double? costPrice,
  }) {
    return ProductFormState(
      mode: mode,
      productId: productId,
      status: status,
      categories: categories,
      name: name,
      description: description,
      categoryId: categoryId,
      salePrice: salePrice,
      costPrice: costPrice,
      stockQuantity: stockQuantity,
      photo: photo,
      mainImageId: mainImageId,
      removeBackground: removeBackground,
      extraImages: extraImages,
      options: options,
      variants: variants,
      sku: sku,
      barcode: barcode,
      savedProduct: savedProduct,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    mode,
    productId,
    status,
    categories,
    name,
    description,
    categoryId,
    salePrice,
    costPrice,
    stockQuantity,
    photo,
    mainImageId,
    removeBackground,
    extraImages,
    options,
    variants,
    sku,
    barcode,
    savedProduct,
    failure,
  ];
}
