import 'package:equatable/equatable.dart';

/// A cash drawer shift. The POS works without turnos: one session stays open
/// from the moment it is opened until the cashier closes it.
final class CashSession extends Equatable {
  const CashSession({
    required this.id,
    required this.openedAt,
    required this.openingAmount,
    required this.cashierName,
    this.closedAt,
    this.countedAmount,
    this.closingNote,
  });

  final String id;
  final DateTime openedAt;

  /// Money placed in the drawer when opening.
  final double openingAmount;
  final String cashierName;
  final DateTime? closedAt;

  /// Cash counted by the cashier when closing.
  final double? countedAmount;
  final String? closingNote;

  bool get isOpen => closedAt == null;

  Duration get elapsed => (closedAt ?? DateTime.now()).difference(openedAt);

  CashSession close({
    required DateTime closedAt,
    required double countedAmount,
    String? closingNote,
  }) {
    return CashSession(
      id: id,
      openedAt: openedAt,
      openingAmount: openingAmount,
      cashierName: cashierName,
      closedAt: closedAt,
      countedAmount: countedAmount,
      closingNote: closingNote,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    openedAt,
    openingAmount,
    cashierName,
    closedAt,
    countedAmount,
    closingNote,
  ];
}
