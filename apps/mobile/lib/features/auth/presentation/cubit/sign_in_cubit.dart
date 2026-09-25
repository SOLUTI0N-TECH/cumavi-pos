import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/sent_verification_code.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/request_sign_in_code.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_in_with_phone.dart';
import 'sign_in_state.dart';

/// Sign-in form: Google, email + password, or phone.
class SignInCubit extends Cubit<SignInState> {
  SignInCubit({
    required SignInWithEmail signInWithEmail,
    required SignInWithGoogle signInWithGoogle,
    required RequestSignInCode requestSignInCode,
    required SignInWithPhone signInWithPhone,
  }) : _signInWithEmail = signInWithEmail,
       _signInWithGoogle = signInWithGoogle,
       _requestSignInCode = requestSignInCode,
       _signInWithPhone = signInWithPhone,
       super(const SignInState());

  final SignInWithEmail _signInWithEmail;
  final SignInWithGoogle _signInWithGoogle;
  final RequestSignInCode _requestSignInCode;
  final SignInWithPhone _signInWithPhone;

  void methodChanged(SignInMethod method) =>
      emit(state.copyWith(method: method, status: SignInStatus.editing));

  void emailChanged(String email) => emit(state.copyWith(email: email));

  void passwordChanged(String password) =>
      emit(state.copyWith(password: password));

  void phoneNumberChanged(String phoneNumber) =>
      emit(state.copyWith(phoneNumber: phoneNumber));

  Future<void> signInWithEmail() async {
    emit(state.copyWith(status: SignInStatus.submitting));
    _handle(
      await _signInWithEmail(
        EmailCredentials(email: state.email, password: state.password),
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: SignInStatus.submitting));
    _handle(await _signInWithGoogle(const NoParams()));
  }

  /// Phone step 1: sends the SMS code (also used to resend it).
  Future<void> requestPhoneCode() async {
    emit(state.copyWith(status: SignInStatus.submitting));
    switch (await _requestSignInCode(state.phoneNumber)) {
      case Success<SentVerificationCode>(:final SentVerificationCode value):
        emit(
          state.copyWith(
            status: SignInStatus.editing,
            codeSent: true,
            code: '',
            demoCode: value.demoCode,
          ),
        );
      case Failed<SentVerificationCode>(:final failure):
        emit(state.copyWith(status: SignInStatus.failure, failure: failure));
    }
  }

  void codeChanged(String code) =>
      emit(state.copyWith(code: code, status: SignInStatus.editing));

  /// Back to phone step 1 to fix the number.
  void changePhoneNumber() => emit(
    state.copyWith(codeSent: false, code: '', status: SignInStatus.editing),
  );

  /// Phone step 2: signs in with the SMS code.
  Future<void> signInWithPhone() async {
    emit(state.copyWith(status: SignInStatus.submitting));
    _handle(
      await _signInWithPhone(
        PhoneCredentials(phoneNumber: state.phoneNumber, code: state.code),
      ),
    );
  }

  void _handle(Result<UserAccount> result) {
    switch (result) {
      case Success<UserAccount>():
        emit(state.copyWith(status: SignInStatus.success));
      case Failed<UserAccount>(:final failure):
        emit(state.copyWith(status: SignInStatus.failure, failure: failure));
    }
  }
}
