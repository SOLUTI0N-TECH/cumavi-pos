import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/entities/product_variant.dart';
import '../../domain/entities/stock_level.dart';
import '../../domain/repositories/product_repository.dart';
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
      final String normalizedQuery = query.trim().toLowerCase();

      final List<Product> filtered = products.where((Product product) {
        final bool matchesCategory =
            categoryId == null || product.category.id == categoryId;
        final bool matchesQuery =
            normalizedQuery.isEmpty ||
            product.name.toLowerCase().contains(normalizedQuery) ||
            product.category.name.toLowerCase().contains(normalizedQuery) ||
            // "roja", "M"... finds the products that come in that variant.
            product.variants.any(
              (ProductVariant variant) =>
                  variant.label.toLowerCase().contains(normalizedQuery),
            );
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
  Future<Result<List<ProductCategory>>> getCategories() async {
    try {
      return Success<List<ProductCategory>>(
        await _dataSource.fetchCategories(),
      );
    } on DataSourceException catch (exception) {
      return Failed<List<ProductCategory>>(UnexpectedFailure(exception.code));
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

  @override
  Future<Result<void>> reduceStock(List<StockMovement> movements) async {
    try {
      await _dataSource.applyStockMovements(movements);
      return const Success<void>(null);
    } on DataSourceException catch (exception) {
      return Failed<void>(
        ConflictFailure(exception.code, detail: exception.detail),
      );
    }
  }
}
