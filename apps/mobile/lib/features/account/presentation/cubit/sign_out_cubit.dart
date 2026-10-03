import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/usecases/sign_out.dart';

enum SignOutStatus { idle, signingOut, signedOut, failure }

final class SignOutState extends Equatable {
  const SignOutState({this.status = SignOutStatus.idle, this.failure});

  final SignOutStatus status;
  final Failure? failure;

  bool get isBusy => status == SignOutStatus.signingOut;

  @override
  List<Object?> get props => <Object?>[status, failure];
}

/// "Cerrar sesión" in the "Más" hub.
class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit({required SignOut signOut})
    : _signOut = signOut,
      super(const SignOutState());

  final SignOut _signOut;

  Future<void> signOut() async {
    if (state.isBusy) return;
    emit(const SignOutState(status: SignOutStatus.signingOut));
    switch (await _signOut(const NoParams())) {
      case Success<void>():
        emit(const SignOutState(status: SignOutStatus.signedOut));
      case Failed<void>(:final failure):
        emit(SignOutState(status: SignOutStatus.failure, failure: failure));
    }
  }
}
