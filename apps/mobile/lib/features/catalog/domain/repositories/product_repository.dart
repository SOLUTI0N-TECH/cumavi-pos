import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../entities/product_code_match.dart';
import '../entities/product_draft.dart';

/// Read/write access to the catalog. Implemented in memory while there is no
/// backend.
abstract interface class ProductRepository {
  /// Products filtered by free text and/or category, newest first.
  ///
  /// [categoryId] `null` means "all categories".
  Future<Result<List<Product>>> getProducts({
    String query = '',
    String? categoryId,
  });

  Future<Result<Product>> getProductById(String id);

  /// The product or variant whose SKU or barcode is [code] (already
  /// normalized); fails with `productCodeNotFound`.
  Future<Result<ProductCodeMatch>> findByCode(String code);

  /// Products at or below the low-stock threshold, most urgent first.
  Future<Result<List<Product>>> getLowStockProducts();

  /// Categories in the seller's order; archived ones only when asked.
  Future<Result<List<ProductCategory>>> getCategories({
    bool includeArchived = false,
  });

  /// Fails with `categoryNameTaken` when another category (archived ones
  /// included) has the same name, ignoring case and accents.
  Future<Result<ProductCategory>> createCategory(String name);

  /// Products of the category show the new name everywhere.
  Future<Result<ProductCategory>> renameCategory(String id, String name);

  /// [orderedIds] lists the category ids in the new order.
  Future<Result<void>> reorderCategories(List<String> orderedIds);

  Future<Result<ProductCategory>> setCategoryArchived(
    String id, {
    required bool archived,
  });

  Future<Result<Product>> createProduct(ProductDraft draft);

  /// Replaces the editable data of product [id]; its id and creation date
  /// stay the same.
  Future<Result<Product>> updateProduct(String id, ProductDraft draft);
}
