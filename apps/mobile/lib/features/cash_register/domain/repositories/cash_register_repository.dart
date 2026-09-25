import '../../../../core/utils/result.dart';
import '../entities/cash_session.dart';

/// Input for closing the drawer.
final class CloseCashSessionInput {
  const CloseCashSessionInput({required this.countedAmount, this.note});

  final double countedAmount;
  final String? note;
}

/// Keeps track of the cash drawer.
abstract interface class CashRegisterRepository {
  /// The open session, or `null` when the drawer is closed.
  Future<Result<CashSession?>> getCurrentSession();

  Future<Result<bool>> hasOpenSession();

  Future<Result<CashSession>> openSession({required double openingAmount});

  Future<Result<CashSession>> closeSession(CloseCashSessionInput input);
}
