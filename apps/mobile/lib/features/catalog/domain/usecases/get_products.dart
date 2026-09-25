import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Filters for [GetProducts].
final class ProductQuery {
  const ProductQuery({this.query = '', this.categoryId});

  final String query;

  /// `null` means every category.
  final String? categoryId;
}

/// Lists catalog products for the inventory list and the sale search screen.
final class GetProducts implements UseCase<List<Product>, ProductQuery> {
  const GetProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call(ProductQuery input) {
    return _repository.getProducts(
      query: input.query,
      categoryId: input.categoryId,
    );
  }
}
