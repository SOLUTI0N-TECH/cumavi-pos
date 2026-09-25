import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/auth/data/repositories/mock_auth_repository.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/entities/sent_verification_code.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/entities/user_account.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/usecases/request_phone_code.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/usecases/request_sign_in_code.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/usecases/sign_in_with_phone.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _failsWith(FailureCode code) => isA<Failed<Object?>>().having(
  (Failed<Object?> failed) => failed.failure.code,
  'code',
  code,
);

void main() {
  late InMemorySessionStore session;
  late MockAuthRepository repository;

  setUp(() {
    session = InMemorySessionStore();
    repository = MockAuthRepository(
      sessionRepository: session,
      latency: Duration.zero,
    );
  });

  group('demo SMS code', () {
    test('is 123456 and travels back so the screens can show it', () async {
      final Result<SentVerificationCode> result = await RequestSignInCode(
        repository,
      )('765 43210');

      expect(
        result,
        isA<Success<SentVerificationCode>>().having(
          (Success<SentVerificationCode> success) => success.value,
          'value',
          const SentVerificationCode(
            phoneNumber: '76543210',
            demoCode: '123456',
          ),
        ),
      );
    });

    test('is also sent when registering', () async {
      final Result<SentVerificationCode> result =
          await RequestPhoneCode(repository)(
            const PhoneRegistrationDraft(
              fullName: 'Juan Quispe',
              phoneNumber: '71234567',
            ),
          );

      expect(
        (result as Success<SentVerificationCode>).value.demoCode,
        MockAuthRepository.demoVerificationCode,
      );
    });
  });

  group('SignInWithPhone', () {
    test('signs in with the demo code and saves the user', () async {
      final Result<UserAccount> result = await SignInWithPhone(repository)(
        const PhoneCredentials(phoneNumber: '6123 4567', code: '123 456'),
      );

      expect(result, isA<Success<UserAccount>>());
      expect(session.currentUser?.phoneNumber, '61234567');
      expect(session.currentUser?.provider, AuthProvider.phone);
    });

    test('rejects a wrong code', () async {
      final Result<UserAccount> result = await SignInWithPhone(repository)(
        const PhoneCredentials(phoneNumber: '76543210', code: '000000'),
      );

      expect(result, _failsWith(FailureCode.verificationCodeInvalid));
    });

    test('asks for all six digits', () async {
      final Result<UserAccount> result = await SignInWithPhone(repository)(
        const PhoneCredentials(phoneNumber: '76543210', code: '1234'),
      );

      expect(result, _failsWith(FailureCode.verificationCodeIncomplete));
    });

    test('rejects numbers that are not Bolivian mobiles', () async {
      final Result<SentVerificationCode> result = await RequestSignInCode(
        repository,
      )('3345678');

      expect(result, _failsWith(FailureCode.invalidMobileNumber));
    });
  });
}
