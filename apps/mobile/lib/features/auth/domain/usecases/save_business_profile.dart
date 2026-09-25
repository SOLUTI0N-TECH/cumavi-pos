import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/business_profile.dart';
import '../repositories/auth_repository.dart';

/// Stores the business data collected on step 3 of the registration.
final class SaveBusinessProfile
    implements UseCase<BusinessProfile, BusinessProfileDraft> {
  const SaveBusinessProfile(this._repository);

  final AuthRepository _repository;

  @override
  Future<Result<BusinessProfile>> call(BusinessProfileDraft input) async {
    if (input.name.trim().length < 3) {
      return const Failed<BusinessProfile>(
        ValidationFailure(FailureCode.businessNameTooShort),
      );
    }
    return _repository.saveBusinessProfile(input);
  }
}
