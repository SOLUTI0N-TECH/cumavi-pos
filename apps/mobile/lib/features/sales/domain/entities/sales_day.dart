import 'package:equatable/equatable.dart';

import 'sale.dart';

/// The sales of one calendar day, as the history shows them.
final class SalesDay extends Equatable {
  const SalesDay({required this.date, required this.sales});

  /// Midnight of the day.
  final DateTime date;

  /// Newest first.
  final List<Sale> sales;

  /// Money of the day's sales; cancelled ones don't count.
  double get total => sales
      .where((Sale sale) => !sale.isCancelled)
      .fold(0, (double sum, Sale sale) => sum + sale.total);

  /// Groups [sales] (newest first) by calendar day, newest day first.
  static List<SalesDay> group(List<Sale> sales) {
    final Map<DateTime, List<Sale>> byDay = <DateTime, List<Sale>>{};
    for (final Sale sale in sales) {
      final DateTime day = DateTime(
        sale.createdAt.year,
        sale.createdAt.month,
        sale.createdAt.day,
      );
      (byDay[day] ??= <Sale>[]).add(sale);
    }
    return <SalesDay>[
      for (final MapEntry<DateTime, List<Sale>> entry in byDay.entries)
        SalesDay(date: entry.key, sales: entry.value),
    ];
  }

  @override
  List<Object?> get props => <Object?>[date, sales];
}
