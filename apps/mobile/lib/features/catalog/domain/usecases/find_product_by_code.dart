import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/product_code_match.dart';
import '../repositories/product_repository.dart';
import 'product_code_rules.dart';

/// Finds the product (or variant) whose SKU or barcode is [code].
final class FindProductByCode implements UseCase<ProductCodeMatch, String> {
  const FindProductByCode(this._repository);

  final ProductRepository _repository;

  @override
  Future<Result<ProductCodeMatch>> call(String code) async {
    final String? normalized = ProductCodeRules.normalizeOrNull(code);
    if (normalized == null) {
      return const Failed<ProductCodeMatch>(
        ValidationFailure(FailureCode.invalidBarcode),
      );
    }
    return _repository.findByCode(normalized);
  }
}
