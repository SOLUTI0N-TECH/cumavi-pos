import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../sales/domain/entities/daily_sales_summary.dart';
import '../../../sales/domain/repositories/sales_repository.dart';
import '../entities/cash_close_summary.dart';
import '../entities/cash_session.dart';
import '../repositories/cash_register_repository.dart';

/// Builds the close-drawer report by joining the open session with the sales
/// registered during it.
final class GetCashCloseSummary implements UseCase<CashCloseSummary, NoParams> {
  const GetCashCloseSummary({
    required CashRegisterRepository cashRegisterRepository,
    required SalesRepository salesRepository,
  }) : _cashRegisterRepository = cashRegisterRepository,
       _salesRepository = salesRepository;

  final CashRegisterRepository _cashRegisterRepository;
  final SalesRepository _salesRepository;

  @override
  Future<Result<CashCloseSummary>> call(NoParams input) async {
    final Result<CashSession?> sessionResult = await _cashRegisterRepository
        .getCurrentSession();

    final CashSession? session;
    switch (sessionResult) {
      case Failed<CashSession?>(:final Failure failure):
        return Failed<CashCloseSummary>(failure);
      case Success<CashSession?>(:final CashSession? value):
        session = value;
    }

    if (session == null) {
      return const Failed<CashCloseSummary>(
        ConflictFailure(FailureCode.cashSessionNotOpen),
      );
    }

    final Result<DailySalesSummary> salesResult = await _salesRepository
        .getSummarySince(session.openedAt);

    return switch (salesResult) {
      Failed<DailySalesSummary>(:final Failure failure) =>
        Failed<CashCloseSummary>(failure),
      Success<DailySalesSummary>(:final DailySalesSummary value) =>
        Success<CashCloseSummary>(
          CashCloseSummary(session: session, sales: value),
        ),
    };
  }
}
