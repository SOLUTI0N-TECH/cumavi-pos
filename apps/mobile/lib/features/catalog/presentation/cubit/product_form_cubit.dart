import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/services/photo_capturer.dart';
import '../../domain/usecases/capture_product_photo.dart';
import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/remove_photo_background.dart';
import '../../domain/usecases/update_product.dart';
import 'product_form_state.dart';

/// Drives the product form, to create a product or edit one: photos (with
/// the background removal of the main one), data, and variants with their
/// stock and photo.
class ProductFormCubit extends Cubit<ProductFormState> {
  ProductFormCubit({
    required GetCategories getCategories,
    required GetProduct getProduct,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required CaptureProductPhoto captureProductPhoto,
    required RemovePhotoBackground removePhotoBackground,
  }) : _getCategories = getCategories,
       _getProduct = getProduct,
       _createProduct = createProduct,
       _updateProduct = updateProduct,
       _captureProductPhoto = captureProductPhoto,
       _removePhotoBackground = removePhotoBackground,
       super(const ProductFormState());

  final GetCategories _getCategories;
  final GetProduct _getProduct;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final CaptureProductPhoto _captureProductPhoto;
  final RemovePhotoBackground _removePhotoBackground;

  int _imageSequence = 0;

  /// Loads the categories and, to edit, the product [productId].
  Future<void> load({String? productId}) async {
    // A cubit reused for another product, or to create one after editing,
    // starts from a blank form.
    if (productId != state.productId) {
      emit(ProductFormState(categories: state.categories));
    }
    if (productId != null) {
      emit(
        state.copyWith(
          mode: ProductFormMode.edit,
          productId: productId,
          status: ProductFormStatus.loading,
        ),
      );
    }

    if (await _getCategories(const NoParams())
        case Success<List<ProductCategory>>(
          :final List<ProductCategory> value,
        )) {
      emit(
        state.copyWith(
          categories: value,
          categoryId: state.categoryId ?? value.firstOrNull?.id,
        ),
      );
    }

    if (productId == null) return;
    switch (await _getProduct(productId)) {
      case Success<Product>(:final Product value):
        emit(_prefilledWith(value));
      case Failed<Product>(:final failure):
        emit(
          state.copyWith(status: ProductFormStatus.failure, failure: failure),
        );
    }
  }

  ProductFormState _prefilledWith(Product product) {
    final ProductImage? main = product.images.firstOrNull;
    return state.copyWith(
      status: ProductFormStatus.editing,
      name: product.name,
      description: product.description,
      categoryId: product.category.id,
      salePrice: product.salePrice,
      costPrice: product.costPrice,
      stockQuantity: product.hasVariants ? 0 : product.stockQuantity,
      photo: main == null ? null : ProductPhoto(originalPath: main.path),
      mainImageId: main?.id,
      extraImages: product.images.skip(1).toList(),
      options: product.options,
      variants: product.variants,
    );
  }

  // ------------------------------------------------------------ basic data

  void nameChanged(String name) => emit(state.copyWith(name: name));

  void descriptionChanged(String description) =>
      emit(state.copyWith(description: description));

  void categorySelected(String categoryId) =>
      emit(state.copyWith(categoryId: categoryId));

  void salePriceChanged(double? price) =>
      emit(state.withPrices(salePrice: price, costPrice: state.costPrice));

  void costPriceChanged(double? cost) =>
      emit(state.withPrices(salePrice: state.salePrice, costPrice: cost));

  void incrementQuantity() =>
      emit(state.copyWith(stockQuantity: state.stockQuantity + 1));

  void decrementQuantity() => emit(
    state.copyWith(
      stockQuantity: state.stockQuantity <= 0 ? 0 : state.stockQuantity - 1,
    ),
  );

  // ------------------------------------------------------------ main photo

  /// Takes or picks the main photo and removes its background right away,
  /// since a clean white background is what the catalog shows by default.
  Future<void> capturePhoto(PhotoSource source) async {
    switch (await _captureProductPhoto(source)) {
      case Success<ProductPhoto?>(value: null):
        return;
      case Success<ProductPhoto?>(:final ProductPhoto? value):
        emit(state.copyWith(photo: value, removeBackground: false));
        await toggleBackgroundRemoval(true);
      case Failed<ProductPhoto?>(:final failure):
        emit(
          state.copyWith(status: ProductFormStatus.failure, failure: failure),
        );
    }
  }

  Future<void> toggleBackgroundRemoval(bool enabled) async {
    final ProductPhoto? photo = state.photo;
    if (photo == null) return;

    if (!enabled) {
      emit(
        state.copyWith(
          removeBackground: false,
          photo: photo.copyWith(background: PhotoBackground.original),
        ),
      );
      return;
    }

    if (photo.hasCutout) {
      emit(
        state.copyWith(
          removeBackground: true,
          photo: photo.copyWith(background: PhotoBackground.white),
        ),
      );
      return;
    }

    emit(state.copyWith(status: ProductFormStatus.removingBackground));

    switch (await _removePhotoBackground(photo)) {
      case Success<ProductPhoto>(:final ProductPhoto value):
        emit(
          state.copyWith(
            status: ProductFormStatus.editing,
            photo: value,
            removeBackground: true,
          ),
        );
      case Failed<ProductPhoto>(:final failure):
        emit(
          state.copyWith(
            status: ProductFormStatus.failure,
            removeBackground: false,
            failure: failure,
          ),
        );
    }
  }

  void backgroundSelected(PhotoBackground background) {
    final ProductPhoto? photo = state.photo;
    if (photo == null) return;
    emit(
      state.copyWith(
        photo: photo.copyWith(background: background),
        removeBackground: background != PhotoBackground.original,
      ),
    );
  }

  // --------------------------------------------------------- more photos

  /// Adds a photo after the main one; variants can then use it.
  Future<void> addImage(PhotoSource source) async {
    switch (await _captureProductPhoto(source)) {
      case Success<ProductPhoto?>(value: null):
        return;
      case Success<ProductPhoto?>(:final ProductPhoto? value):
        emit(
          state.copyWith(
            extraImages: <ProductImage>[
              ...state.extraImages,
              ProductImage(id: _newImageId(), path: value!.originalPath),
            ],
          ),
        );
      case Failed<ProductPhoto?>(:final failure):
        emit(
          state.copyWith(status: ProductFormStatus.failure, failure: failure),
        );
    }
  }

  /// Removes an extra photo; the variants that used it go back to the main
  /// photo.
  void removeImage(String imageId) {
    emit(
      state.copyWith(
        extraImages: state.extraImages
            .where((ProductImage image) => image.id != imageId)
            .toList(),
        variants: <ProductVariant>[
          for (final ProductVariant variant in state.variants)
            variant.imageId == imageId ? variant.withoutImage() : variant,
        ],
      ),
    );
  }

  String _newImageId() =>
      'img-${DateTime.now().microsecondsSinceEpoch}-${++_imageSequence}';

  // ------------------------------------------------------------- variants

  /// Adds a variant type (`Color`, `Talla`...). Ignored when empty or
  /// already there.
  void addOption(String name) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty || _hasOption(trimmed)) return;
    _setOptions(<VariantOption>[
      ...state.options,
      VariantOption(name: trimmed, values: const <String>[]),
    ]);
  }

  void renameOption(int index, String name) {
    final String trimmed = name.trim();
    final VariantOption option = state.options[index];
    if (trimmed.isEmpty || trimmed == option.name || _hasOption(trimmed)) {
      return;
    }
    // The variants are keyed by option name: carry their data over.
    final List<ProductVariant> renamed = <ProductVariant>[
      for (final ProductVariant variant in state.variants)
        ProductVariant(
          id: variant.id,
          optionValues: <String, String>{
            for (final MapEntry<String, String> entry
                in variant.optionValues.entries)
              entry.key == option.name ? trimmed : entry.key: entry.value,
          },
          stockQuantity: variant.stockQuantity,
          imageId: variant.imageId,
        ),
    ];
    emit(state.copyWith(variants: renamed));
    _setOptions(<VariantOption>[
      for (int i = 0; i < state.options.length; i++)
        i == index ? option.copyWith(name: trimmed) : state.options[i],
    ]);
  }

  void removeOption(int index) {
    _setOptions(<VariantOption>[
      for (int i = 0; i < state.options.length; i++)
        if (i != index) state.options[i],
    ]);
  }

  /// Adds a value (`Rojo`, `M`) to the type at [optionIndex]. Ignored when
  /// empty or repeated.
  void addOptionValue(int optionIndex, String value) {
    final String trimmed = value.trim();
    final VariantOption option = state.options[optionIndex];
    final bool repeated = option.values.any(
      (String existing) => existing.toLowerCase() == trimmed.toLowerCase(),
    );
    if (trimmed.isEmpty || repeated) return;
    _replaceOption(
      optionIndex,
      option.copyWith(values: <String>[...option.values, trimmed]),
    );
  }

  void removeOptionValue(int optionIndex, String value) {
    final VariantOption option = state.options[optionIndex];
    _replaceOption(
      optionIndex,
      option.copyWith(
        values: option.values.where((String v) => v != value).toList(),
      ),
    );
  }

  void variantStockChanged(String variantId, int stock) =>
      _updateVariant(variantId, (ProductVariant variant) {
        return variant.copyWith(stockQuantity: stock < 0 ? 0 : stock);
      });

  void incrementVariantStock(String variantId) =>
      _updateVariant(variantId, (ProductVariant variant) {
        return variant.copyWith(stockQuantity: variant.stockQuantity + 1);
      });

  void decrementVariantStock(String variantId) =>
      _updateVariant(variantId, (ProductVariant variant) {
        final int stock = variant.stockQuantity;
        return variant.copyWith(stockQuantity: stock <= 0 ? 0 : stock - 1);
      });

  /// Sets the photo of a variant (`null` = the main photo). With
  /// [sharedOption] (e.g. `Color`), every variant with the same value of
  /// that option (all the `Rojo` ones) gets it too.
  void variantImageSelected(
    String variantId,
    String? imageId, {
    String? sharedOption,
  }) {
    final ProductVariant? chosen = state.variants
        .where((ProductVariant variant) => variant.id == variantId)
        .firstOrNull;
    if (chosen == null) return;
    final String? sharedValue = sharedOption == null
        ? null
        : chosen.optionValues[sharedOption];

    emit(
      state.copyWith(
        variants: <ProductVariant>[
          for (final ProductVariant variant in state.variants)
            if (variant.id == variantId ||
                (sharedValue != null &&
                    variant.optionValues[sharedOption] == sharedValue))
              imageId == null
                  ? variant.withoutImage()
                  : variant.copyWith(imageId: imageId)
            else
              variant,
        ],
      ),
    );
  }

  bool _hasOption(String name) => state.options.any(
    (VariantOption option) => option.name.toLowerCase() == name.toLowerCase(),
  );

  void _replaceOption(int index, VariantOption option) {
    _setOptions(<VariantOption>[
      for (int i = 0; i < state.options.length; i++)
        i == index ? option : state.options[i],
    ]);
  }

  void _updateVariant(
    String variantId,
    ProductVariant Function(ProductVariant variant) update,
  ) {
    emit(
      state.copyWith(
        variants: <ProductVariant>[
          for (final ProductVariant variant in state.variants)
            variant.id == variantId ? update(variant) : variant,
        ],
      ),
    );
  }

  /// Rebuilds the combinations after the options change. A combination
  /// that already existed keeps its stock and photo; a new one starts with
  /// no stock and inherits the photo of the variants it grew from (see
  /// [_inheritedImageId]).
  void _setOptions(List<VariantOption> options) {
    final Map<String, ProductVariant> previous = <String, ProductVariant>{
      for (final ProductVariant variant in state.variants) variant.id: variant,
    };

    final List<ProductVariant> variants = <ProductVariant>[
      for (final Map<String, String> values in combinationsOf(options))
        _variantFor(values, previous),
    ];

    emit(
      state.copyWith(
        options: options,
        variants: variants,
        // Leaving variants: the product keeps the stock they had.
        stockQuantity: variants.isEmpty && state.hasVariants
            ? state.totalStock
            : null,
      ),
    );
  }

  ProductVariant _variantFor(
    Map<String, String> values,
    Map<String, ProductVariant> previous,
  ) {
    final ProductVariant? existing = previous[ProductVariant.idFor(values)];
    if (existing != null) {
      return ProductVariant(
        id: existing.id,
        optionValues: values,
        stockQuantity: existing.stockQuantity,
        imageId: existing.imageId,
      );
    }
    return ProductVariant.fromValues(
      optionValues: values,
      stockQuantity: 0,
      imageId: _inheritedImageId(values, previous.values),
    );
  }

  /// Photo of a new combination: the one shared by every previous variant
  /// with the values it already had. Sizes added to `Rojo` (a new type, or
  /// size 43 next to 38–42) keep the red photo; a new color, whose sizes
  /// match variants of different colors, starts with the main photo.
  String? _inheritedImageId(
    Map<String, String> values,
    Iterable<ProductVariant> previous,
  ) {
    final Map<String, String> known = <String, String>{
      for (final MapEntry<String, String> entry in values.entries)
        if (previous.any(
          (ProductVariant variant) =>
              variant.optionValues[entry.key] == entry.value,
        ))
          entry.key: entry.value,
    };
    if (known.isEmpty) return null;

    final Set<String?> imageIds = previous
        .where((ProductVariant variant) => variant.matches(known))
        .map((ProductVariant variant) => variant.imageId)
        .toSet();
    return imageIds.length == 1 ? imageIds.single : null;
  }

  // ---------------------------------------------------------------- save

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: ProductFormStatus.submitting));

    final ProductDraft draft = ProductDraft(
      name: state.name,
      categoryId: state.categoryId!,
      salePrice: state.salePrice ?? 0,
      costPrice: state.costPrice ?? 0,
      description: state.description,
      stockQuantity: state.stockQuantity,
      images: state.images,
      options: state.options,
      variants: state.variants,
    );
    final String? productId = state.productId;
    final Result<Product> result = productId == null
        ? await _createProduct(draft)
        : await _updateProduct(
            ProductUpdate(productId: productId, draft: draft),
          );

    switch (result) {
      case Success<Product>(:final Product value):
        emit(
          state.copyWith(status: ProductFormStatus.saved, savedProduct: value),
        );
      case Failed<Product>(:final failure):
        emit(
          state.copyWith(status: ProductFormStatus.failure, failure: failure),
        );
    }
  }
}
