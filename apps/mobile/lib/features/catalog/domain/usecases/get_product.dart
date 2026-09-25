import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// One product with all its data, for the detail and edit screens.
final class GetProduct implements UseCase<Product, String> {
  const GetProduct(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(String productId) =>
      _repository.getProductById(productId);
}
