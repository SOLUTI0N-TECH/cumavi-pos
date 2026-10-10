import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/usecases/use_case.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/entities/stock_movement.dart';
import 'package:cumavi_pos_mobile/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:cumavi_pos_mobile/features/online_store/domain/entities/store_settings.dart';
import 'package:cumavi_pos_mobile/features/online_store/domain/repositories/store_settings_repository.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/entities/order.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/entities/order_requests.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/repositories/order_repository.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/usecases/order_usecases.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/cubit/orders_badge_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The orders inbox over the demo services wired as in the app.
void main() {
  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<Order> order(int number) async =>
      (await injector<OrderRepository>().getOrders(const OrderQuery()))
          .valueOrNull!
          .singleWhere((Order o) => o.number == number);

  Future<Result<Order>> move(
    int number,
    OrderStatus to, {
    String? note,
    double? deliveryFee,
  }) async => injector<UpdateOrderStatus>()(
    OrderStatusRequest(
      orderId: (await order(number)).id,
      update: OrderStatusUpdate(to: to, note: note, deliveryFee: deliveryFee),
    ),
  );

  Future<int> stock(String productId, {String? variantId}) async {
    final Product product = (await injector<ProductRepository>().getProductById(
      productId,
    )).valueOrNull!;
    return variantId == null
        ? product.stockQuantity
        : product.variantById(variantId)!.stockQuantity;
  }

  test('the demo inbox has orders in every open state', () async {
    final List<Order> orders = (await injector<GetOrders>()(const OrderQuery()))
        .valueOrNull!;

    expect(orders.map((Order o) => o.number), <int>[
      1005,
      1004,
      1003,
      1002,
      1001,
    ]);
    expect(orders.map((Order o) => o.status), <OrderStatus>[
      OrderStatus.newOrder,
      OrderStatus.newOrder,
      OrderStatus.confirmed,
      OrderStatus.ready,
      OrderStatus.cancelled,
    ]);
    expect((await order(1003)).total, 450 + 15);
  });

  group('status changes (ECO-R8)', () {
    test('follow new → confirmed → ready and keep the history', () async {
      expect((await move(1004, OrderStatus.confirmed)).failureOrNull, isNull);
      final Order ready = (await move(1004, OrderStatus.ready)).valueOrNull!;

      expect(ready.status, OrderStatus.ready);
      expect(ready.history.map((OrderStatusChange c) => c.to), <OrderStatus>[
        OrderStatus.newOrder,
        OrderStatus.confirmed,
        OrderStatus.ready,
      ]);
      expect(ready.history.last.byName, 'Carla Mamani');
    });

    test('refuse jumps, going back and changing a closed order', () async {
      Future<FailureCode?> code(int number, OrderStatus to) async =>
          (await move(number, to, note: 'x')).failureOrNull?.code;

      expect(
        await code(1004, OrderStatus.ready),
        FailureCode.invalidOrderTransition,
      );
      expect(
        await code(1002, OrderStatus.confirmed),
        FailureCode.invalidOrderTransition,
      );
      expect(
        await code(1001, OrderStatus.confirmed),
        FailureCode.invalidOrderTransition,
      );
      // Delivered only through "Cobrar pedido".
      expect(
        await code(1002, OrderStatus.delivered),
        FailureCode.invalidOrderTransition,
      );
    });

    test('cancelling needs a reason and keeps it', () async {
      expect(
        (await move(
          1004,
          OrderStatus.cancelled,
          note: ' ',
        )).failureOrNull?.code,
        FailureCode.reasonRequired,
      );
      final Order cancelled = (await move(
        1004,
        OrderStatus.cancelled,
        note: 'Sin stock',
      )).valueOrNull!;
      expect(cancelled.cancelReason, 'Sin stock');
    });

    test('confirming a delivery sets its fee, never negative', () async {
      expect(
        (await move(
          1005,
          OrderStatus.confirmed,
          deliveryFee: -1,
        )).failureOrNull?.code,
        FailureCode.invalidDeliveryFee,
      );
      final Order confirmed = (await move(
        1005,
        OrderStatus.confirmed,
        deliveryFee: 10,
      )).valueOrNull!;
      expect(confirmed.deliveryFee, 10);
      expect(confirmed.total, 690 + 10);
    });
  });

  group('editing (ECO-R10)', () {
    Future<Result<Order>> edit(
      int number,
      List<int> quantities,
      double fee,
    ) async => injector<EditOrder>()(
      OrderEditRequest(
        orderId: (await order(number)).id,
        edit: OrderEdit(quantities: quantities, deliveryFee: fee),
      ),
    );

    test('changes quantities and removes lines, leaving a trace', () async {
      final Order edited = (await edit(1004, <int>[1, 0], 0)).valueOrNull!;

      expect(edited.lines.single.quantity, 1);
      expect(edited.total, 89);
      expect(edited.history.last.isEdit, isTrue);
      expect(edited.status, OrderStatus.newOrder);
    });

    test('is refused once ready, or leaving nothing', () async {
      expect(
        (await edit(1002, <int>[1, 1], 0)).failureOrNull?.code,
        FailureCode.orderNotEditable,
      );
      expect(
        (await edit(1004, <int>[0, 0], 0)).failureOrNull?.code,
        FailureCode.orderEmpty,
      );
    });
  });

  group('charging (ECO-R9)', () {
    test('only a ready order with stock can be charged', () async {
      Future<FailureCode?> prepare(int number) async =>
          (await injector<PrepareOrderCheckout>()((await order(number)).id))
              .failureOrNull
              ?.code;

      expect(await prepare(1004), FailureCode.invalidOrderTransition);

      await move(1005, OrderStatus.confirmed, deliveryFee: 0);
      await move(1005, OrderStatus.ready);
      // Chamarra de cuero S has no stock left.
      expect(await prepare(1005), FailureCode.insufficientStock);
    });

    test('creates the sale at the order price and delivers it', () async {
      final Order ready = await order(1002);
      final int capsBefore = await stock('p-008');
      final OrderCheckout checkout = (await injector<PrepareOrderCheckout>()(
        ready.id,
      )).valueOrNull!;
      expect(checkout.cart.total, ready.total);

      final Sale sale = (await injector<CheckoutOrder>(param1: ready.id)(
        SaleDraft(
          cart: checkout.cart,
          paymentMethod: PaymentMethod.qr,
          amountReceived: checkout.cart.total,
        ),
      )).valueOrNull!;

      expect(sale.channel, SaleChannel.onlineOrder);
      expect(sale.orderNumber, 1002);
      expect(sale.total, ready.total);
      final Order delivered = await order(1002);
      expect(delivered.status, OrderStatus.delivered);
      expect(delivered.saleId, sale.id);
      expect(await stock('p-008'), capsBefore - 2);
      final StockMovement movement =
          (await injector<InventoryRepository>().getMovements(
            const StockMovementQuery(productId: 'p-008', limit: 1),
          )).valueOrNull!.single;
      expect(movement.saleId, sale.id);

      // Charging it again is refused.
      final Result<Sale> again =
          await injector<CheckoutOrder>(param1: ready.id)(
            SaleDraft(
              cart: checkout.cart,
              paymentMethod: PaymentMethod.qr,
              amountReceived: checkout.cart.total,
            ),
          );
      expect(again.failureOrNull?.code, FailureCode.invalidOrderTransition);
    });

    test('the delivery fee is charged and printed with the sale', () async {
      await move(1003, OrderStatus.ready);
      final Order ready = await order(1003);
      final OrderCheckout checkout = (await injector<PrepareOrderCheckout>()(
        ready.id,
      )).valueOrNull!;

      final Sale sale = (await injector<CheckoutOrder>(param1: ready.id)(
        SaleDraft(
          cart: checkout.cart,
          paymentMethod: PaymentMethod.cash,
          amountReceived: 500,
        ),
      )).valueOrNull!;

      expect(sale.deliveryFee, 15);
      expect(sale.total, 465);
      expect(sale.change, 35);
    });
  });

  group('new orders', () {
    test('arrive as an event and raise the badge', () async {
      final OrdersBadgeCubit badge = injector<OrdersBadgeCubit>();
      await badge.load();
      expect(badge.state.newCount, 2);
      expect(badge.state.inProgressCount, 2);
      final Future<OrderEvent> event = injector<WatchOrders>()().first;

      final Order arrived = (await injector<SimulateIncomingOrder>()(
        const NoParams(),
      )).valueOrNull!;

      expect(arrived.number, 1006);
      expect(await event, OrderCreated(arrived));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(badge.state.newCount, 3);
      expect(badge.state.arrived, arrived);
      await badge.close();
    });

    test("don't arrive while the online store is disabled", () async {
      final StoreSettingsRepository settings =
          injector<StoreSettingsRepository>();
      final StoreSettings current = (await settings.getSettings()).valueOrNull!;
      await settings.saveSettings(current.copyWith(isEnabled: false));

      final Result<Order> result = await injector<SimulateIncomingOrder>()(
        const NoParams(),
      );

      expect(result.failureOrNull?.code, FailureCode.storeDisabled);
    });
  });
}
