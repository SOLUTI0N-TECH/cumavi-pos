import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_draft.dart';

/// Storage contract for the catalog. Swapping the mock for an HTTP client
/// only requires another implementation of this interface.
abstract interface class ProductDataSource {
  Future<List<Product>> fetchProducts();

  Future<List<ProductCategory>> fetchCategories({bool includeArchived = false});

  Future<ProductCategory> insertCategory(String name);

  Future<ProductCategory> updateCategory(
    String id, {
    String? name,
    bool? archived,
  });

  Future<void> reorderCategories(List<String> orderedIds);

  Future<Product> insertProduct(ProductDraft draft);

  Future<Product> updateProduct(String id, ProductDraft draft);
}
