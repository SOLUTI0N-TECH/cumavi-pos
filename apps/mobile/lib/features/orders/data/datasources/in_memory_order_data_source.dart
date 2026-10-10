import 'dart:async';
import 'dart:math';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_requests.dart';

/// Storage contract of the orders inbox (backend phase B7).
abstract interface class OrderDataSource {
  Future<List<Order>> fetchOrders();

  Stream<OrderEvent> watch();

  Future<Order> changeStatus(
    String id,
    OrderStatusUpdate update, {
    required String userName,
  });

  Future<Order> editOrder(
    String id,
    OrderEdit edit, {
    required String userName,
  });

  Future<Order> markDelivered(
    String id, {
    required String saleId,
    required String userName,
  });

  Future<Order> importOrder(Order order);
}

/// Mock inbox kept in memory: a few orders in every state and, on demand,
/// a new one as if a customer had just ordered from the web.
final class InMemoryOrderDataSource implements OrderDataSource {
  InMemoryOrderDataSource({Duration? latency, DateTime Function()? clock})
    : _latency = latency ?? const Duration(milliseconds: 260),
      _clock = clock ?? DateTime.now {
    _orders.addAll(_seed(_clock()));
  }

  /// First order number of a business (`ECO-R7`).
  static const int firstNumber = 1001;

  final Duration _latency;
  final DateTime Function() _clock;
  final List<Order> _orders = <Order>[];
  final StreamController<OrderEvent> _events =
      StreamController<OrderEvent>.broadcast();
  final Random _random = Random();
  int _sequence = 0;

  @override
  Future<List<Order>> fetchOrders() async {
    await Future<void>.delayed(_latency);
    return List<Order>.unmodifiable(_orders);
  }

  @override
  Stream<OrderEvent> watch() => _events.stream;

  @override
  Future<Order> changeStatus(
    String id,
    OrderStatusUpdate update, {
    required String userName,
  }) async {
    await Future<void>.delayed(_latency);
    final Order order = _find(id);
    final Order updated = order.copyWith(
      status: update.to,
      deliveryFee: update.deliveryFee,
      cancelReason: update.to == OrderStatus.cancelled ? update.note : null,
      history: <OrderStatusChange>[
        ...order.history,
        OrderStatusChange(
          from: order.status,
          to: update.to,
          at: _clock(),
          byName: userName,
          note: update.note,
        ),
      ],
    );
    return _save(updated, created: false);
  }

  @override
  Future<Order> editOrder(
    String id,
    OrderEdit edit, {
    required String userName,
  }) async {
    await Future<void>.delayed(_latency);
    final Order order = _find(id);
    final Order updated = order.copyWith(
      lines: <OrderLine>[
        for (int i = 0; i < order.lines.length; i++)
          if (edit.quantities[i] > 0)
            order.lines[i].withQuantity(edit.quantities[i]),
      ],
      deliveryFee: edit.deliveryFee,
      // An edit keeps the state and leaves a trace (`ECO-R10`).
      history: <OrderStatusChange>[
        ...order.history,
        OrderStatusChange(
          from: order.status,
          to: order.status,
          at: _clock(),
          byName: userName,
          isEdit: true,
        ),
      ],
    );
    return _save(updated, created: false);
  }

  @override
  Future<Order> markDelivered(
    String id, {
    required String saleId,
    required String userName,
  }) async {
    await Future<void>.delayed(_latency);
    final Order order = _find(id);
    final Order updated = order.copyWith(
      status: OrderStatus.delivered,
      saleId: saleId,
      history: <OrderStatusChange>[
        ...order.history,
        OrderStatusChange(
          from: order.status,
          to: OrderStatus.delivered,
          at: _clock(),
          byName: userName,
        ),
      ],
    );
    return _save(updated, created: false);
  }

  @override
  Future<Order> importOrder(Order order) async {
    await Future<void>.delayed(_latency);
    // The web's id makes the import idempotent.
    final Order? existing = _orders
        .where((Order candidate) => candidate.id == order.id)
        .firstOrNull;
    if (existing != null) return existing;
    return _save(_numbered(order, createdAt: order.createdAt), created: true);
  }

  /// Adds one of the demo orders as if it had just come from the web.
  Future<Order> simulateNewOrder() async {
    await Future<void>.delayed(_latency);
    final ({
      OrderCustomer customer,
      Fulfillment fulfillment,
      PaymentMethod method,
      List<OrderLine> lines,
    })
    template = _incomingTemplates[_sequence++ % _incomingTemplates.length];
    return _save(
      _numbered(
        Order(
          id: 'order-${_clock().microsecondsSinceEpoch}',
          number: 0,
          createdAt: _clock(),
          status: OrderStatus.newOrder,
          fulfillment: template.fulfillment,
          customer: template.customer,
          paymentMethod: template.method,
          lines: template.lines,
          publicToken: '',
        ),
        createdAt: _clock(),
      ),
      created: true,
    );
  }

  Order _numbered(Order order, {required DateTime createdAt}) {
    final int number = _orders.isEmpty
        ? firstNumber
        : _orders.map((Order o) => o.number).reduce(max) + 1;
    return Order(
      id: order.id,
      number: number,
      createdAt: createdAt,
      status: OrderStatus.newOrder,
      fulfillment: order.fulfillment,
      customer: order.customer,
      paymentMethod: order.paymentMethod,
      lines: order.lines,
      publicToken: _token(),
      source: order.source,
      history: <OrderStatusChange>[
        OrderStatusChange(to: OrderStatus.newOrder, at: createdAt),
      ],
    );
  }

  String _token() => List<String>.generate(
    16,
    (_) => _random.nextInt(36).toRadixString(36),
  ).join();

  Order _find(String id) {
    final Order? order = _orders
        .where((Order candidate) => candidate.id == id)
        .firstOrNull;
    if (order == null) {
      throw DataSourceException(FailureCode.orderNotFound, detail: id);
    }
    return order;
  }

  Order _save(Order order, {required bool created}) {
    final int index = _orders.indexWhere((Order o) => o.id == order.id);
    if (index == -1) {
      _orders.add(order);
    } else {
      _orders[index] = order;
    }
    _events.add(created ? OrderCreated(order) : OrderUpdated(order));
    return order;
  }

  // ------------------------------------------------------------- demo data

  static const String _owner = 'Carla Mamani';

  static OrderLine _line(
    String productId,
    String name,
    double price, {
    int quantity = 1,
    String? variantId,
    String? variantLabel,
  }) => OrderLine(
    productId: productId,
    productName: name,
    unitPrice: price,
    quantity: quantity,
    variantId: variantId,
    variantLabel: variantLabel,
  );

  /// Orders of the last day in every state, with products of the demo
  /// catalog (same ids as the web's).
  static List<Order> _seed(DateTime now) {
    DateTime ago(Duration duration) => now.subtract(duration);

    Order order({
      required int number,
      required Duration age,
      required OrderStatus status,
      required Fulfillment fulfillment,
      required OrderCustomer customer,
      required PaymentMethod method,
      required List<OrderLine> lines,
      double deliveryFee = 0,
      String? cancelReason,
    }) {
      final DateTime placed = ago(age);
      final List<OrderStatus> path = switch (status) {
        OrderStatus.newOrder => <OrderStatus>[],
        OrderStatus.confirmed => <OrderStatus>[OrderStatus.confirmed],
        OrderStatus.ready => <OrderStatus>[
          OrderStatus.confirmed,
          OrderStatus.ready,
        ],
        OrderStatus.cancelled => <OrderStatus>[OrderStatus.cancelled],
        OrderStatus.delivered => <OrderStatus>[
          OrderStatus.confirmed,
          OrderStatus.ready,
          OrderStatus.delivered,
        ],
      };
      OrderStatus previous = OrderStatus.newOrder;
      final List<OrderStatusChange> history = <OrderStatusChange>[
        OrderStatusChange(to: OrderStatus.newOrder, at: placed),
        for (final (int i, OrderStatus step) in path.indexed)
          OrderStatusChange(
            from: previous,
            to: previous = step,
            at: placed.add(Duration(minutes: 6 * (i + 1))),
            byName: _owner,
            note: step == OrderStatus.cancelled ? cancelReason : null,
          ),
      ];
      return Order(
        id: 'order-seed-$number',
        number: number,
        createdAt: placed,
        status: status,
        fulfillment: fulfillment,
        customer: customer,
        paymentMethod: method,
        lines: lines,
        deliveryFee: deliveryFee,
        publicToken: 'demo$number',
        cancelReason: cancelReason,
        history: history,
      );
    }

    return <Order>[
      order(
        number: 1001,
        age: const Duration(hours: 22),
        status: OrderStatus.cancelled,
        fulfillment: Fulfillment.delivery,
        customer: const OrderCustomer(
          name: 'Jorge Quispe',
          phone: '71234567',
          address: 'Calle Murillo #340, Centro',
        ),
        method: PaymentMethod.cash,
        lines: <OrderLine>[_line('p-007', 'Mochila urbana', 260)],
        cancelReason: 'El cliente no respondió',
      ),
      order(
        number: 1002,
        age: const Duration(hours: 3, minutes: 10),
        status: OrderStatus.ready,
        fulfillment: Fulfillment.pickup,
        customer: const OrderCustomer(
          name: 'Valeria Rojas',
          phone: '76012345',
          note: 'Paso a recoger a las 18:00',
        ),
        method: PaymentMethod.qr,
        lines: <OrderLine>[
          _line('p-008', 'Gorra trucker blanca', 65, quantity: 2),
          _line(
            'p-011',
            'Polera básica',
            75,
            variantId: 'negra/m',
            variantLabel: 'Negra · M',
          ),
        ],
      ),
      order(
        number: 1003,
        age: const Duration(hours: 1, minutes: 40),
        status: OrderStatus.confirmed,
        fulfillment: Fulfillment.delivery,
        customer: const OrderCustomer(
          name: 'Diego Fernández',
          phone: '69876543',
          address: 'Av. Ballivián #1180, Calacoto',
          note: 'Tocar el timbre del 3B',
        ),
        method: PaymentMethod.bankTransfer,
        lines: <OrderLine>[
          _line(
            'p-001',
            'Zapatillas urbanas',
            450,
            variantId: 'azul/40',
            variantLabel: 'Azul · 40',
          ),
        ],
        deliveryFee: 15,
      ),
      order(
        number: 1004,
        age: const Duration(minutes: 35),
        status: OrderStatus.newOrder,
        fulfillment: Fulfillment.pickup,
        customer: const OrderCustomer(name: 'Lucía Mendoza', phone: '77788899'),
        method: PaymentMethod.cash,
        lines: <OrderLine>[
          _line(
            'p-003',
            'Polera estampada Original',
            89,
            quantity: 2,
            variantId: 'rojo/m',
            variantLabel: 'Rojo · M',
          ),
          _line('p-006', 'Lentes de sol clásicos', 120),
        ],
      ),
      order(
        number: 1005,
        age: const Duration(minutes: 8),
        status: OrderStatus.newOrder,
        fulfillment: Fulfillment.delivery,
        customer: const OrderCustomer(
          name: 'Andrés Salazar',
          phone: '72233445',
          address: 'Calle 21 de Calacoto #8050',
        ),
        method: PaymentMethod.qr,
        // Sold out at the counter since: charging it will say so.
        lines: <OrderLine>[
          _line(
            'p-002',
            'Chamarra de cuero',
            690,
            variantId: 's',
            variantLabel: 'S',
          ),
        ],
      ),
    ];
  }

  static const List<
    ({
      OrderCustomer customer,
      Fulfillment fulfillment,
      PaymentMethod method,
      List<OrderLine> lines,
    })
  >
  _incomingTemplates =
      <
        ({
          OrderCustomer customer,
          Fulfillment fulfillment,
          PaymentMethod method,
          List<OrderLine> lines,
        })
      >[
        (
          customer: OrderCustomer(
            name: 'Camila Vargas',
            phone: '70011223',
            note: '¿Tienen bolsa de regalo?',
          ),
          fulfillment: Fulfillment.pickup,
          method: PaymentMethod.qr,
          lines: <OrderLine>[
            OrderLine(
              productId: 'p-005',
              productName: 'Cartera de cuero',
              unitPrice: 380,
              quantity: 1,
              variantId: 'negra',
              variantLabel: 'Negra',
            ),
          ],
        ),
        (
          customer: OrderCustomer(
            name: 'Marco Antezana',
            phone: '67788990',
            address: 'Av. Arce #2799, San Jorge',
          ),
          fulfillment: Fulfillment.delivery,
          method: PaymentMethod.cash,
          lines: <OrderLine>[
            OrderLine(
              productId: 'p-012',
              productName: 'Zapatillas running',
              unitPrice: 420,
              quantity: 1,
              variantId: '41',
              variantLabel: '41',
            ),
            OrderLine(
              productId: 'p-008',
              productName: 'Gorra trucker blanca',
              unitPrice: 65,
              quantity: 1,
            ),
          ],
        ),
        (
          customer: OrderCustomer(name: 'Paola Gutiérrez', phone: '75566778'),
          fulfillment: Fulfillment.pickup,
          method: PaymentMethod.cash,
          lines: <OrderLine>[
            OrderLine(
              productId: 'p-011',
              productName: 'Polera básica',
              unitPrice: 75,
              quantity: 3,
              variantId: 'gris/l',
              variantLabel: 'Gris · L',
            ),
          ],
        ),
      ];
}
