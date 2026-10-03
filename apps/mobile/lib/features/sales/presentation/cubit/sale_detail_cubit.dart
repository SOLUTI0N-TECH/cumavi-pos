import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../cash_register/domain/entities/cash_session.dart';
import '../../../cash_register/domain/usecases/get_current_cash_session.dart';
import '../../domain/entities/sale.dart';
import '../../domain/usecases/cancel_and_return.dart';
import '../../domain/usecases/get_sales.dart';

enum SaleDetailStatus { loading, ready, failure }

final class SaleDetailState extends Equatable {
  const SaleDetailState({
    this.status = SaleDetailStatus.loading,
    this.sale,
    this.session,
    this.checkedAt,
    this.cancelling = false,
    this.failure,
  });

  final SaleDetailStatus status;
  final Sale? sale;

  /// The open cash session, which decides whether the sale can be
  /// cancelled.
  final CashSession? session;

  /// When the sale was read, for the 30-day return window.
  final DateTime? checkedAt;
  final bool cancelling;
  final Failure? failure;

  bool get canCancel {
    final Sale? sale = this.sale;
    return sale != null &&
        SaleCorrectionRules.cancelBlocker(sale, session) == null;
  }

  bool get canReturn {
    final Sale? sale = this.sale;
    final DateTime? checkedAt = this.checkedAt;
    return sale != null &&
        checkedAt != null &&
        SaleCorrectionRules.returnBlocker(sale, checkedAt) == null;
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    sale,
    session,
    checkedAt,
    cancelling,
    failure,
  ];
}

/// One past sale, read by id so the screen survives a restart of the route,
/// with what can still be done with it: cancel it or return some units.
class SaleDetailCubit extends Cubit<SaleDetailState> {
  SaleDetailCubit({
    required GetSale getSale,
    required GetCurrentCashSession getCurrentCashSession,
    required CancelSale cancelSale,
    required String saleId,
    DateTime Function()? clock,
  }) : _getSale = getSale,
       _getCurrentCashSession = getCurrentCashSession,
       _cancelSale = cancelSale,
       _saleId = saleId,
       _clock = clock ?? DateTime.now,
       super(const SaleDetailState());

  final GetSale _getSale;
  final GetCurrentCashSession _getCurrentCashSession;
  final CancelSale _cancelSale;
  final String _saleId;
  final DateTime Function() _clock;

  /// Also called after a return, to show it.
  Future<void> load() async {
    // Keep the sale on screen while refreshing it.
    emit(SaleDetailState(sale: state.sale, session: state.session));
    final Result<CashSession?> session = await _getCurrentCashSession(
      const NoParams(),
    );
    switch (await _getSale(_saleId)) {
      case Success<Sale>(:final Sale value):
        emit(
          SaleDetailState(
            status: SaleDetailStatus.ready,
            sale: value,
            session: session.valueOrNull,
            checkedAt: _clock(),
          ),
        );
      case Failed<Sale>(:final failure):
        emit(
          SaleDetailState(
            status: SaleDetailStatus.failure,
            sale: state.sale,
            failure: failure,
          ),
        );
    }
  }

  /// Cancels the whole sale; returns the failure, or `null` when done.
  Future<Failure?> cancel(String reason) async {
    emit(
      SaleDetailState(
        status: state.status,
        sale: state.sale,
        session: state.session,
        checkedAt: state.checkedAt,
        cancelling: true,
      ),
    );
    final Result<Sale> result = await _cancelSale(
      SaleCancellationRequest(saleId: _saleId, reason: reason),
    );
    await load();
    return result.failureOrNull;
  }
}
