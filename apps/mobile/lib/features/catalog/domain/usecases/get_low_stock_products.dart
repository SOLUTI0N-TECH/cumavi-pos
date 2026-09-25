import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

/// Products that need restocking, shown on the dashboard alert.
final class GetLowStockProducts implements UseCase<List<Product>, NoParams> {
  const GetLowStockProducts(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<Product>>> call(NoParams input) =>
      _repository.getLowStockProducts();
}
