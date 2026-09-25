import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';
import '../entities/product_draft.dart';

/// How many units of a product (or of one of its variants) leave the stock.
final class StockMovement {
  const StockMovement({
    required this.productId,
    required this.quantity,
    this.variantId,
  });

  final String productId;

  /// Set when the product has variants: the stock is kept per variant.
  final String? variantId;
  final int quantity;
}

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

  /// Products at or below the low-stock threshold, most urgent first.
  Future<Result<List<Product>>> getLowStockProducts();

  Future<Result<List<ProductCategory>>> getCategories();

  Future<Result<Product>> createProduct(ProductDraft draft);

  /// Replaces the editable data of product [id]; its id and creation date
  /// stay the same.
  Future<Result<Product>> updateProduct(String id, ProductDraft draft);

  /// Applies the stock reduction of a sale.
  Future<Result<void>> reduceStock(List<StockMovement> movements);
}
