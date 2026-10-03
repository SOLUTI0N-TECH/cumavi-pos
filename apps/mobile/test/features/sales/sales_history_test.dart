import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/cash_register/data/datasources/in_memory_cash_register_data_source.dart';
import 'package:cumavi_pos_mobile/features/cash_register/data/repositories/cash_register_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/repositories/cash_register_repository.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/usecases/get_current_cash_session.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/in_memory_product_data_source.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/datasources/in_memory_inventory_data_source.dart';
import 'package:cumavi_pos_mobile/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/data/datasources/in_memory_sales_data_source.dart';
import 'package:cumavi_pos_mobile/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/daily_sales_summary.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_query.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sales_day.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/cancel_and_return.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/get_sales.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/sale_detail_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/sales_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sales history over the in-memory sales seeded around a fixed day.
void main() {
  // Noon, after the 18 demo sales of the morning.
  final DateTime now = DateTime(2026, 9, 25, 12);
  final DateTime today = DateTime(2026, 9, 25);
  late SalesRepository repository;

  setUp(() {
    repository = SalesRepositoryImpl(
      dataSource: InMemorySalesDataSource(
        latency: Duration.zero,
        seedReference: now,
      ),
      sessionRepository: InMemorySessionStore(),
    );
  });

  SalesHistoryCubit buildCubit() =>
      SalesHistoryCubit(getSales: GetSales(repository), clock: () => now);

  group('demo sales', () {
    test('two weeks of history keep today as it was', () async {
      final DailySalesSummary todaySummary = (await repository.getDailySummary(
        now,
      )).valueOrNull!;
      final List<Sale> all = (await repository.getSales(const SaleQuery()))
          .valueOrNull!;

      expect(todaySummary.saleCount, 18);
      expect(all.length, 103 + 18);
      expect(
        all
            .map((Sale sale) => sale.createdAt)
            .reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b),
        isA<DateTime>().having(
          (DateTime date) =>
              date.isBefore(today.subtract(const Duration(days: 13))),
          'older than 13 days',
          isTrue,
        ),
      );
    });

    test('numbers follow the order the sales happened', () async {
      final List<Sale> all = (await repository.getSales(const SaleQuery()))
          .valueOrNull!;

      // Newest first, so numbers go down.
      expect(all.first.number, 121);
      expect(all.last.number, 1);
      expect((await repository.getNextSaleNumber()).valueOrNull, 122);
    });
  });

  test('SaleQuery narrows by date, method and number', () async {
    final List<Sale> qr = (await repository.getSales(
      SaleQuery(
        from: today,
        to: today.add(const Duration(days: 1)),
        paymentMethod: PaymentMethod.qr,
      ),
    )).valueOrNull!;
    final List<Sale> byNumber = (await repository.getSales(
      const SaleQuery(number: 104),
    )).valueOrNull!;

    expect(qr, isNotEmpty);
    expect(
      qr.every(
        (Sale sale) =>
            sale.paymentMethod == PaymentMethod.qr &&
            !sale.createdAt.isBefore(today),
      ),
      isTrue,
    );
    expect(byNumber.single.id, 'sale-seed-1');
  });

  test('SalesDay groups by calendar day, newest first', () async {
    final List<Sale> week = (await repository.getSales(
      SaleQuery(from: today.subtract(const Duration(days: 2))),
    )).valueOrNull!;

    final List<SalesDay> days = SalesDay.group(week);

    expect(days.map((SalesDay day) => day.date), <DateTime>[
      today,
      DateTime(2026, 9, 24),
      DateTime(2026, 9, 23),
    ]);
    expect(days.first.sales, hasLength(18));
    expect(
      days.first.total,
      days.first.sales.fold(0.0, (double sum, Sale sale) => sum + sale.total),
    );
  });

  group('SalesHistoryCubit', () {
    test('periods count the sales of their days', () async {
      final SalesHistoryCubit cubit = buildCubit();

      await cubit.load();
      expect(cubit.state.sales, hasLength(18));

      await cubit.periodSelected(SalesPeriod.yesterday);
      expect(cubit.state.sales, hasLength(6));

      await cubit.periodSelected(SalesPeriod.last7Days);
      expect(cubit.state.sales, hasLength(18 + 45));
      expect(cubit.state.days, hasLength(7));
      await cubit.close();
    });

    test('a custom range includes both ends', () async {
      final SalesHistoryCubit cubit = buildCubit();

      await cubit.rangeSelected(DateTime(2026, 9, 23), DateTime(2026, 9, 24));

      expect(cubit.state.period, SalesPeriod.custom);
      expect(cubit.state.days.map((SalesDay day) => day.date), <DateTime>[
        DateTime(2026, 9, 24),
        DateTime(2026, 9, 23),
      ]);
      await cubit.close();
    });

    test('the payment filter keeps only that method', () async {
      final SalesHistoryCubit cubit = buildCubit();
      await cubit.periodSelected(SalesPeriod.last7Days);

      await cubit.paymentMethodSelected(PaymentMethod.bankTransfer);
      expect(cubit.state.sales, isNotEmpty);
      expect(
        cubit.state.sales.every(
          (Sale sale) => sale.paymentMethod == PaymentMethod.bankTransfer,
        ),
        isTrue,
      );

      await cubit.paymentMethodSelected(null);
      expect(cubit.state.sales, hasLength(18 + 45));
      await cubit.close();
    });

    test('a number is found in any date, typed as the seller likes', () async {
      final SalesHistoryCubit cubit = buildCubit();
      await cubit.load();

      await cubit.numberChanged('#0005');
      expect(cubit.state.isSearchingNumber, isTrue);
      expect(cubit.state.sales.single.number, 5);

      await cubit.numberChanged('');
      expect(cubit.state.sales, hasLength(18));
      await cubit.close();
    });
  });

  group('SaleDetailCubit', () {
    SaleDetailCubit detailCubit(String saleId) {
      final CashRegisterRepository cash = CashRegisterRepositoryImpl(
        dataSource: InMemoryCashRegisterDataSource(latency: Duration.zero),
        sessionRepository: InMemorySessionStore(),
      );
      final InventoryRepository inventory = InventoryRepositoryImpl(
        dataSource: InMemoryInventoryDataSource(
          products: InMemoryProductDataSource(latency: Duration.zero),
          latency: Duration.zero,
        ),
        sessionRepository: InMemorySessionStore(),
      );
      return SaleDetailCubit(
        getSale: GetSale(repository),
        getCurrentCashSession: GetCurrentCashSession(cash),
        cancelSale: CancelSale(
          salesRepository: repository,
          inventoryRepository: inventory,
          cashRegisterRepository: cash,
        ),
        saleId: saleId,
      );
    }

    test('reads the sale by id', () async {
      final SaleDetailCubit cubit = detailCubit('sale-seed-1');

      await cubit.load();

      expect(cubit.state.status, SaleDetailStatus.ready);
      expect(cubit.state.sale?.number, 104);
      await cubit.close();
    });

    test('an unknown sale explains itself', () async {
      final SaleDetailCubit cubit = detailCubit('nope');

      await cubit.load();

      expect(cubit.state.status, SaleDetailStatus.failure);
      expect(cubit.state.failure?.code, FailureCode.saleNotFound);
      await cubit.close();
    });
  });
}
