import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';

/// Aggregated sales of one day, used by the dashboard and the cash close.
final class DailySalesSummary extends Equatable {
  const DailySalesSummary({
    required this.date,
    required this.saleCount,
    required this.soldUnits,
    required this.totalsByMethod,
  });

  const DailySalesSummary.empty(DateTime date)
    : this(
        date: date,
        saleCount: 0,
        soldUnits: 0,
        totalsByMethod: const <PaymentMethod, double>{},
      );

  final DateTime date;
  final int saleCount;
  final int soldUnits;
  final Map<PaymentMethod, double> totalsByMethod;

  double get total => totalsByMethod.values.fold(
    0,
    (double sum, double amount) => sum + amount,
  );

  double get cashTotal => totalFor(PaymentMethod.cash);

  double get averageTicket => saleCount == 0 ? 0 : total / saleCount;

  double totalFor(PaymentMethod method) => totalsByMethod[method] ?? 0;

  /// Share of the day's revenue taken by [method], between 0 and 1.
  double shareFor(PaymentMethod method) =>
      total == 0 ? 0 : totalFor(method) / total;

  /// Methods with at least one sale, highest amount first.
  List<PaymentMethod> get usedMethods {
    final List<PaymentMethod> methods =
        totalsByMethod.entries
            .where((MapEntry<PaymentMethod, double> entry) => entry.value > 0)
            .map((MapEntry<PaymentMethod, double> entry) => entry.key)
            .toList()
          ..sort(
            (PaymentMethod a, PaymentMethod b) =>
                totalFor(b).compareTo(totalFor(a)),
          );
    return methods;
  }

  @override
  List<Object?> get props => <Object?>[
    date,
    saleCount,
    soldUnits,
    totalsByMethod,
  ];
}
