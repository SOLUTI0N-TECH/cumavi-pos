import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/cash_session.dart';

enum CashRegisterStatus { initial, loading, ready, submitting, failure }

final class CashRegisterState extends Equatable {
  const CashRegisterState({
    this.status = CashRegisterStatus.initial,
    this.session,
    this.failure,
  });

  final CashRegisterStatus status;

  /// Open session, `null` when the drawer is closed.
  final CashSession? session;
  final Failure? failure;

  bool get isOpen => session?.isOpen ?? false;

  bool get isBusy =>
      status == CashRegisterStatus.loading ||
      status == CashRegisterStatus.submitting ||
      status == CashRegisterStatus.initial;

  CashRegisterState copyWith({
    CashRegisterStatus? status,
    CashSession? session,
    bool clearSession = false,
    Failure? failure,
  }) {
    return CashRegisterState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, session, failure];
}
