import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_draft.dart';
import '../repositories/product_repository.dart';
import 'product_draft_rules.dart';

/// Validates the product form and stores the new product.
final class CreateProduct implements UseCase<Product, ProductDraft> {
  const CreateProduct(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(ProductDraft input) async {
    final Failure? validation = ProductDraftRules.validate(input);
    if (validation != null) return Failed<Product>(validation);
    return _repository.createProduct(input);
  }
}
