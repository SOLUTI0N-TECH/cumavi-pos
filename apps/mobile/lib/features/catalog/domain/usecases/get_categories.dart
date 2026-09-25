import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_category.dart';
import '../repositories/product_repository.dart';

/// Categories available to filter the catalog and to classify new products.
final class GetCategories implements UseCase<List<ProductCategory>, NoParams> {
  const GetCategories(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<List<ProductCategory>>> call(NoParams input) =>
      _repository.getCategories();
}
