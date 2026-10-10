import '../../../../core/constants/app_assets.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/usecases/product_code_rules.dart';
import 'catalog_seed_data.dart';
import 'product_data_source.dart';

/// Mock catalog kept in memory for the whole app session.
///
/// Registered as a singleton so a sale that reduces stock is reflected
/// everywhere, exactly as a backend would behave.
final class InMemoryProductDataSource implements ProductDataSource {
  InMemoryProductDataSource({Duration? latency})
    : _latency = latency ?? const Duration(milliseconds: 320),
      _products = CatalogSeedData.products(),
      _categories = List<ProductCategory>.of(CatalogSeedData.categories);

  final Duration _latency;
  final List<Product> _products;
  final List<ProductCategory> _categories;
  int _sequence = 100;
  int _categorySequence = 100;

  @override
  Future<List<Product>> fetchProducts() async {
    await _simulateLatency();
    return List<Product>.unmodifiable(_products);
  }

  @override
  Future<List<ProductCategory>> fetchCategories({
    bool includeArchived = false,
  }) async {
    await _simulateLatency();
    final List<ProductCategory> categories =
        _categories
            .where(
              (ProductCategory category) =>
                  includeArchived || !category.isArchived,
            )
            .toList()
          ..sort(
            (ProductCategory a, ProductCategory b) =>
                a.sortOrder.compareTo(b.sortOrder),
          );
    return List<ProductCategory>.unmodifiable(categories);
  }

  @override
  Future<ProductCategory> insertCategory(String name) async {
    await _simulateLatency();
    _ensureNameIsFree(name);
    final ProductCategory category = ProductCategory(
      id: 'category-${++_categorySequence}',
      name: name,
      sortOrder: _categories.isEmpty
          ? 0
          : _categories
                    .map((ProductCategory category) => category.sortOrder)
                    .reduce((int a, int b) => a > b ? a : b) +
                1,
    );
    _categories.add(category);
    return category;
  }

  @override
  Future<ProductCategory> updateCategory(
    String id, {
    String? name,
    bool? archived,
  }) async {
    await _simulateLatency();
    final int index = _categoryIndex(id);
    if (name != null) _ensureNameIsFree(name, exceptId: id);
    final ProductCategory updated = _categories[index].copyWith(
      name: name,
      isArchived: archived,
    );
    _categories[index] = updated;
    // Products embed their category, like the API's joined response.
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].category.id == id) {
        _products[i] = _products[i].copyWith(category: updated);
      }
    }
    return updated;
  }

  @override
  Future<void> reorderCategories(List<String> orderedIds) async {
    await _simulateLatency();
    for (int position = 0; position < orderedIds.length; position++) {
      final int index = _categoryIndex(orderedIds[position]);
      _categories[index] = _categories[index].copyWith(sortOrder: position);
    }
  }

  int _categoryIndex(String id) {
    final int index = _categories.indexWhere(
      (ProductCategory category) => category.id == id,
    );
    if (index == -1) {
      throw const DataSourceException(FailureCode.categoryNotFound);
    }
    return index;
  }

  /// Names are unique ignoring case and accents, archived ones included.
  void _ensureNameIsFree(String name, {String? exceptId}) {
    final String normalized = TextNormalizer.normalize(name);
    final bool taken = _categories.any(
      (ProductCategory category) =>
          category.id != exceptId &&
          TextNormalizer.normalize(category.name) == normalized,
    );
    if (taken) {
      throw DataSourceException(FailureCode.categoryNameTaken, detail: name);
    }
  }

  @override
  Future<Product> insertProduct(ProductDraft draft) async {
    await _simulateLatency();
    _ensureCodesAreFree(draft);
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
    _ensureCodesAreFree(draft, exceptProductId: id);
    final Product existing = _products[index];
    final Product edited = _fromDraft(
      id: id,
      draft: draft,
      createdAt: existing.createdAt,
    );
    // Stock only changes through movements: editing keeps it. A new
    // variant starts empty and gets its units with a receipt.
    final Product updated = edited.copyWith(
      stockQuantity: existing.hasVariants ? 0 : existing.stockQuantity,
      variants: <ProductVariant>[
        for (final ProductVariant variant in edited.variants)
          variant.copyWith(
            stockQuantity: existing.variantById(variant.id)?.stockQuantity ?? 0,
          ),
      ],
    );
    _products[index] = updated;
    return updated;
  }

  /// Applies stock [changes] to the catalog, all or none, and says what
  /// each one left. Only the mock ledger calls it: with a backend, recording
  /// a movement updates the stock on the server.
  Future<List<StockChangeResult>> applyStockChanges(
    List<StockChange> changes,
  ) async {
    // Validate every change first so a failed batch changes nothing.
    final List<Product> updated = List<Product>.of(_products);
    final List<StockChangeResult> results = <StockChangeResult>[];
    for (final StockChange change in changes) {
      final int index = _indexOf(change.productId);
      final (Product product, StockChangeResult result) = _apply(
        updated[index],
        change,
      );
      updated[index] = product;
      results.add(result);
    }
    _products
      ..clear()
      ..addAll(updated);
    return results;
  }

  (Product, StockChangeResult) _apply(Product product, StockChange change) {
    final String? variantId = change.variantId;
    if (variantId == null) {
      final int remaining = product.stockQuantity + change.delta;
      if (product.hasVariants || remaining < 0) {
        throw DataSourceException(
          FailureCode.insufficientStock,
          detail: product.name,
        );
      }
      return (
        product.copyWith(stockQuantity: remaining),
        StockChangeResult(productName: product.name, stockAfter: remaining),
      );
    }

    final ProductVariant? variant = product.variantById(variantId);
    if (variant == null) {
      throw DataSourceException(
        FailureCode.productNotFound,
        detail: '${product.name} ($variantId)',
      );
    }
    final int remaining = variant.stockQuantity + change.delta;
    if (remaining < 0) {
      throw DataSourceException(
        FailureCode.insufficientStock,
        detail: '${product.name} (${variant.label})',
      );
    }
    return (
      product.copyWith(
        variants: <ProductVariant>[
          for (final ProductVariant candidate in product.variants)
            candidate.id == variantId
                ? candidate.copyWith(stockQuantity: remaining)
                : candidate,
        ],
      ),
      StockChangeResult(
        productName: product.name,
        variantLabel: variant.label,
        stockAfter: remaining,
      ),
    );
  }

  Product _fromDraft({
    required String id,
    required ProductDraft draft,
    required DateTime createdAt,
  }) {
    final ProductCategory category = _categories.firstWhere(
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
      variants: <ProductVariant>[
        for (final ProductVariant variant in draft.variants)
          variant.withCodes(
            sku: ProductCodeRules.normalizeOrNull(variant.sku),
            barcode: ProductCodeRules.normalizeOrNull(variant.barcode),
          ),
      ],
      sku: ProductCodeRules.normalizeOrNull(draft.sku),
      barcode: ProductCodeRules.normalizeOrNull(draft.barcode),
      showOnline: draft.showOnline,
    );
  }

  /// A SKU or barcode identifies one product or variant in the whole store,
  /// so a scan never has two answers.
  void _ensureCodesAreFree(ProductDraft draft, {String? exceptProductId}) {
    final Map<String, String> owners = <String, String>{
      for (final Product product in _products)
        if (product.id != exceptProductId)
          for (final String? code in <String?>[
            product.sku,
            product.barcode,
            for (final ProductVariant variant in product.variants) ...<String?>[
              variant.sku,
              variant.barcode,
            ],
          ])
            ?code: product.name,
    };
    final List<String?> codes = <String?>[
      draft.sku,
      draft.barcode,
      for (final ProductVariant variant in draft.variants) ...<String?>[
        variant.sku,
        variant.barcode,
      ],
    ];
    for (final String? code in codes) {
      final String? owner = owners[ProductCodeRules.normalizeOrNull(code)];
      if (owner != null) {
        throw DataSourceException(FailureCode.productCodeTaken, detail: owner);
      }
    }
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

/// A change of the stock of a product, or of one of its variants.
final class StockChange {
  const StockChange({
    required this.productId,
    required this.delta,
    this.variantId,
  });

  final String productId;
  final String? variantId;

  /// Units added (positive) or taken (negative).
  final int delta;
}

/// What a [StockChange] left, for the ledger.
final class StockChangeResult {
  const StockChangeResult({
    required this.productName,
    required this.stockAfter,
    this.variantLabel,
  });

  final String productName;
  final String? variantLabel;
  final int stockAfter;
}
