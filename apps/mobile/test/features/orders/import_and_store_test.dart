import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/usecases/use_case.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_draft.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/usecases/create_product.dart';
import 'package:cumavi_pos_mobile/features/online_store/domain/entities/store_settings.dart';
import 'package:cumavi_pos_mobile/features/online_store/domain/usecases/store_settings_usecases.dart';
import 'package:cumavi_pos_mobile/features/online_store/presentation/cubit/online_store_cubit.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/entities/order.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/entities/order_requests.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/repositories/order_repository.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/usecases/import_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Orders imported from the web's WhatsApp link, and the online store
/// settings.
void main() {
  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Order webOrder({String id = 'web-1', String productId = 'p-001'}) => Order(
    id: id,
    number: 0,
    createdAt: DateTime.utc(2026, 10, 10, 15, 20),
    status: OrderStatus.newOrder,
    fulfillment: Fulfillment.delivery,
    customer: const OrderCustomer(
      name: 'Ana Pérez',
      phone: '76543210',
      address: 'Av. Arce #10',
      note: 'Después de las 6',
    ),
    paymentMethod: PaymentMethod.qr,
    lines: <OrderLine>[
      OrderLine(
        productId: productId,
        productName: 'Zapatillas urbanas',
        variantId: 'rojo/40',
        variantLabel: 'Rojo · 40',
        unitPrice: 450,
        quantity: 1,
      ),
    ],
    publicToken: '',
    source: OrderSource.whatsappImport,
  );

  String link({String store = 'illimani-store', Order? order}) =>
      'https://cumavi-pos-catalogo.netlify.app/$store/pedido/importar/?d='
      '${OrderLinkCodec.encode(OrderLinkPayload(storeSlug: store, order: order ?? webOrder(), webNumber: 1001))}';

  group('OrderLinkCodec', () {
    test('reads the order back, also from a whole WhatsApp message', () {
      final String message =
          '*Pedido #1001 · Illimani Store*\n1 x Zapatillas urbanas\n\n'
          'Ábrelo en Cumavi POS: ${link()}';

      final OrderLinkPayload payload = OrderLinkCodec.decode(message)!;

      expect(payload.storeSlug, 'illimani-store');
      expect(payload.webNumber, 1001);
      expect(payload.order.customer.name, 'Ana Pérez');
      expect(payload.order.lines.single.variantLabel, 'Rojo · 40');
      expect(payload.order.fulfillment, Fulfillment.delivery);
      expect(payload.order.paymentMethod, PaymentMethod.qr);
    });

    test('reads what the web catalog writes', () {
      // Made by apps/web/src/features/ordering/domain/order-link.ts.
      const String fromWeb = webFixture;

      final OrderLinkPayload payload = OrderLinkCodec.decode(fromWeb)!;

      expect(payload.order.id, 'f1e2d3c4-0000-4000-8000-000000000001');
      expect(payload.order.customer.name, 'Ana Pérez');
      expect(payload.order.lines.map((OrderLine l) => l.quantity), <int>[2, 1]);
      expect(payload.order.lines.first.variantId, 'negra/m');
      expect(payload.order.lines.last.variantId, isNull);
    });

    test('ignores text without an order', () {
      expect(OrderLinkCodec.decode('hola, ¿tienen talla M?'), isNull);
      expect(OrderLinkCodec.decode('https://x.com/?d=no-es-un-pedido'), isNull);
    });
  });

  group('ImportOrder', () {
    test('puts the web order in the inbox once', () async {
      final Order imported = (await injector<ImportOrder>()(link()))
          .valueOrNull!;

      expect(imported.number, 1006);
      expect(imported.status, OrderStatus.newOrder);
      expect(imported.source, OrderSource.whatsappImport);
      expect(imported.publicToken, isNotEmpty);

      final Order again = (await injector<ImportOrder>()(link())).valueOrNull!;
      expect(again.id, imported.id);
      final List<Order> all = (await injector<OrderRepository>().getOrders(
        const OrderQuery(),
      )).valueOrNull!;
      expect(all.where((Order o) => o.id == 'web-1'), hasLength(1));
    });

    test('refuses other stores, unknown products and broken links', () async {
      Future<FailureCode?> code(String text) async =>
          (await injector<ImportOrder>()(text)).failureOrNull?.code;

      expect(
        await code(link(store: 'otra-tienda')),
        FailureCode.orderFromAnotherStore,
      );
      expect(
        await code(link(order: webOrder(productId: 'p-999'))),
        FailureCode.productNotFound,
      );
      expect(await code('nada que importar'), FailureCode.invalidOrderLink);
    });
  });

  group('StoreSettingsRules', () {
    test('slug of the business name', () {
      expect(StoreSettingsRules.slugFor('Illimani Store'), 'illimani-store');
      expect(StoreSettingsRules.slugFor('  Ñandú & Café  '), 'nandu-cafe');
      expect(StoreSettingsRules.slugFor('!!!'), 'mi-tienda');
    });

    test('hours close after opening and never overlap (SUC-R5)', () {
      const OpeningHoursRange morning = OpeningHoursRange(
        weekday: 1,
        opensAt: 9 * 60,
        closesAt: 13 * 60,
      );
      expect(
        StoreSettingsRules.checkOpeningHours(const <OpeningHoursRange>[
          morning,
          OpeningHoursRange(weekday: 1, opensAt: 15 * 60, closesAt: 20 * 60),
        ]),
        isNull,
      );
      expect(
        StoreSettingsRules.checkOpeningHours(const <OpeningHoursRange>[
          morning,
          OpeningHoursRange(weekday: 1, opensAt: 12 * 60, closesAt: 14 * 60),
        ])?.code,
        FailureCode.invalidOpeningHours,
      );
      expect(
        StoreSettingsRules.checkOpeningHours(const <OpeningHoursRange>[
          OpeningHoursRange(weekday: 2, opensAt: 18 * 60, closesAt: 9 * 60),
        ])?.code,
        FailureCode.invalidOpeningHours,
      );
    });

    test('open now follows the ranges of the day', () {
      const StoreSettings settings = StoreSettings(
        isEnabled: true,
        slug: 's',
        openingHours: <OpeningHoursRange>[
          OpeningHoursRange(weekday: 6, opensAt: 9 * 60, closesAt: 13 * 60),
        ],
      );
      // 2026-10-10 is a Saturday.
      expect(settings.isOpenAt(DateTime(2026, 10, 10, 10)), isTrue);
      expect(settings.isOpenAt(DateTime(2026, 10, 10, 13)), isFalse);
      expect(settings.isOpenAt(DateTime(2026, 10, 11, 10)), isFalse);
    });
  });

  group('SaveStoreSettings', () {
    Future<StoreSettings> current() async =>
        (await injector<GetStoreSettings>()(const NoParams())).valueOrNull!;

    test('starts like the web catalog demo store', () async {
      final StoreSettings settings = await current();

      expect(settings.slug, 'illimani-store');
      expect(settings.isEnabled, isTrue);
      expect(settings.rangesFor(7), isEmpty);
      expect(settings.onlinePaymentMethods, <PaymentMethod>[
        PaymentMethod.cash,
        PaymentMethod.qr,
        PaymentMethod.bankTransfer,
      ]);
    });

    test('checks WhatsApp, fulfillment and payments', () async {
      final StoreSettings settings = await current();
      Future<FailureCode?> save(StoreSettings s) async =>
          (await injector<SaveStoreSettings>()(s)).failureOrNull?.code;

      expect(
        await save(settings.copyWith(whatsapp: '1234')),
        FailureCode.invalidMobileNumber,
      );
      expect(
        await save(
          settings.copyWith(pickupEnabled: false, deliveryEnabled: false),
        ),
        FailureCode.onlineFulfillmentRequired,
      );
      expect(
        await save(settings.copyWith(onlinePaymentMethods: <PaymentMethod>[])),
        FailureCode.onlinePaymentMethodRequired,
      );
      final Result<StoreSettings> saved = await injector<SaveStoreSettings>()(
        settings.copyWith(whatsapp: '+591 7111 2233', tagline: '  Hola  '),
      );
      expect(saved.valueOrNull?.whatsapp, '71112233');
      expect(saved.valueOrNull?.tagline, 'Hola');
    });

    test('products hidden online are not counted as online', () async {
      await injector<CreateProduct>()(
        ProductDraft(
          name: 'Taza de prueba',
          categoryId: CatalogSeedData.accessories.id,
          salePrice: 30,
          costPrice: 10,
          showOnline: false,
        ),
      );
      final OnlineStoreCubit cubit = injector<OnlineStoreCubit>();
      await cubit.load();

      expect(cubit.state.onlineProducts, 14);
      expect(cubit.state.totalProducts, 15);
      await cubit.close();
    });

    test('the screen cubit edits a draft and saves it', () async {
      final OnlineStoreCubit cubit = injector<OnlineStoreCubit>();
      await cubit.load();
      expect(cubit.state.onlineProducts, 14);
      expect(
        cubit.storeUrl,
        'https://cumavi-pos-catalogo.netlify.app/illimani-store',
      );

      cubit
        ..paymentMethodToggled(PaymentMethod.card)
        ..dayHoursChanged(7, const <OpeningHoursRange>[
          OpeningHoursRange(weekday: 7, opensAt: 10 * 60, closesAt: 14 * 60),
        ]);
      expect(cubit.state.hasChanges, isTrue);
      expect(cubit.state.draft!.onlinePaymentMethods, <PaymentMethod>[
        PaymentMethod.cash,
        PaymentMethod.qr,
        PaymentMethod.card,
        PaymentMethod.bankTransfer,
      ]);

      expect(await cubit.save(), isNull);
      expect(cubit.state.hasChanges, isFalse);
      expect((await current()).rangesFor(7), hasLength(1));
      await cubit.close();
    });
  });
}

/// An order link written by the web catalog's encoder (see the test of
/// `order-link.ts`): two lines, one with a variant, delivery, QR.
const String webFixture =
    'eyJ2IjoxLCJzIjoiaWxsaW1hbmktc3RvcmUiLCJpZCI6ImYxZTJkM2M0LTAwMDAtNDAwMC04MDAwLTAwMDAwMDAwMDAwMSIsIm4iOjEwMDMsInQiOiIyMDI2LTEwLTEwVDE5OjIwOjAwLjAwMFoiLCJmIjoiZGVsaXZlcnkiLCJtIjoicXIiLCJjIjp7Im4iOiJBbmEgUMOpcmV6IiwicCI6Ijc2NTQzMjEwIiwiYSI6IkF2LiBBcmNlICMxMCIsIm8iOiIifSwibCI6W1sicC0wMTEiLCJuZWdyYS9tIiwyLDc1LCJQb2xlcmEgYsOhc2ljYSIsIk5lZ3JhIMK3IE0iXSxbInAtMDA4IiwiIiwxLDY1LCJHb3JyYSB0cnVja2VyIGJsYW5jYSIsIiJdXX0';
