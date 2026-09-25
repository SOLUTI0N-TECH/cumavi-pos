import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';

enum SignInStatus { editing, submitting, success, failure }

/// Credential the sign-in form is using.
enum SignInMethod { email, phone }

final class SignInState extends Equatable {
  const SignInState({
    this.status = SignInStatus.editing,
    this.method = SignInMethod.email,
    this.email = '',
    this.password = '',
    this.phoneNumber = '',
    this.codeSent = false,
    this.code = '',
    this.demoCode,
    this.failure,
  });

  final SignInStatus status;
  final SignInMethod method;
  final String email;
  final String password;
  final String phoneNumber;

  /// Phone sign-in goes in two steps: number, then the SMS code.
  final bool codeSent;
  final String code;

  /// Code to show while there is no SMS backend (see `SentVerificationCode`).
  final String? demoCode;
  final Failure? failure;

  bool get isSubmitting => status == SignInStatus.submitting;

  bool get canSubmit {
    if (isSubmitting) return false;
    return switch (method) {
      SignInMethod.email => email.contains('@') && password.length >= 8,
      SignInMethod.phone =>
        codeSent
            ? code.replaceAll(RegExp(r'\D'), '').length == 6
            : phoneNumber.replaceAll(RegExp(r'\D'), '').length == 8,
    };
  }

  SignInState copyWith({
    SignInStatus? status,
    SignInMethod? method,
    String? email,
    String? password,
    String? phoneNumber,
    bool? codeSent,
    String? code,
    String? demoCode,
    Failure? failure,
  }) {
    return SignInState(
      status: status ?? this.status,
      method: method ?? this.method,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      codeSent: codeSent ?? this.codeSent,
      code: code ?? this.code,
      demoCode: demoCode ?? this.demoCode,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    method,
    email,
    password,
    phoneNumber,
    codeSent,
    code,
    demoCode,
    failure,
  ];
}
