import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/usecases/use_case.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/entities/cash_close_summary.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/repositories/cash_register_repository.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/usecases/get_cash_close_summary.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/data/services/receipt_text_builder.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/daily_sales_summary.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_line.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_return.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/cancel_and_return.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Cancelling and returning over the demo services wired as in the app.
void main() {
  setUp(() async {
    await initializeDateFormatting('es');
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<Sale> sale(String id) async =>
      (await injector<SalesRepository>().getSaleById(id)).valueOrNull!;

  Future<int> variantStock(String productId, String variantId) async {
    final Product product = (await injector<ProductRepository>().getProductById(
      productId,
    )).valueOrNull!;
    return product.variantById(variantId)!.stockQuantity;
  }

  Future<DailySalesSummary> today() async =>
      (await injector<SalesRepository>().getDailySummary(DateTime.now()))
          .valueOrNull!;

  SaleReturnRequest returnOf(
    String saleId, {
    int quantity = 1,
    bool restock = true,
    PaymentMethod method = PaymentMethod.cash,
    String reason = 'Cambio de talla',
  }) => SaleReturnRequest(
    saleId: saleId,
    items: <ReturnItem>[
      ReturnItem(lineIndex: 0, quantity: quantity, restock: restock),
    ],
    refundMethod: method,
    reason: reason,
  );

  group('discount proration', () {
    final Sale discounted = Sale(
      id: 's',
      number: 1,
      createdAt: _epoch,
      lines: <SaleLine>[
        SaleLine(productId: 'a', productName: 'A', unitPrice: 100, quantity: 1),
        SaleLine(productId: 'b', productName: 'B', unitPrice: 25, quantity: 2),
      ],
      discount: 10,
      paymentMethod: PaymentMethod.cash,
      amountReceived: 140,
      cashierName: 'Carla',
    );

    test('each line carries its share of the discount', () {
      expect(discounted.lineNetTotal(0), 93.33);
      expect(discounted.lineNetTotal(1), 46.67);
      expect(
        discounted.lineNetTotal(0) + discounted.lineNetTotal(1),
        discounted.total,
      );
    });

    test('the last units refund exactly what is left', () {
      final double first = discounted.refundFor(1, 1);
      final Sale afterOne = discounted.copyWith(
        returns: <SaleReturn>[
          SaleReturn(
            id: 'r',
            number: 1,
            saleId: 's',
            lines: <SaleReturnLine>[
              SaleReturnLine(
                lineIndex: 1,
                productId: 'b',
                productName: 'B',
                quantity: 1,
                amount: first,
                restock: true,
              ),
            ],
            refundMethod: PaymentMethod.cash,
            reason: 'x',
            createdAt: _epoch,
            cashierName: 'Carla',
          ),
        ],
      );

      expect(first + afterOne.refundFor(1, 1), 46.67);
      expect(afterOne.returnableQuantity(1), 1);
      expect(afterOne.status, SaleStatus.partiallyReturned);
    });
  });

  test('the demo history has a cancelled sale and a partial return', () async {
    expect((await sale('sale-seed-d1-3')).status, SaleStatus.cancelled);
    expect((await sale('sale-seed-d3-1')).status, SaleStatus.partiallyReturned);

    final DateTime now = DateTime.now();
    final DailySalesSummary yesterday =
        (await injector<SalesRepository>().getDailySummary(
          DateTime(now.year, now.month, now.day - 1),
        )).valueOrNull!;
    // Six sales yesterday, one of them cancelled.
    expect(yesterday.saleCount, 5);
  });

  group('CancelSale', () {
    test('takes the sale out of the totals and puts the units back', () async {
      final DailySalesSummary before = await today();
      final int stockBefore = await variantStock('p-003', 'azul/m');
      final Sale target = await sale('sale-seed-1');

      final Result<Sale> result = await injector<CancelSale>()(
        const SaleCancellationRequest(
          saleId: 'sale-seed-1',
          reason: 'Se cobró dos veces',
        ),
      );

      expect(result.valueOrNull?.status, SaleStatus.cancelled);
      expect(result.valueOrNull?.cancellation?.cancelledBy, 'Carla Mamani');
      final DailySalesSummary after = await today();
      expect(after.saleCount, before.saleCount - 1);
      expect(after.total, closeTo(before.total - target.total, 0.001));
      expect(await variantStock('p-003', 'azul/m'), stockBefore + 1);

      final StockMovement movement =
          (await injector<InventoryRepository>().getMovements(
            const StockMovementQuery(productId: 'p-003', limit: 1),
          )).valueOrNull!.single;
      expect(movement.type, StockMovementType.cancellation);
      expect(movement.saleId, 'sale-seed-1');
    });

    test('refuses twice, without reason or outside the open cash', () async {
      Future<FailureCode?> cancel(String id, [String reason = 'Error']) async =>
          (await injector<CancelSale>()(
            SaleCancellationRequest(saleId: id, reason: reason),
          )).failureOrNull?.code;

      expect(await cancel('sale-seed-2', ' '), FailureCode.reasonRequired);
      expect(await cancel('sale-seed-2'), isNull);
      expect(await cancel('sale-seed-2'), FailureCode.saleAlreadyCancelled);
      expect(
        await cancel('sale-seed-d1-1'),
        FailureCode.saleCancelWindowClosed,
      );
      expect(await cancel('sale-seed-d3-1'), FailureCode.saleHasReturns);
    });
  });

  group('RegisterReturn', () {
    test('refunds by method, lowers the expected cash and restocks', () async {
      final CashCloseSummary closeBefore =
          (await injector<GetCashCloseSummary>()(const NoParams()))
              .valueOrNull!;
      final int stockBefore = await variantStock('p-009', 'm');

      final SaleReturn refund = (await injector<RegisterReturn>()(
        returnOf('sale-seed-d2-1'),
      )).valueOrNull!;

      expect(refund.amount, 320);
      expect(refund.formattedNumber, 'D-0002');
      expect(await variantStock('p-009', 'm'), stockBefore + 1);
      final DailySalesSummary summary = await today();
      expect(summary.refundCount, 1);
      expect(summary.refundsByMethod[PaymentMethod.cash], 320);
      final CashCloseSummary closeAfter =
          (await injector<GetCashCloseSummary>()(const NoParams()))
              .valueOrNull!;
      expect(closeAfter.expectedCash, closeBefore.expectedCash - 320);
      expect(
        (await sale('sale-seed-d2-1')).status,
        SaleStatus.partiallyReturned,
      );
    });

    test('damaged units do not go back to stock', () async {
      final int stockBefore = await variantStock('p-009', 'm');

      await injector<RegisterReturn>()(
        returnOf('sale-seed-d2-1', restock: false),
      );

      expect(await variantStock('p-009', 'm'), stockBefore);
    });

    test('never returns more than was sold, across returns', () async {
      final RegisterReturn register = injector<RegisterReturn>();
      expect(
        (await register(returnOf('sale-seed-d2-1'))).failureOrNull,
        isNull,
      );
      expect(
        (await register(returnOf('sale-seed-d2-1'))).failureOrNull,
        isNull,
      );
      expect(
        (await register(returnOf('sale-seed-d2-1'))).failureOrNull?.code,
        FailureCode.returnQuantityExceeded,
      );
      expect((await sale('sale-seed-d2-1')).status, SaleStatus.returned);
    });

    test(
      'checks the window, the method, the reason and cancelled sales',
      () async {
        final RegisterReturn late = RegisterReturn(
          salesRepository: injector<SalesRepository>(),
          inventoryRepository: injector<InventoryRepository>(),
          cashRegisterRepository: injector<CashRegisterRepository>(),
          clock: () => DateTime.now().add(const Duration(days: 40)),
        );
        Future<FailureCode?> code(Future<Result<SaleReturn>> result) async =>
            (await result).failureOrNull?.code;

        expect(
          await code(late(returnOf('sale-seed-d2-1'))),
          FailureCode.returnWindowClosed,
        );
        expect(
          await code(
            injector<RegisterReturn>()(
              returnOf('sale-seed-d2-1', method: PaymentMethod.card),
            ),
          ),
          FailureCode.invalidRefundMethod,
        );
        expect(
          await code(
            injector<RegisterReturn>()(returnOf('sale-seed-d2-1', reason: '')),
          ),
          FailureCode.reasonRequired,
        );
        expect(
          await code(injector<RegisterReturn>()(returnOf('sale-seed-d1-3'))),
          FailureCode.saleAlreadyCancelled,
        );
      },
    );
  });

  test('receipts are stamped and a return prints as its own receipt', () async {
    final ReceiptTextBuilder texts = injector<ReceiptTextBuilder>();
    final Sale cancelled = await sale('sale-seed-d1-3');
    final Sale withReturn = await sale('sale-seed-d3-1');

    final Receipt refund = Receipt.refund(
      original: withReturn,
      refund: withReturn.returns.single,
    );

    expect(Receipt(sale: cancelled).mark, ReceiptMark.cancelled);
    expect(texts.build(Receipt(sale: cancelled)), contains('*ANULADA*'));
    expect(refund.number, 'D-0001');
    expect(refund.sale.total, withReturn.returns.single.amount);
    expect(
      texts.build(refund),
      contains('De la venta ${withReturn.formattedNumber}'),
    );
    expect(
      Receipt(sale: withReturn).markLabel(injector<AppLocalizations>()),
      'CON DEVOLUCIÓN PARCIAL',
    );
  });
}

final DateTime _epoch = DateTime(2026);
