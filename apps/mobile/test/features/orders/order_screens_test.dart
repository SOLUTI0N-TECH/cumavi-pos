import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/services/external_launcher.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:cumavi_pos_mobile/features/online_store/presentation/cubit/online_store_cubit.dart';
import 'package:cumavi_pos_mobile/features/online_store/presentation/screens/online_store_screen.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/entities/order.dart';
import 'package:cumavi_pos_mobile/features/orders/domain/usecases/order_usecases.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/cubit/import_order_cubit.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/cubit/order_detail_cubit.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/cubit/orders_inbox_cubit.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/screens/import_order_screen.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/screens/order_detail_screen.dart';
import 'package:cumavi_pos_mobile/features/orders/presentation/screens/orders_inbox_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/load_app_fonts.dart';
import 'import_and_store_test.dart' show webFixture;

typedef AnyBlocProvider = BlocProvider<StateStreamableSource<Object?>>;

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget home, {
    List<AnyBlocProvider> providers = const <AnyBlocProvider>[],
  }) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <AnyBlocProvider>[
          BlocProvider<SessionCubit>(
            create: (_) => injector<SessionCubit>()..refresh(),
          ),
          ...providers,
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: AppLocale.bolivianSpanish,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: home,
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Widget detail(String orderId, {List<OrderCheckout>? checkouts}) =>
      BlocProvider<OrderDetailCubit>(
        create: (_) => injector<OrderDetailCubit>(param1: orderId),
        child: OrderDetailScreen(
          onBack: () {},
          onCheckout: (OrderCheckout checkout) => checkouts?.add(checkout),
          onOpenSale: (_) {},
        ),
      );

  testWidgets('the inbox lists new orders and brings in a simulated one', (
    WidgetTester tester,
  ) async {
    final List<Order> opened = <Order>[];
    await pump(
      tester,
      BlocProvider<OrdersInboxCubit>(
        create: (_) => injector<OrdersInboxCubit>(),
        child: OrdersInboxScreen(
          onBack: () {},
          onOpenOrder: opened.add,
          onImport: () {},
        ),
      ),
    );

    expect(find.text('Pedidos en línea'), findsOneWidget);
    expect(find.text('#1005'), findsOneWidget);
    expect(find.text('#1004'), findsOneWidget);
    expect(find.text('#1002'), findsNothing);

    await tester.tap(find.text('Simular pedido'));
    await settle(tester);
    expect(find.text('#1006'), findsOneWidget);

    await tester.tap(find.text('En curso'));
    await tester.pumpAndSettle();
    expect(find.text('#1002'), findsOneWidget);
    await tester.tap(find.text('#1002'));
    expect(opened.single.number, 1002);
  });

  testWidgets('confirming a delivery asks the fee and offers to notify', (
    WidgetTester tester,
  ) async {
    await pump(tester, detail('order-seed-1005'));

    expect(find.text('Pedido #1005'), findsOneWidget);
    expect(find.text('Andrés Salazar'), findsOneWidget);
    expect(find.text('Por definir'), findsOneWidget);

    await tester.tap(find.text('Confirmar pedido'));
    await tester.pumpAndSettle();
    expect(find.text('Costo de envío'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '10');
    await tester.tap(find.text('Confirmar pedido').last);
    await settle(tester);

    expect(find.text('Confirmado'), findsWidgets);
    expect(find.text('Pedido confirmado'), findsOneWidget);
    expect(find.text('Marcar como listo'), findsOneWidget);

    await tester.tap(find.text('Avisar'));
    await tester.pumpAndSettle();
    final DemoExternalLauncher launcher =
        injector<ExternalLauncher>() as DemoExternalLauncher;
    expect(launcher.requests.single, startsWith('whatsapp:72233445:'));
    expect(launcher.requests.single, contains('Envío: Bs 10,00'));
  });

  testWidgets('a ready order opens the checkout with its cart', (
    WidgetTester tester,
  ) async {
    final List<OrderCheckout> checkouts = <OrderCheckout>[];
    await pump(tester, detail('order-seed-1002', checkouts: checkouts));

    await tester.tap(find.text('Cobrar pedido'));
    await settle(tester);

    expect(checkouts.single.order.number, 1002);
    expect(checkouts.single.cart.total, 205);
  });

  testWidgets('cancelling asks for a reason', (WidgetTester tester) async {
    await pump(tester, detail('order-seed-1004'));

    await tester.ensureVisible(find.text('Cancelar pedido'));
    await tester.tap(find.text('Cancelar pedido'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sin stock'));
    await tester.pump();
    await tester.tap(find.text('Cancelar pedido').last);
    await settle(tester);

    expect(find.text('Cancelado: Sin stock'), findsOneWidget);
    expect(find.text('Cancelar pedido'), findsNothing);
  });

  testWidgets('a pasted WhatsApp message imports the order', (
    WidgetTester tester,
  ) async {
    final List<Order> imported = <Order>[];
    await pump(
      tester,
      BlocProvider<ImportOrderCubit>(
        create: (_) => injector<ImportOrderCubit>(),
        child: ImportOrderScreen(onClose: () {}, onImported: imported.add),
      ),
    );

    await tester.enterText(
      find.byType(TextField),
      'Nuevo pedido #1003\nÁbrelo en Cumavi POS: '
      'https://x.test/illimani-store/pedido/importar/?d=$webFixture',
    );
    await tester.pump();
    await tester.tap(find.text('Importar pedido').last);
    await settle(tester);

    expect(imported.single.customer.name, 'Ana Pérez');
    expect(imported.single.number, 1006);
  });

  testWidgets('the online store shows its link, hours and options', (
    WidgetTester tester,
  ) async {
    // The clipboard is a platform channel: answer it like the phone does.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async => null,
    );
    await pump(
      tester,
      BlocProvider<OnlineStoreCubit>(
        create: (_) => injector<OnlineStoreCubit>(),
        child: OnlineStoreScreen(
          onBack: () {},
          onOpenPoster: () {},
          // Saturday 10:00, inside the demo hours.
          clock: () => DateTime(2026, 10, 10, 10),
        ),
      ),
    );

    expect(find.text('Tienda en línea'), findsOneWidget);
    expect(
      find.text('cumavi-pos-catalogo.netlify.app/illimani-store'),
      findsOneWidget,
    );
    expect(find.text('Abierta ahora'), findsOneWidget);

    await tester.tap(find.text('Copiar'));
    await tester.pumpAndSettle();
    expect(find.text('Link copiado'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Domingo'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.text('Domingo'));
    await tester.pumpAndSettle();
    expect(find.text('Cerrado'), findsOneWidget);
    await tester.tap(find.text('Domingo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar horario'));
    await tester.pump();
    await tester.tap(find.text('Guardar').last);
    await tester.pumpAndSettle();

    expect(find.text('09:00–13:00'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await settle(tester);
    expect(find.text('Tienda en línea guardada'), findsOneWidget);
  });
}
