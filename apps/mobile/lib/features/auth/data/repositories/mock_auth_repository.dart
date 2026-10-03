import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/entities/sales_setup.dart';
import '../../domain/entities/sent_verification_code.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/session_repository.dart';

/// Authentication without a backend.
///
/// Every method waits like a network call, stores the result in the
/// [SessionRepository] and accepts any well-formed input. No SMS is sent:
/// the verification code is always [demoVerificationCode] and travels back
/// in [SentVerificationCode.demoCode] so the screens can show it.
final class MockAuthRepository implements AuthRepository {
  MockAuthRepository({
    required SessionRepository sessionRepository,
    Duration? latency,
  }) : _sessionRepository = sessionRepository,
       _latency = latency ?? const Duration(milliseconds: 700);

  static const String demoVerificationCode = '123456';

  final SessionRepository _sessionRepository;
  final Duration _latency;

  @override
  Future<Result<UserAccount>> signInWithEmail(
    EmailCredentials credentials,
  ) async {
    await _simulateLatency();
    final String localPart = credentials.email.split('@').first;
    final UserAccount user = UserAccount(
      id: 'user-${localPart.hashCode.abs()}',
      fullName: _nameFromEmail(localPart),
      provider: AuthProvider.email,
      email: credentials.email.trim(),
    );
    _sessionRepository.saveUser(user);
    return Success<UserAccount>(user);
  }

  @override
  Future<Result<UserAccount>> signInWithGoogle() async {
    await _simulateLatency();
    const UserAccount user = UserAccount(
      id: 'user-google-demo',
      fullName: 'Carla Mamani',
      provider: AuthProvider.google,
      email: 'carla.mamani@gmail.com',
    );
    _sessionRepository.saveUser(user);
    return const Success<UserAccount>(user);
  }

  @override
  Future<Result<SentVerificationCode>> requestPhoneCode(
    PhoneRegistrationDraft draft,
  ) => _sendDemoCode(draft.phoneNumber);

  @override
  Future<Result<SentVerificationCode>> requestSignInCode(String phoneNumber) =>
      _sendDemoCode(phoneNumber);

  @override
  Future<Result<UserAccount>> signInWithPhone(
    PhoneCredentials credentials,
  ) async {
    await _simulateLatency();
    if (credentials.code != demoVerificationCode) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.verificationCodeInvalid),
      );
    }
    // Any number signs in to the demo seller's account.
    final UserAccount user = UserAccount(
      id: 'user-${credentials.phoneNumber}',
      fullName: 'Carla Mamani',
      provider: AuthProvider.phone,
      phoneNumber: credentials.phoneNumber,
    );
    _sessionRepository.saveUser(user);
    return Success<UserAccount>(user);
  }

  @override
  Future<Result<UserAccount>> verifyPhoneCode({
    required PhoneRegistrationDraft draft,
    required String code,
  }) async {
    await _simulateLatency();
    if (code != demoVerificationCode) {
      return const Failed<UserAccount>(
        ValidationFailure(FailureCode.verificationCodeInvalid),
      );
    }
    final UserAccount user = UserAccount(
      id: 'user-${draft.phoneNumber}',
      fullName: draft.fullName,
      provider: AuthProvider.phone,
      phoneNumber: draft.phoneNumber,
    );
    _sessionRepository.saveUser(user);
    return Success<UserAccount>(user);
  }

  @override
  Future<Result<BusinessProfile>> saveBusinessProfile(
    BusinessProfileDraft draft,
  ) async {
    await _simulateLatency();
    final BusinessProfile business = BusinessProfile(
      id:
          _sessionRepository.currentBusiness?.id ??
          'business-${DateTime.now().millisecondsSinceEpoch}',
      name: draft.name.trim(),
      type: draft.type,
      department: draft.department,
      logoPath: draft.logoPath,
      taxId: switch (draft.taxId?.trim()) {
        null => _sessionRepository.currentBusiness?.taxId,
        '' => null,
        final String taxId => taxId,
      },
    );
    _sessionRepository.saveBusiness(business);
    return Success<BusinessProfile>(business);
  }

  @override
  Future<Result<BusinessProfile>> saveSalesSetup(SalesSetup setup) async {
    await _simulateLatency();
    final BusinessProfile? business = _sessionRepository.currentBusiness;
    if (business == null) {
      return const Failed<BusinessProfile>(
        ConflictFailure(FailureCode.businessProfileRequired),
      );
    }
    final BusinessProfile updated = business.copyWith(taxId: setup.taxId);
    _sessionRepository.saveBusiness(updated);
    return Success<BusinessProfile>(updated);
  }

  Future<Result<SentVerificationCode>> _sendDemoCode(String phoneNumber) async {
    await _simulateLatency();
    return Success<SentVerificationCode>(
      SentVerificationCode(
        phoneNumber: phoneNumber,
        demoCode: demoVerificationCode,
      ),
    );
  }

  @override
  Future<Result<void>> signOut() async {
    await _simulateLatency();
    _sessionRepository.clearUser();
    return const Success<void>(null);
  }

  Future<void> _simulateLatency() => Future<void>.delayed(_latency);

  String _nameFromEmail(String localPart) {
    final Iterable<String> words = localPart
        .split(RegExp(r'[._-]'))
        .where((String word) => word.isNotEmpty)
        .map(
          (String word) =>
              word[0].toUpperCase() + word.substring(1).toLowerCase(),
        );
    return words.isEmpty ? 'Vendedor' : words.join(' ');
  }
}
