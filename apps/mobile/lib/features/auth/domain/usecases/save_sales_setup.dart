import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../../../catalog/domain/entities/product_category.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../entities/business_profile.dart';
import '../entities/sales_setup.dart';
import '../repositories/auth_repository.dart';

/// Stores the categories, payment methods and NIT of step 4, and creates
/// in the catalog the categories the seller picked that don't exist yet.
final class SaveSalesSetup implements UseCase<BusinessProfile, SalesSetup> {
  const SaveSalesSetup({
    required AuthRepository authRepository,
    required ProductRepository productRepository,
  }) : _authRepository = authRepository,
       _productRepository = productRepository;

  final AuthRepository _authRepository;
  final ProductRepository _productRepository;

  @override
  Future<Result<BusinessProfile>> call(SalesSetup input) async {
    if (input.categoryNames.isEmpty) {
      return const Failed<BusinessProfile>(
        ValidationFailure(FailureCode.salesCategoryRequired),
      );
    }
    if (input.acceptedPaymentMethods.isEmpty) {
      return const Failed<BusinessProfile>(
        ValidationFailure(FailureCode.paymentMethodRequired),
      );
    }

    final Result<BusinessProfile> saved = await _authRepository.saveSalesSetup(
      input,
    );
    if (saved case Failed<BusinessProfile>()) return saved;

    final Failure? categoriesFailure = await _createMissingCategories(
      input.categoryNames,
    );
    return categoriesFailure == null
        ? saved
        : Failed<BusinessProfile>(categoriesFailure);
  }

  Future<Failure?> _createMissingCategories(List<String> names) async {
    final Result<List<ProductCategory>> existing = await _productRepository
        .getCategories(includeArchived: true);
    if (existing case Failed<List<ProductCategory>>(:final Failure failure)) {
      return failure;
    }
    final Set<String> known = <String>{
      for (final ProductCategory category
          in (existing as Success<List<ProductCategory>>).value)
        TextNormalizer.normalize(category.name),
    };

    for (final String name in names) {
      if (!known.add(TextNormalizer.normalize(name))) continue;
      if (await _productRepository.createCategory(name.trim())
          case Failed<ProductCategory>(:final Failure failure)) {
        return failure;
      }
    }
    return null;
  }
}
