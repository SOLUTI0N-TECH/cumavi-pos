import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_draft.dart';
import '../../domain/repositories/product_repository.dart';

/// Storage contract for the catalog. Swapping the mock for an HTTP client
/// only requires another implementation of this interface.
abstract interface class ProductDataSource {
  Future<List<Product>> fetchProducts();

  Future<List<ProductCategory>> fetchCategories();

  Future<Product> insertProduct(ProductDraft draft);

  Future<Product> updateProduct(String id, ProductDraft draft);

  Future<void> applyStockMovements(List<StockMovement> movements);
}
