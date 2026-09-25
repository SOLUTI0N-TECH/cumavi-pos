import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../auth/domain/repositories/session_repository.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/cash_register_repository.dart';
import '../datasources/cash_register_data_source.dart';

final class CashRegisterRepositoryImpl implements CashRegisterRepository {
  const CashRegisterRepositoryImpl({
    required CashRegisterDataSource dataSource,
    required SessionRepository sessionRepository,
  }) : _dataSource = dataSource,
       _sessionRepository = sessionRepository;

  final CashRegisterDataSource _dataSource;
  final SessionRepository _sessionRepository;

  @override
  Future<Result<CashSession?>> getCurrentSession() async {
    try {
      return Success<CashSession?>(await _dataSource.fetchCurrentSession());
    } on DataSourceException catch (exception) {
      return Failed<CashSession?>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<bool>> hasOpenSession() async {
    try {
      return Success<bool>(await _dataSource.fetchCurrentSession() != null);
    } on DataSourceException catch (exception) {
      return Failed<bool>(UnexpectedFailure(exception.code));
    }
  }

  @override
  Future<Result<CashSession>> openSession({
    required double openingAmount,
  }) async {
    try {
      return Success<CashSession>(
        await _dataSource.insertSession(
          openingAmount: openingAmount,
          cashierName: _sessionRepository.currentCashierName,
        ),
      );
    } on DataSourceException catch (exception) {
      return Failed<CashSession>(
        ConflictFailure(exception.code, detail: exception.detail),
      );
    }
  }

  @override
  Future<Result<CashSession>> closeSession(CloseCashSessionInput input) async {
    try {
      return Success<CashSession>(await _dataSource.closeSession(input));
    } on DataSourceException catch (exception) {
      return Failed<CashSession>(
        ConflictFailure(exception.code, detail: exception.detail),
      );
    }
  }
}
