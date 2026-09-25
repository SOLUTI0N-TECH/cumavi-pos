import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/cubit/registration_cubit.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/screens/business_profile_screen.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/screens/business_ready_screen.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/screens/phone_verification_screen.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/screens/register_account_screen.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/screens/sales_setup_screen.dart';
import 'package:cumavi_pos_mobile/features/cash_register/presentation/cubit/cash_close_cubit.dart';
import 'package:cumavi_pos_mobile/features/cash_register/presentation/cubit/cash_register_cubit.dart';
import 'package:cumavi_pos_mobile/features/cash_register/presentation/screens/close_cash_session_screen.dart';
import 'package:cumavi_pos_mobile/features/cash_register/presentation/views/open_cash_session_view.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/services/photo_capturer.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_form_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/background_removal_screen.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/inventory_screen.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/product_form_screen.dart';
import 'package:cumavi_pos_mobile/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:cumavi_pos_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_line.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/cart_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/checkout_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/checkout_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/product_search_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/receipt_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/sale_completed_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/views/sale_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/load_app_fonts.dart';

typedef AnyBlocProvider = BlocProvider<StateStreamableSource<Object?>>;

/// Products with variants are sold in one of them.
ProductVariant? firstAvailableVariant(Product product) => product.variants
    .where((ProductVariant variant) => variant.isAvailable)
    .firstOrNull;

/// Renders every screen at phone size.
///
/// Layout errors (overflows) fail the test, so this suite is the safety net
/// that keeps the screens matching the mockups as the code grows.
void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
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
          home: screen,
        ),
      ),
    );
    // The mocks answer after a simulated latency; advance the fake clock past
    // it before waiting for animations to finish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Sale buildSale() {
    return Sale(
      id: 'sale-1',
      number: 19,
      createdAt: DateTime(2026, 9, 17, 11, 24),
      lines: const <SaleLine>[
        SaleLine(
          productId: 'p-001',
          productName: 'Zapatillas urbanas rojas',
          unitPrice: 450,
          quantity: 1,
        ),
        SaleLine(
          productId: 'p-003',
          productName: 'Polera estampada Original',
          unitPrice: 89,
          quantity: 2,
        ),
      ],
      discount: 0,
      paymentMethod: PaymentMethod.cash,
      amountReceived: 700,
      cashierName: 'Carla Mamani',
    );
  }

  // Built from the seed synchronously: inside testWidgets time is simulated,
  // so awaiting the mocks' latency directly would never complete.
  Cart buildCartWithProducts() {
    Cart cart = const Cart.empty();
    for (final Product product in CatalogSeedData.products().take(3)) {
      cart = cart.addProduct(product, variant: firstAvailableVariant(product));
    }
    return cart;
  }

  testWidgets('dashboard renders', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      DashboardScreen(onStartSale: () {}, onOpenInventory: () {}),
      providers: <AnyBlocProvider>[
        BlocProvider<DashboardCubit>(create: (_) => injector<DashboardCubit>()),
      ],
    );

    expect(find.text('Ventas de hoy'), findsOneWidget);
    expect(find.text('Métodos de pago'), findsOneWidget);
  });

  testWidgets('open cash drawer renders', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      const Scaffold(body: OpenCashSessionView()),
      providers: <AnyBlocProvider>[
        BlocProvider<CashRegisterCubit>(
          create: (_) => injector<CashRegisterCubit>(),
        ),
      ],
    );

    expect(find.text('Abre la caja para empezar a vender'), findsOneWidget);
    expect(find.text('Abrir caja'), findsOneWidget);
  });

  testWidgets('empty cart renders with its category shortcuts', (
    WidgetTester tester,
  ) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: SaleView(
          onOpenCatalog: ({String? categoryId}) {},
          onCheckout: () {},
          onManageCashRegister: () {},
        ),
      ),
      providers: <AnyBlocProvider>[
        BlocProvider<CartCubit>(create: (_) => injector<CartCubit>()),
        BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
      ],
    );

    expect(find.text('El carrito está vacío'), findsOneWidget);
    expect(find.text('Explorar por categoría'), findsOneWidget);
  });

  testWidgets('cart with products renders', (WidgetTester tester) async {
    final CartCubit cartCubit = injector<CartCubit>();
    for (final Product product in CatalogSeedData.products().take(3)) {
      cartCubit.addProduct(product, variant: firstAvailableVariant(product));
    }

    await pumpScreen(
      tester,
      Scaffold(
        body: SaleView(
          onOpenCatalog: ({String? categoryId}) {},
          onCheckout: () {},
          onManageCashRegister: () {},
        ),
      ),
      providers: <AnyBlocProvider>[
        BlocProvider<CartCubit>.value(value: cartCubit),
        BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
      ],
    );

    expect(find.text('Cobrar'), findsOneWidget);
    expect(find.textContaining('Carrito'), findsOneWidget);
  });

  testWidgets('catalog search renders', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      ProductSearchScreen(onBack: () {}),
      providers: <AnyBlocProvider>[
        BlocProvider<CartCubit>(create: (_) => injector<CartCubit>()),
        BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
      ],
    );

    expect(find.text('Todos'), findsOneWidget);
    expect(find.text('Zapatillas urbanas'), findsOneWidget);
  });

  testWidgets('checkout renders with the change', (WidgetTester tester) async {
    final Cart cart = buildCartWithProducts();

    await pumpScreen(
      tester,
      CheckoutScreen(
        saleNumberLabel: '#0019',
        onBack: () {},
        onCompleted: (_) {},
      ),
      providers: <AnyBlocProvider>[
        BlocProvider<CheckoutCubit>(
          create: (_) => injector<CheckoutCubit>(param1: cart),
        ),
      ],
    );

    expect(find.text('Total a cobrar'), findsOneWidget);
    expect(find.text('Efectivo'), findsOneWidget);
    expect(find.text('Cambio a devolver'), findsOneWidget);
  });

  testWidgets('sale completed renders', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      SaleCompletedScreen(
        sale: buildSale(),
        onNewSale: () {},
        onGoHome: () {},
        onOpenReceipt: () {},
      ),
    );

    expect(find.text('Venta registrada'), findsOneWidget);
    expect(find.text('Comprobante'), findsOneWidget);
  });

  testWidgets('receipt renders', (WidgetTester tester) async {
    await pumpScreen(tester, ReceiptScreen(sale: buildSale(), onBack: () {}));

    expect(find.text('TOTAL'), findsOneWidget);
    expect(find.text('¡Gracias por tu compra!'), findsOneWidget);
  });

  testWidgets('close cash drawer renders', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      CloseCashSessionScreen(onClosed: () {}, onBack: () {}),
      providers: <AnyBlocProvider>[
        BlocProvider<CashCloseCubit>(create: (_) => injector<CashCloseCubit>()),
      ],
    );

    expect(find.text('Cerrar caja'), findsOneWidget);
    expect(find.text('Efectivo esperado'), findsOneWidget);
  });

  testWidgets('inventory renders', (WidgetTester tester) async {
    await pumpScreen(
      tester,
      InventoryScreen(onCreateProduct: () {}, onOpenProduct: (_) {}),
      providers: <AnyBlocProvider>[
        BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
      ],
    );

    expect(find.text('Inventario'), findsOneWidget);
    expect(find.text('Crear producto'), findsOneWidget);
  });

  testWidgets('product form renders and removes the photo background', (
    WidgetTester tester,
  ) async {
    final ProductFormCubit formCubit = injector<ProductFormCubit>();

    await pumpScreen(
      tester,
      ProductFormScreen(onClose: () {}, onSaved: (_) {}, onAdjustPhoto: () {}),
      providers: <AnyBlocProvider>[
        BlocProvider<ProductFormCubit>.value(value: formCubit),
      ],
    );

    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('Quitar fondo'), findsOneWidget);

    await tester.runAsync(() => formCubit.capturePhoto(PhotoSource.camera));
    await tester.pumpAndSettle();

    expect(find.text('Fondo quitado'), findsOneWidget);
  });

  testWidgets('background removal renders', (WidgetTester tester) async {
    final ProductFormCubit formCubit = injector<ProductFormCubit>();
    await tester.runAsync(() => formCubit.capturePhoto(PhotoSource.camera));

    await pumpScreen(
      tester,
      BackgroundRemovalScreen(onDone: () {}),
      providers: <AnyBlocProvider>[
        BlocProvider<ProductFormCubit>.value(value: formCubit),
      ],
    );

    expect(find.text('Sin fondo'), findsOneWidget);
    expect(find.text('Usar foto'), findsOneWidget);
  });

  group('registration flow', () {
    testWidgets('step 1 renders', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        RegisterAccountScreen(
          onBack: () {},
          onCodeSent: () {},
          onAccountReady: () {},
          onSignIn: () {},
        ),
        providers: <AnyBlocProvider>[
          BlocProvider<RegistrationCubit>(
            create: (_) => injector<RegistrationCubit>(),
          ),
        ],
      );

      expect(find.text('Crea tu cuenta'), findsOneWidget);
      expect(
        find.textContaining('Paso 1 de 4', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('step 2 renders', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        PhoneVerificationScreen(onBack: () {}, onVerified: () {}),
        providers: <AnyBlocProvider>[
          BlocProvider<RegistrationCubit>(
            create: (_) => injector<RegistrationCubit>(),
          ),
        ],
      );

      expect(find.text('Ingresa el código'), findsOneWidget);
      expect(find.text('Verificar'), findsOneWidget);
    });

    testWidgets('step 3 renders', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        BusinessProfileScreen(onBack: () {}, onSaved: () {}),
        providers: <AnyBlocProvider>[
          BlocProvider<RegistrationCubit>(
            create: (_) => injector<RegistrationCubit>(),
          ),
        ],
      );

      expect(find.text('Sobre tu negocio'), findsOneWidget);
      expect(find.text('Ropa y calzado'), findsOneWidget);
    });

    testWidgets('step 4 renders', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        SalesSetupScreen(onBack: () {}, onCompleted: () {}),
        providers: <AnyBlocProvider>[
          BlocProvider<RegistrationCubit>(
            create: (_) => injector<RegistrationCubit>(),
          ),
        ],
      );

      expect(find.text('Últimos detalles'), findsOneWidget);
      expect(find.text('Terminar registro'), findsOneWidget);
    });

    testWidgets('business ready renders', (WidgetTester tester) async {
      await pumpScreen(
        tester,
        BusinessReadyScreen(
          onCreateProduct: () {},
          onOpenCashRegister: () {},
          onGoHome: () {},
        ),
        providers: <AnyBlocProvider>[
          BlocProvider<RegistrationCubit>(
            create: (_) => injector<RegistrationCubit>(),
          ),
        ],
      );

      expect(find.text('Primeros pasos'), findsOneWidget);
      expect(find.text('Agregar mi primer producto'), findsOneWidget);
    });
  });
}
