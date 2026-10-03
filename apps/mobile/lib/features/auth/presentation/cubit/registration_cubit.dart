import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../account/domain/usecases/pick_business_logo.dart';
import '../../../catalog/domain/services/photo_capturer.dart';
import '../../domain/entities/business_profile.dart';
import '../../domain/entities/sales_setup.dart';
import '../../domain/entities/sent_verification_code.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/request_phone_code.dart';
import '../../domain/usecases/save_business_profile.dart';
import '../../domain/usecases/save_sales_setup.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/verify_phone_code.dart';
import 'registration_state.dart';

/// Self-onboarding across the four registration steps. One cubit spans the
/// whole flow so a back navigation never loses what was typed.
class RegistrationCubit extends Cubit<RegistrationState> {
  RegistrationCubit({
    required RequestPhoneCode requestPhoneCode,
    required VerifyPhoneCode verifyPhoneCode,
    required SignInWithGoogle signInWithGoogle,
    required SaveBusinessProfile saveBusinessProfile,
    required SaveSalesSetup saveSalesSetup,
    required PickBusinessLogo pickBusinessLogo,
  }) : _requestPhoneCode = requestPhoneCode,
       _verifyPhoneCode = verifyPhoneCode,
       _signInWithGoogle = signInWithGoogle,
       _saveBusinessProfile = saveBusinessProfile,
       _saveSalesSetup = saveSalesSetup,
       _pickBusinessLogo = pickBusinessLogo,
       super(const RegistrationState()) {
    _selectSuggestedCategories(state.businessType);
  }

  final RequestPhoneCode _requestPhoneCode;
  final VerifyPhoneCode _verifyPhoneCode;
  final SignInWithGoogle _signInWithGoogle;
  final SaveBusinessProfile _saveBusinessProfile;
  final SaveSalesSetup _saveSalesSetup;
  final PickBusinessLogo _pickBusinessLogo;

  // ---------------------------------------------------------------- step 1
  void methodChanged(RegistrationMethod method) =>
      emit(state.copyWith(method: method, status: RegistrationStatus.editing));

  void fullNameChanged(String value) => emit(state.copyWith(fullName: value));

  void phoneNumberChanged(String value) =>
      emit(state.copyWith(phoneNumber: value));

  void emailChanged(String value) => emit(state.copyWith(email: value));

  void passwordChanged(String value) => emit(state.copyWith(password: value));

  void termsToggled(bool accepted) =>
      emit(state.copyWith(acceptedTerms: accepted));

  Future<void> submitAccount() async {
    if (!state.canSubmitAccount) return;
    emit(state.copyWith(status: RegistrationStatus.submitting));

    if (state.method == RegistrationMethod.email) {
      // Email accounts are verified by a link, so the flow jumps to the
      // business step.
      emit(state.copyWith(status: RegistrationStatus.accountReady));
      return;
    }

    final Result<SentVerificationCode> result = await _requestPhoneCode(
      PhoneRegistrationDraft(
        fullName: state.fullName,
        phoneNumber: state.phoneNumber,
      ),
    );

    switch (result) {
      case Success<SentVerificationCode>(:final SentVerificationCode value):
        emit(
          state.copyWith(
            status: RegistrationStatus.codeSent,
            demoCode: value.demoCode,
          ),
        );
      case Failed<SentVerificationCode>(:final failure):
        _fail(failure);
    }
  }

  Future<void> signUpWithGoogle() async {
    emit(state.copyWith(status: RegistrationStatus.submitting));
    switch (await _signInWithGoogle(const NoParams())) {
      case Success<UserAccount>(:final UserAccount value):
        emit(
          state.copyWith(
            status: RegistrationStatus.accountReady,
            fullName: value.fullName,
            email: value.email ?? '',
          ),
        );
      case Failed<UserAccount>(:final failure):
        _fail(failure);
    }
  }

  // ---------------------------------------------------------------- step 2
  void codeChanged(String code) =>
      emit(state.copyWith(code: code, status: RegistrationStatus.editing));

  Future<void> verifyCode() async {
    if (!state.canVerifyCode) return;
    emit(state.copyWith(status: RegistrationStatus.submitting));

    final Result<UserAccount> result = await _verifyPhoneCode(
      PhoneVerification(
        draft: PhoneRegistrationDraft(
          fullName: state.fullName,
          phoneNumber: state.phoneNumber,
        ),
        code: state.code,
      ),
    );

    switch (result) {
      case Success<UserAccount>():
        emit(state.copyWith(status: RegistrationStatus.accountReady));
      case Failed<UserAccount>(:final failure):
        _fail(failure);
    }
  }

  Future<void> resendCode() => submitAccount();

  // ---------------------------------------------------------------- step 3
  void businessNameChanged(String value) =>
      emit(state.copyWith(businessName: value));

  void businessTypeSelected(BusinessType type) {
    emit(state.copyWith(businessType: type));
    _selectSuggestedCategories(type);
  }

  void departmentSelected(BoliviaDepartment department) =>
      emit(state.copyWith(department: department));

  /// Takes or picks the logo with the camera or the gallery. Returns the
  /// failure (e.g. camera permission denied) so the screen can explain it;
  /// cancelling the picker keeps the current logo.
  Future<Failure?> pickLogo(PhotoSource source) async {
    switch (await _pickBusinessLogo(source)) {
      case Success<String?>(:final String? value):
        if (value != null) emit(state.copyWith(logoPath: value));
        return null;
      case Failed<String?>(:final failure):
        return failure;
    }
  }

  Future<void> submitBusiness() async {
    if (!state.canSubmitBusiness) return;
    emit(state.copyWith(status: RegistrationStatus.submitting));

    final Result<BusinessProfile> result = await _saveBusinessProfile(
      BusinessProfileDraft(
        name: state.businessName,
        type: state.businessType,
        department: state.department,
        logoPath: state.logoPath,
      ),
    );

    switch (result) {
      case Success<BusinessProfile>():
        emit(state.copyWith(status: RegistrationStatus.businessSaved));
      case Failed<BusinessProfile>(:final failure):
        _fail(failure);
    }
  }

  // ---------------------------------------------------------------- step 4
  void categoryToggled(String category) {
    final Set<String> updated = Set<String>.of(state.selectedCategories);
    if (!updated.remove(category)) updated.add(category);
    emit(state.copyWith(selectedCategories: updated));
  }

  void paymentMethodToggled(PaymentMethod method) {
    final Set<PaymentMethod> updated = Set<PaymentMethod>.of(
      state.acceptedPaymentMethods,
    );
    if (!updated.remove(method)) updated.add(method);
    emit(state.copyWith(acceptedPaymentMethods: updated));
  }

  void taxIdChanged(String value) => emit(state.copyWith(taxId: value));

  Future<void> submitSetup() async {
    if (!state.canSubmitSetup) return;
    emit(state.copyWith(status: RegistrationStatus.submitting));

    final Result<BusinessProfile> result = await _saveSalesSetup(
      SalesSetup(
        categoryNames: state.selectedCategories.toList(),
        acceptedPaymentMethods: state.acceptedPaymentMethods,
        taxId: state.taxId.trim().isEmpty ? null : state.taxId.trim(),
      ),
    );

    switch (result) {
      case Success<BusinessProfile>():
        emit(state.copyWith(status: RegistrationStatus.completed));
      case Failed<BusinessProfile>(:final failure):
        _fail(failure);
    }
  }

  void _selectSuggestedCategories(BusinessType type) {
    emit(
      state.copyWith(
        selectedCategories: type.suggestedCategories.take(3).toSet(),
      ),
    );
  }

  void _fail(Failure failure) => emit(
    state.copyWith(status: RegistrationStatus.failure, failure: failure),
  );
}
