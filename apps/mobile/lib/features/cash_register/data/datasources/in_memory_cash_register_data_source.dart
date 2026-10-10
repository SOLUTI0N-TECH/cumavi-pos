import '../../../../core/error/exceptions.dart';
import '../../domain/entities/cash_session.dart';
import '../../domain/repositories/cash_register_repository.dart';
import 'cash_register_data_source.dart';

/// Mock cash drawer.
///
/// It starts with an open session (today at 08:30, Bs 200 float) so the demo
/// lands on the sale screen; closing it takes the app back to the opening
/// form, just like the real flow.
final class InMemoryCashRegisterDataSource implements CashRegisterDataSource {
  InMemoryCashRegisterDataSource({
    Duration? latency,
    CashSession? initialSession,
    DateTime? now,
  }) : _latency = latency ?? const Duration(milliseconds: 220),
       _session = initialSession ?? _seedSession(now ?? DateTime.now());

  final Duration _latency;
  CashSession? _session;
  int _sequence = 1;

  @override
  Future<CashSession?> fetchCurrentSession() async {
    await _simulateLatency();
    final CashSession? session = _session;
    if (session == null || !session.isOpen) return null;
    return session;
  }

  @override
  Future<CashSession> insertSession({
    required double openingAmount,
    required String cashierName,
  }) async {
    await _simulateLatency();
    if (_session?.isOpen ?? false) {
      throw const DataSourceException(FailureCode.cashSessionAlreadyOpen);
    }
    final CashSession session = CashSession(
      id: 'cash-${++_sequence}',
      openedAt: DateTime.now(),
      openingAmount: openingAmount,
      cashierName: cashierName,
    );
    _session = session;
    return session;
  }

  @override
  Future<CashSession> closeSession(CloseCashSessionInput input) async {
    await _simulateLatency();
    final CashSession? current = _session;
    if (current == null || !current.isOpen) {
      throw const DataSourceException(FailureCode.cashSessionNotOpen);
    }
    final CashSession closed = current.close(
      closedAt: DateTime.now(),
      countedAmount: input.countedAmount,
      closingNote: input.note,
    );
    _session = closed;
    return closed;
  }

  Future<void> _simulateLatency() => Future<void>.delayed(_latency);

  static CashSession _seedSession(DateTime now) {
    final DateTime usualOpening = DateTime(now.year, now.month, now.day, 8, 30);
    return CashSession(
      id: 'cash-1',
      // Before 08:30 the demo drawer opened a moment ago: an opening in the
      // future would leave what is sold or refunded now out of the close.
      openedAt: now.isAfter(usualOpening)
          ? usualOpening
          : now.subtract(const Duration(minutes: 5)),
      openingAmount: 200,
      cashierName: 'Carla Mamani',
    );
  }
}
