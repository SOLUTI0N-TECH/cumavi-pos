import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/usecases/get_current_cash_session.dart';
import '../../domain/usecases/open_cash_session.dart';
import 'cash_register_state.dart';

/// Owns the cash drawer state for the whole session: the Ventas tab, the
/// dashboard and the sale screen all read it.
class CashRegisterCubit extends Cubit<CashRegisterState> {
  CashRegisterCubit({
    required GetCurrentCashSession getCurrentCashSession,
    required OpenCashSession openCashSession,
  }) : _getCurrentCashSession = getCurrentCashSession,
       _openCashSession = openCashSession,
       super(const CashRegisterState());

  final GetCurrentCashSession _getCurrentCashSession;
  final OpenCashSession _openCashSession;

  Future<void> load() async {
    emit(state.copyWith(status: CashRegisterStatus.loading));

    switch (await _getCurrentCashSession(const NoParams())) {
      case Success<CashSession?>(:final CashSession? value):
        emit(
          CashRegisterState(status: CashRegisterStatus.ready, session: value),
        );
      case Failed<CashSession?>(:final failure):
        emit(
          state.copyWith(status: CashRegisterStatus.failure, failure: failure),
        );
    }
  }

  /// Opens the drawer. Returns `true` when it succeeded so the caller can
  /// navigate.
  Future<bool> open(double openingAmount) async {
    emit(state.copyWith(status: CashRegisterStatus.submitting));

    switch (await _openCashSession(openingAmount)) {
      case Success<CashSession>(:final CashSession value):
        emit(
          CashRegisterState(status: CashRegisterStatus.ready, session: value),
        );
        return true;
      case Failed<CashSession>(:final failure):
        emit(
          state.copyWith(status: CashRegisterStatus.failure, failure: failure),
        );
        return false;
    }
  }

  /// Called after the close-drawer flow finishes.
  void markAsClosed() {
    emit(const CashRegisterState(status: CashRegisterStatus.ready));
  }
}
