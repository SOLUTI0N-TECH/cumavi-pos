import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/business_profile.dart';

/// Credential chosen on step 1.
enum RegistrationMethod { phone, email }

/// Where the registration flow currently is. The screens listen to it to
/// move forward, so navigation stays a consequence of the state.
enum RegistrationStatus {
  editing,
  submitting,
  codeSent,
  accountReady,
  businessSaved,
  completed,
  failure,
}

final class RegistrationState extends Equatable {
  const RegistrationState({
    this.status = RegistrationStatus.editing,
    this.method = RegistrationMethod.phone,
    this.fullName = '',
    this.phoneNumber = '',
    this.email = '',
    this.password = '',
    this.acceptedTerms = true,
    this.code = '',
    this.demoCode,
    this.businessName = '',
    this.businessType = BusinessType.clothingAndFootwear,
    this.department = BoliviaDepartment.laPaz,
    this.logoPath,
    this.selectedCategories = const <String>{},
    this.acceptedPaymentMethods = const <PaymentMethod>{
      PaymentMethod.cash,
      PaymentMethod.qr,
    },
    this.taxId = '',
    this.failure,
  });

  final RegistrationStatus status;
  final RegistrationMethod method;

  // Step 1 — account.
  final String fullName;
  final String phoneNumber;
  final String email;
  final String password;
  final bool acceptedTerms;

  // Step 2 — verification.
  final String code;

  /// Code to show while there is no SMS backend (see `SentVerificationCode`).
  final String? demoCode;

  // Step 3 — business.
  final String businessName;
  final BusinessType businessType;
  final BoliviaDepartment department;
  final String? logoPath;

  // Step 4 — how they sell.
  final Set<String> selectedCategories;
  final Set<PaymentMethod> acceptedPaymentMethods;
  final String taxId;

  final Failure? failure;

  bool get isSubmitting => status == RegistrationStatus.submitting;

  bool get canSubmitAccount {
    if (isSubmitting || !acceptedTerms) return false;
    if (fullName.trim().split(RegExp(r'\s+')).length < 2) return false;
    return switch (method) {
      RegistrationMethod.phone =>
        phoneNumber.replaceAll(RegExp(r'\D'), '').length == 8,
      RegistrationMethod.email => email.contains('@') && password.length >= 8,
    };
  }

  bool get canVerifyCode =>
      !isSubmitting && code.replaceAll(RegExp(r'\D'), '').length == 6;

  bool get canSubmitBusiness =>
      !isSubmitting && businessName.trim().length >= 3;

  bool get canSubmitSetup =>
      !isSubmitting &&
      selectedCategories.isNotEmpty &&
      acceptedPaymentMethods.isNotEmpty;

  /// Categories proposed for the chosen business type.
  List<String> get suggestedCategories => businessType.suggestedCategories;

  RegistrationState copyWith({
    RegistrationStatus? status,
    RegistrationMethod? method,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    bool? acceptedTerms,
    String? code,
    String? demoCode,
    String? businessName,
    BusinessType? businessType,
    BoliviaDepartment? department,
    String? logoPath,
    Set<String>? selectedCategories,
    Set<PaymentMethod>? acceptedPaymentMethods,
    String? taxId,
    Failure? failure,
  }) {
    return RegistrationState(
      status: status ?? this.status,
      method: method ?? this.method,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      password: password ?? this.password,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      code: code ?? this.code,
      demoCode: demoCode ?? this.demoCode,
      businessName: businessName ?? this.businessName,
      businessType: businessType ?? this.businessType,
      department: department ?? this.department,
      logoPath: logoPath ?? this.logoPath,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      acceptedPaymentMethods:
          acceptedPaymentMethods ?? this.acceptedPaymentMethods,
      taxId: taxId ?? this.taxId,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    method,
    fullName,
    phoneNumber,
    email,
    password,
    acceptedTerms,
    code,
    demoCode,
    businessName,
    businessType,
    department,
    logoPath,
    selectedCategories,
    acceptedPaymentMethods,
    taxId,
    failure,
  ];
}
