import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/cash_close_summary.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/cash_register_repository.dart';
import '../../domain/usecases/close_cash_session.dart';
import '../../domain/usecases/get_cash_close_summary.dart';
import 'cash_close_state.dart';

/// Drives the close-drawer screen: loads the report, tracks the counted cash
/// and submits the closing.
class CashCloseCubit extends Cubit<CashCloseState> {
  CashCloseCubit({
    required GetCashCloseSummary getCashCloseSummary,
    required CloseCashSession closeCashSession,
  }) : _getCashCloseSummary = getCashCloseSummary,
       _closeCashSession = closeCashSession,
       super(const CashCloseState());

  final GetCashCloseSummary _getCashCloseSummary;
  final CloseCashSession _closeCashSession;

  Future<void> load() async {
    emit(state.copyWith(status: CashCloseStatus.loading));

    switch (await _getCashCloseSummary(const NoParams())) {
      case Success<CashCloseSummary>(:final CashCloseSummary value):
        emit(
          CashCloseState(
            status: CashCloseStatus.ready,
            summary: value,
            // Pre-fill with the expected cash: the cashier only edits it when
            // the count does not match.
            countedAmount: value.expectedCash,
          ),
        );
      case Failed<CashCloseSummary>(:final failure):
        emit(state.copyWith(status: CashCloseStatus.failure, failure: failure));
    }
  }

  void countedAmountChanged(double? amount) {
    emit(
      CashCloseState(
        status: CashCloseStatus.ready,
        summary: state.summary,
        countedAmount: amount,
        note: state.note,
      ),
    );
  }

  void noteChanged(String note) => emit(state.copyWith(note: note));

  Future<void> submit() async {
    final double? counted = state.countedAmount;
    if (counted == null) return;

    emit(state.copyWith(status: CashCloseStatus.submitting));

    final Result<CashSession> result = await _closeCashSession(
      CloseCashSessionInput(
        countedAmount: counted,
        note: state.note.trim().isEmpty ? null : state.note.trim(),
      ),
    );

    switch (result) {
      case Success<CashSession>():
        emit(state.copyWith(status: CashCloseStatus.closed));
      case Failed<CashSession>(:final failure):
        emit(state.copyWith(status: CashCloseStatus.failure, failure: failure));
    }
  }
}
