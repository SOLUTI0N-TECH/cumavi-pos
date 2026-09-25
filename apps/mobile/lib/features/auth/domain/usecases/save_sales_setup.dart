import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/business_profile.dart';
import '../entities/sales_setup.dart';
import '../repositories/auth_repository.dart';

/// Stores the categories, payment methods and NIT of step 4.
final class SaveSalesSetup implements UseCase<BusinessProfile, SalesSetup> {
  const SaveSalesSetup(this._repository);

  final AuthRepository _repository;

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
    return _repository.saveSalesSetup(input);
  }
}
