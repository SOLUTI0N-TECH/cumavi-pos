import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_code_match.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/stock_level.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/product_code_rules.dart';
import '../datasources/product_data_source.dart';

/// Applies catalog query rules on top of the raw [ProductDataSource] and
/// turns exceptions into failures.
final class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl(this._dataSource);

  final ProductDataSource _dataSource;

  @override
  Future<Result<List<Product>>> getProducts({
    String query = '',
    String? categoryId,
  }) async {
    try {
      final List<Product> products = await _dataSource.fetchProducts();
      final String normalizedQuery = TextNormalizer.normalize(query);
      final String codeQuery = ProductCodeRules.normalize(query);

      final List<Product> filtered = products.where((Product product) {
        final bool matchesCategory =
            categoryId == null || product.category.id == categoryId;
        final bool matchesQuery =
            normalizedQuery.isEmpty ||
            TextNormalizer.normalize(product.name).contains(normalizedQuery) ||
            TextNormalizer.normalize(product.category.name)
                .contains(normalizedQuery) ||
            // "roja", "M"... finds the products that come in that variant.
            product.variants.any(
              (ProductVariant variant) =>
                  TextNormalizer.normalize(variant.label)
                      .contains(normalizedQuery) ||
                  _codeContains(variant.sku, codeQuery) ||
                  _codeContains(variant.barcode, codeQuery),
            ) ||
            _codeContains(product.sku, codeQuery) ||
            _codeContains(product.barcode, codeQuery);
        return matchesCategory && matchesQuery;
      }).toList();

      return Success<List<Product>>(filtered);
    } on DataSourceException catch (exception) {
      return Failed<List<Product>>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<Product>> getProductById(String id) async {
    try {
      final List<Product> products = await _dataSource.fetchProducts();
      final Product? product = products
          .where((Product candidate) => candidate.id == id)
          .firstOrNull;
      if (product == null) {
        return const Failed<Product>(
          NotFoundFailure(FailureCode.productNotFound),
        );
      }
      return Success<Product>(product);
    } on DataSourceException catch (exception) {
      return Failed<Product>(UnexpectedFailure(exception.code));
    }
  }

  /// A few typed digits or letters of a SKU or barcode find the product.
  static bool _codeContains(String? code, String query) =>
      query.length >= 3 && code != null && code.contains(query);

  @override
  Future<Result<ProductCodeMatch>> findByCode(String code) async {
    try {
      final List<Product> products = await _dataSource.fetchProducts();
      for (final Product product in products) {
        // A variant's own code is the most precise answer.
        for (final ProductVariant variant in product.variants) {
          if (variant.sku == code || variant.barcode == code) {
            return Success<ProductCodeMatch>(
              ProductCodeMatch(product: product, variant: variant),
            );
          }
        }
        if (product.sku == code || product.barcode == code) {
          return Success<ProductCodeMatch>(ProductCodeMatch(product: product));
        }
      }
      return Failed<ProductCodeMatch>(
        NotFoundFailure(FailureCode.productCodeNotFound, detail: code),
      );
    } on DataSourceException catch (exception) {
      return Failed<ProductCodeMatch>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<List<Product>>> getLowStockProducts() async {
    try {
      final List<Product> products = await _dataSource.fetchProducts();
      final List<Product> lowStock =
          products
              .where(
                (Product product) => product.stockLevel != StockLevel.healthy,
              )
              .toList()
            ..sort(
              (Product a, Product b) =>
                  a.stockQuantity.compareTo(b.stockQuantity),
            );
      return Success<List<Product>>(lowStock);
    } on DataSourceException catch (exception) {
      return Failed<List<Product>>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<List<ProductCategory>>> getCategories({
    bool includeArchived = false,
  }) async {
    try {
      return Success<List<ProductCategory>>(
        await _dataSource.fetchCategories(includeArchived: includeArchived),
      );
    } on DataSourceException catch (exception) {
      return Failed<List<ProductCategory>>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<ProductCategory>> createCategory(String name) =>
      _categoryCall(() => _dataSource.insertCategory(name));

  @override
  Future<Result<ProductCategory>> renameCategory(String id, String name) =>
      _categoryCall(() => _dataSource.updateCategory(id, name: name));

  @override
  Future<Result<ProductCategory>> setCategoryArchived(
    String id, {
    required bool archived,
  }) => _categoryCall(() => _dataSource.updateCategory(id, archived: archived));

  @override
  Future<Result<void>> reorderCategories(List<String> orderedIds) async {
    try {
      await _dataSource.reorderCategories(orderedIds);
      return const Success<void>(null);
    } on DataSourceException catch (exception) {
      return Failed<void>(NotFoundFailure(exception.code));
    }
  }

  Future<Result<ProductCategory>> _categoryCall(
    Future<ProductCategory> Function() call,
  ) async {
    try {
      return Success<ProductCategory>(await call());
    } on DataSourceException catch (exception) {
      return Failed<ProductCategory>(switch (exception.code) {
        FailureCode.categoryNotFound => const NotFoundFailure(
          FailureCode.categoryNotFound,
        ),
        _ => ConflictFailure(exception.code, detail: exception.detail),
      });
    }
  }

  @override
  Future<Result<Product>> createProduct(ProductDraft draft) async {
    try {
      return Success<Product>(await _dataSource.insertProduct(draft));
    } on DataSourceException catch (exception) {
      return Failed<Product>(
        ValidationFailure(exception.code, detail: exception.detail),
      );
    }
  }

  @override
  Future<Result<Product>> updateProduct(String id, ProductDraft draft) async {
    try {
      return Success<Product>(await _dataSource.updateProduct(id, draft));
    } on DataSourceException catch (exception) {
      return Failed<Product>(
        exception.code == FailureCode.productNotFound
            ? NotFoundFailure(exception.code, detail: exception.detail)
            : ValidationFailure(exception.code, detail: exception.detail),
      );
    }
  }
}
