import '../../../../core/utils/result.dart';
import '../entities/business_profile.dart';
import '../entities/sales_setup.dart';
import '../entities/sent_verification_code.dart';
import '../entities/user_account.dart';

/// Credentials of the email sign-in form.
final class EmailCredentials {
  const EmailCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

/// Credentials of the phone sign-in form.
final class PhoneCredentials {
  const PhoneCredentials({required this.phoneNumber, required this.code});

  /// National number without the country code.
  final String phoneNumber;
  final String code;
}

/// Data of the "create account" step.
final class PhoneRegistrationDraft {
  const PhoneRegistrationDraft({
    required this.fullName,
    required this.phoneNumber,
  });

  final String fullName;

  /// National number without the country code.
  final String phoneNumber;
}

/// Data of the "about your business" step.
final class BusinessProfileDraft {
  const BusinessProfileDraft({
    required this.name,
    required this.type,
    required this.department,
    this.logoPath,
    this.taxId,
  });

  final String name;
  final BusinessType type;
  final BoliviaDepartment department;
  final String? logoPath;

  /// NIT. `null` keeps the current one (registration doesn't ask for it
  /// here), an empty text removes it.
  final String? taxId;
}

/// Authentication and onboarding. Mocked until the backend exists.
abstract interface class AuthRepository {
  Future<Result<UserAccount>> signInWithEmail(EmailCredentials credentials);

  Future<Result<UserAccount>> signInWithGoogle();

  /// Sends the SMS code of a new account.
  Future<Result<SentVerificationCode>> requestPhoneCode(
    PhoneRegistrationDraft draft,
  );

  /// Sends the SMS code to sign in with an existing phone account.
  Future<Result<SentVerificationCode>> requestSignInCode(String phoneNumber);

  Future<Result<UserAccount>> signInWithPhone(PhoneCredentials credentials);

  Future<Result<UserAccount>> verifyPhoneCode({
    required PhoneRegistrationDraft draft,
    required String code,
  });

  Future<Result<BusinessProfile>> saveBusinessProfile(
    BusinessProfileDraft draft,
  );

  Future<Result<BusinessProfile>> saveSalesSetup(SalesSetup setup);

  /// Ends the session of the current user on this device.
  Future<Result<void>> signOut();
}
