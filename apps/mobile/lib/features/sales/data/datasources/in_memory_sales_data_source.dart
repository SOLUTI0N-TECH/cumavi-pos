import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/exceptions.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/entities/sale_line.dart';
import '../../domain/entities/sale_return.dart';
import 'sales_data_source.dart';

/// Mock sales storage.
///
/// It starts with two weeks of demo sales so the dashboard, the cash close
/// and the history are not empty on a fresh install, and every new sale is
/// appended in memory.
final class InMemorySalesDataSource implements SalesDataSource {
  InMemorySalesDataSource({Duration? latency, DateTime? seedReference})
    : _latency = latency ?? const Duration(milliseconds: 280),
      _sales = _seedSales(seedReference ?? DateTime.now());

  final Duration _latency;
  final List<Sale> _sales;

  @override
  Future<Sale> insertSale(
    SaleDraft draft, {
    required String cashierName,
  }) async {
    await _simulateLatency();
    final int number = await _nextNumber();
    final Sale sale = Sale(
      id: 'sale-${DateTime.now().microsecondsSinceEpoch}',
      number: number,
      createdAt: DateTime.now(),
      lines: draft.cart.lines
          .map(
            (CartLine line) => SaleLine(
              productId: line.product.id,
              productName: line.product.name,
              variantId: line.variant?.id,
              variantLabel: line.variant?.label,
              unitPrice: line.unitPrice,
              quantity: line.quantity,
            ),
          )
          .toList(),
      discount: draft.cart.discount,
      deliveryFee: draft.cart.deliveryFee,
      paymentMethod: draft.paymentMethod,
      amountReceived: draft.amountReceived,
      cashierName: cashierName,
      channel: draft.orderId == null
          ? SaleChannel.pos
          : SaleChannel.onlineOrder,
      orderId: draft.orderId,
      orderNumber: draft.orderNumber,
    );
    _sales.add(sale);
    return sale;
  }

  @override
  Future<List<Sale>> fetchSales() async {
    await _simulateLatency();
    return List<Sale>.unmodifiable(_sales);
  }

  @override
  Future<Sale> cancelSale(
    String saleId, {
    required String reason,
    required String cancelledBy,
  }) async {
    await _simulateLatency();
    final int index = _indexOf(saleId);
    final Sale cancelled = _sales[index].copyWith(
      cancellation: SaleCancellation(
        reason: reason,
        cancelledAt: DateTime.now(),
        cancelledBy: cancelledBy,
      ),
    );
    _sales[index] = cancelled;
    return cancelled;
  }

  @override
  Future<SaleReturn> insertReturn(
    SaleReturnDraft draft, {
    required String cashierName,
  }) async {
    await _simulateLatency();
    final int index = _indexOf(draft.saleId);
    final int number =
        _sales.fold(0, (int sum, Sale sale) => sum + sale.returns.length) + 1;
    final SaleReturn saleReturn = SaleReturn(
      id: 'return-${DateTime.now().microsecondsSinceEpoch}',
      number: number,
      saleId: draft.saleId,
      lines: draft.lines,
      refundMethod: draft.refundMethod,
      reason: draft.reason,
      createdAt: DateTime.now(),
      cashierName: cashierName,
    );
    _sales[index] = _sales[index].copyWith(
      returns: <SaleReturn>[..._sales[index].returns, saleReturn],
    );
    return saleReturn;
  }

  int _indexOf(String saleId) {
    final int index = _sales.indexWhere((Sale sale) => sale.id == saleId);
    if (index == -1) {
      throw DataSourceException(FailureCode.saleNotFound, detail: saleId);
    }
    return index;
  }

  @override
  Future<int> fetchNextSaleNumber() async {
    await _simulateLatency();
    return _nextNumber();
  }

  Future<int> _nextNumber() async {
    if (_sales.isEmpty) return 1;
    final int highest = _sales
        .map((Sale sale) => sale.number)
        .reduce((int a, int b) => a > b ? a : b);
    return highest + 1;
  }

  Future<void> _simulateLatency() => Future<void>.delayed(_latency);

  /// The catalog as it was when the demo sales happened.
  static const List<({String id, String name, String? variant, double price})>
  _catalogSnapshot =
      <({String id, String name, String? variant, double price})>[
        (
          id: 'p-003',
          name: 'Polera estampada Original',
          variant: 'Azul · M',
          price: 89,
        ),
        (id: 'p-008', name: 'Gorra trucker blanca', variant: null, price: 65),
        (
          id: 'p-006',
          name: 'Lentes de sol clásicos',
          variant: null,
          price: 120,
        ),
        (
          id: 'p-001',
          name: 'Zapatillas urbanas',
          variant: 'Rojo · 40',
          price: 450,
        ),
        (id: 'p-011', name: 'Polera básica', variant: 'Negra · M', price: 75),
        (id: 'p-007', name: 'Mochila urbana', variant: null, price: 260),
        (id: 'p-009', name: 'Chamarra de jean', variant: 'M', price: 320),
        (id: 'p-012', name: 'Zapatillas running', variant: '41', price: 420),
      ];

  static const String _cashier = 'Carla Mamani';

  /// The last two weeks of a small store (5–10 sales a day), then today's
  /// 18 sales over the morning, mirroring the design mockups. Numbers run
  /// in order across all of them.
  static List<Sale> _seedSales(DateTime reference) {
    final DateTime today = DateTime(
      reference.year,
      reference.month,
      reference.day,
    );
    final List<Sale> sales = <Sale>[];

    SaleLine line(int itemIndex, int quantity) {
      final ({String id, String name, String? variant, double price}) item =
          _catalogSnapshot[itemIndex % _catalogSnapshot.length];
      return SaleLine(
        productId: item.id,
        productName: item.name,
        variantId: item.variant == null
            ? null
            : ProductVariant.idFor(<String, String>{
                for (final (int i, String value)
                    in item.variant!.split(' · ').indexed)
                  '$i': value,
              }),
        variantLabel: item.variant,
        unitPrice: item.price,
        quantity: quantity,
      );
    }

    const List<PaymentMethod> pastMethods = <PaymentMethod>[
      PaymentMethod.cash,
      PaymentMethod.qr,
      PaymentMethod.cash,
      PaymentMethod.card,
      PaymentMethod.bankTransfer,
      PaymentMethod.qr,
      PaymentMethod.cash,
    ];
    for (int daysAgo = 14; daysAgo >= 1; daysAgo--) {
      final DateTime dayStart = today
          .subtract(Duration(days: daysAgo))
          .add(const Duration(hours: 9, minutes: 5));
      final int count = 5 + (daysAgo * 7) % 6;
      for (int index = 0; index < count; index++) {
        final List<SaleLine> lines = <SaleLine>[
          line(daysAgo * 3 + index, index % 3 == 0 ? 2 : 1),
          // Every fourth sale takes a second product.
          if ((index + daysAgo) % 4 == 0) line(index + 2, 1),
        ];
        final double subtotal = lines.fold(
          0,
          (double sum, SaleLine line) => sum + line.total,
        );
        final double discount = (index + daysAgo) % 7 == 0 ? 10 : 0;
        final PaymentMethod method =
            pastMethods[(daysAgo + index) % pastMethods.length];
        final double total = subtotal - discount;
        sales.add(
          Sale(
            id: 'sale-seed-d$daysAgo-${index + 1}',
            number: sales.length + 1,
            createdAt: dayStart.add(Duration(minutes: 47 * index)),
            lines: lines,
            discount: discount,
            paymentMethod: method,
            // Cash is usually paid with a round bill.
            amountReceived: method == PaymentMethod.cash
                ? ((total / 50).ceil() * 50).toDouble()
                : total,
            cashierName: _cashier,
          ),
        );
      }
    }

    _addDemoCorrections(sales, today);

    const List<PaymentMethod> todayMethods = <PaymentMethod>[
      PaymentMethod.cash,
      PaymentMethod.qr,
      PaymentMethod.cash,
      PaymentMethod.card,
      PaymentMethod.cash,
      PaymentMethod.qr,
    ];
    final DateTime todayStart = today.add(
      const Duration(hours: 8, minutes: 45),
    );
    for (int index = 0; index < 18; index++) {
      final SaleLine sold = line(index, index.isEven ? 1 : 2);
      final PaymentMethod method = todayMethods[index % todayMethods.length];
      sales.add(
        Sale(
          id: 'sale-seed-${index + 1}',
          number: sales.length + 1,
          createdAt: todayStart.add(Duration(minutes: 9 * index)),
          lines: <SaleLine>[sold],
          discount: 0,
          paymentMethod: method,
          amountReceived: method == PaymentMethod.cash
              ? sold.total + 20
              : sold.total,
          cashierName: _cashier,
        ),
      );
    }
    return sales;
  }

  /// A sale cancelled yesterday and a partial return three days ago, so the
  /// history shows both states from the first launch.
  static void _addDemoCorrections(List<Sale> sales, DateTime today) {
    DateTime at(int daysAgo, int hour) =>
        DateTime(today.year, today.month, today.day - daysAgo, hour, 40);

    final int cancelled = sales.indexWhere(
      (Sale sale) => sale.id == 'sale-seed-d1-3',
    );
    sales[cancelled] = sales[cancelled].copyWith(
      cancellation: SaleCancellation(
        reason: 'Se cobró dos veces',
        cancelledAt: at(1, 12),
        cancelledBy: _cashier,
      ),
    );

    final int returned = sales.indexWhere(
      (Sale sale) => sale.id == 'sale-seed-d3-1',
    );
    final Sale sale = sales[returned];
    final SaleLine line = sale.lines.first;
    sales[returned] = sale.copyWith(
      returns: <SaleReturn>[
        SaleReturn(
          id: 'return-seed-1',
          number: 1,
          saleId: sale.id,
          lines: <SaleReturnLine>[
            SaleReturnLine(
              lineIndex: 0,
              productId: line.productId,
              productName: line.productName,
              variantId: line.variantId,
              variantLabel: line.variantLabel,
              quantity: 1,
              amount: sale.refundFor(0, 1),
              restock: false,
            ),
          ],
          refundMethod: PaymentMethod.cash,
          reason: 'Costura fallada',
          createdAt: at(2, 11),
          cashierName: _cashier,
        ),
      ],
    );
  }
}
