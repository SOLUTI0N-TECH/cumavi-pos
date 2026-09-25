import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product.dart';
import '../entities/product_draft.dart';
import '../repositories/product_repository.dart';
import 'product_draft_rules.dart';

/// Input of [UpdateProduct].
final class ProductUpdate {
  const ProductUpdate({required this.productId, required this.draft});

  final String productId;
  final ProductDraft draft;
}

/// Validates the edited form and stores the changes.
final class UpdateProduct implements UseCase<Product, ProductUpdate> {
  const UpdateProduct(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<Product>> call(ProductUpdate input) async {
    final Failure? validation = ProductDraftRules.validate(input.draft);
    if (validation != null) return Failed<Product>(validation);
    return _repository.updateProduct(input.productId, input.draft);
  }
}
