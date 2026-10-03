import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../entities/business_profile.dart';
import '../repositories/auth_repository.dart';

/// Stores the business data: step 3 of the registration and the business
/// settings in "Más".
final class SaveBusinessProfile
    implements UseCase<BusinessProfile, BusinessProfileDraft> {
  const SaveBusinessProfile(this._repository);

  final AuthRepository _repository;

  /// Bolivian NIT: digits only.
  static final RegExp _taxIdPattern = RegExp(r'^\d{5,15}$');

  @override
  Future<Result<BusinessProfile>> call(BusinessProfileDraft input) async {
    if (input.name.trim().length < 3) {
      return const Failed<BusinessProfile>(
        ValidationFailure(FailureCode.businessNameTooShort),
      );
    }
    final String? taxId = input.taxId?.trim();
    if (taxId != null && taxId.isNotEmpty && !_taxIdPattern.hasMatch(taxId)) {
      return const Failed<BusinessProfile>(
        ValidationFailure(FailureCode.invalidTaxId),
      );
    }
    return _repository.saveBusinessProfile(input);
  }
}
