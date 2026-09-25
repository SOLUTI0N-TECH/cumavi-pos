import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/cash_register_repository.dart';

/// Storage contract for cash sessions.
abstract interface class CashRegisterDataSource {
  Future<CashSession?> fetchCurrentSession();

  Future<CashSession> insertSession({
    required double openingAmount,
    required String cashierName,
  });

  Future<CashSession> closeSession(CloseCashSessionInput input);
}
