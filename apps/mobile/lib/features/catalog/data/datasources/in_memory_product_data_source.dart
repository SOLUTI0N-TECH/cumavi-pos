import '../../../../core/constants/app_assets.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/repositories/product_repository.dart';
import 'catalog_seed_data.dart';
import 'product_data_source.dart';

/// Mock catalog kept in memory for the whole app session.
///
/// Registered as a singleton so a sale that reduces stock is reflected
/// everywhere, exactly as a backend would behave.
final class InMemoryProductDataSource implements ProductDataSource {
  InMemoryProductDataSource({Duration? latency})
    : _latency = latency ?? const Duration(milliseconds: 320),
      _products = CatalogSeedData.products();

  final Duration _latency;
  final List<Product> _products;
  int _sequence = 100;

  @override
  Future<List<Product>> fetchProducts() async {
    await _simulateLatency();
    return List<Product>.unmodifiable(_products);
  }

  @override
  Future<List<ProductCategory>> fetchCategories() async {
    await _simulateLatency();
    return List<ProductCategory>.unmodifiable(CatalogSeedData.categories);
  }

  @override
  Future<Product> insertProduct(ProductDraft draft) async {
    await _simulateLatency();
    final Product product = _fromDraft(
      id: 'p-${++_sequence}',
      draft: draft,
      createdAt: DateTime.now(),
    );
    _products.insert(0, product);
    return product;
  }

  @override
  Future<Product> updateProduct(String id, ProductDraft draft) async {
    await _simulateLatency();
    final int index = _indexOf(id);
    final Product updated = _fromDraft(
      id: id,
      draft: draft,
      createdAt: _products[index].createdAt,
    );
    _products[index] = updated;
    return updated;
  }

  @override
  Future<void> applyStockMovements(List<StockMovement> movements) async {
    await _simulateLatency();
    // Validate every movement first so a failed sale changes nothing.
    final List<Product> updated = List<Product>.of(_products);
    for (final StockMovement movement in movements) {
      final int index = _indexOf(movement.productId);
      updated[index] = _reduce(updated[index], movement);
    }
    _products
      ..clear()
      ..addAll(updated);
  }

  Product _reduce(Product product, StockMovement movement) {
    final String? variantId = movement.variantId;
    if (variantId == null) {
      final int remaining = product.stockQuantity - movement.quantity;
      if (remaining < 0) {
        throw DataSourceException(
          FailureCode.insufficientStock,
          detail: product.name,
        );
      }
      return product.copyWith(stockQuantity: remaining);
    }

    final ProductVariant? variant = product.variantById(variantId);
    if (variant == null) {
      throw DataSourceException(
        FailureCode.productNotFound,
        detail: '${product.name} ($variantId)',
      );
    }
    final int remaining = variant.stockQuantity - movement.quantity;
    if (remaining < 0) {
      throw DataSourceException(
        FailureCode.insufficientStock,
        detail: '${product.name} (${variant.label})',
      );
    }
    return product.copyWith(
      variants: <ProductVariant>[
        for (final ProductVariant candidate in product.variants)
          candidate.id == variantId
              ? candidate.copyWith(stockQuantity: remaining)
              : candidate,
      ],
    );
  }

  Product _fromDraft({
    required String id,
    required ProductDraft draft,
    required DateTime createdAt,
  }) {
    final ProductCategory category = CatalogSeedData.categories.firstWhere(
      (ProductCategory candidate) => candidate.id == draft.categoryId,
      orElse: () =>
          throw const DataSourceException(FailureCode.categoryNotFound),
    );

    return Product(
      id: id,
      name: draft.name.trim(),
      category: category,
      salePrice: draft.salePrice,
      costPrice: draft.costPrice,
      stockQuantity: draft.hasVariants ? 0 : draft.stockQuantity,
      images: draft.images.isEmpty
          ? <ProductImage>[
              ProductImage(id: '$id-img-1', path: AppAssets.demoPhotoWhite),
            ]
          : draft.images,
      createdAt: createdAt,
      description: draft.description.trim(),
      options: draft.hasVariants ? draft.options : const <VariantOption>[],
      variants: draft.variants,
    );
  }

  int _indexOf(String productId) {
    final int index = _products.indexWhere(
      (Product product) => product.id == productId,
    );
    if (index == -1) {
      throw DataSourceException(FailureCode.productNotFound, detail: productId);
    }
    return index;
  }

  Future<void> _simulateLatency() => Future<void>.delayed(_latency);
}
