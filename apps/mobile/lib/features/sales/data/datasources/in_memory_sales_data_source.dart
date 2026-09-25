import '../../../../core/domain/payment_method.dart';
import '../../domain/entities/cart_line.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_draft.dart';
import '../../domain/entities/sale_line.dart';
import 'sales_data_source.dart';

/// Mock sales storage.
///
/// It starts with a day of demo sales so the dashboard and the cash close are
/// not empty on a fresh install, and every new sale is appended in memory.
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
      paymentMethod: draft.paymentMethod,
      amountReceived: draft.amountReceived,
      cashierName: cashierName,
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

  /// 18 sales spread over today's morning, mirroring the design mockups.
  static List<Sale> _seedSales(DateTime reference) {
    final DateTime dayStart = DateTime(
      reference.year,
      reference.month,
      reference.day,
      8,
      45,
    );

    const List<({String id, String name, String? variant, double price})>
    catalogSnapshot =
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

    const List<PaymentMethod> methodRotation = <PaymentMethod>[
      PaymentMethod.cash,
      PaymentMethod.qr,
      PaymentMethod.cash,
      PaymentMethod.card,
      PaymentMethod.cash,
      PaymentMethod.qr,
    ];

    return List<Sale>.generate(18, (int index) {
      final ({String id, String name, String? variant, double price}) item =
          catalogSnapshot[index % catalogSnapshot.length];
      final int quantity = index.isEven ? 1 : 2;
      final PaymentMethod method =
          methodRotation[index % methodRotation.length];
      final double total = item.price * quantity;

      return Sale(
        id: 'sale-seed-${index + 1}',
        number: index + 1,
        createdAt: dayStart.add(Duration(minutes: 9 * index)),
        lines: <SaleLine>[
          SaleLine(
            productId: item.id,
            productName: item.name,
            variantLabel: item.variant,
            unitPrice: item.price,
            quantity: quantity,
          ),
        ],
        discount: 0,
        paymentMethod: method,
        amountReceived: method == PaymentMethod.cash ? total + 20 : total,
        cashierName: 'Carla Mamani',
      );
    });
  }
}
