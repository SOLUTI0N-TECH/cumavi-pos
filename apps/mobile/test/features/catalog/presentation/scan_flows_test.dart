import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/catalog/data/datasources/catalog_seed_data.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/scanner/barcode_camera.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/scanner/demo_barcode_camera.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/scanner/scanner_screen.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/inventory_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart_line.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/cart_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/views/sale_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../helpers/load_app_fonts.dart';

typedef AnyBlocProvider = BlocProvider<StateStreamableSource<Object?>>;

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pump(
    WidgetTester tester,
    Widget screen, {
    List<AnyBlocProvider> providers = const <AnyBlocProvider>[],
  }) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final Widget app = MaterialApp(
      theme: AppTheme.light(),
      locale: AppLocale.bolivianSpanish,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: screen,
    );
    await tester.pumpWidget(
      providers.isEmpty
          ? app
          : MultiBlocProvider(providers: providers, child: app),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  group('ScannerScreen', () {
    Future<List<String>> pumpScanner(WidgetTester tester) async {
      final List<String> codes = <String>[];
      await pump(
        tester,
        ScannerScreen(
          purpose: ScanPurpose.sell,
          camera: const DemoBarcodeCamera(),
          demoCodes: CatalogSeedData.demoScanCodes,
          onCode: codes.add,
          onClose: () {},
        ),
      );
      return codes;
    }

    testWidgets('a typed code is handed back normalized', (
      WidgetTester tester,
    ) async {
      final List<String> codes = await pumpScanner(tester);

      expect(find.text('Escanear producto'), findsOneWidget);
      await tester.enterText(find.byType(TextField), ' cal 001 ');
      await tester.pump();
      await tester.tap(find.byTooltip('Usar código'));
      await tester.pump();

      expect(codes, <String>['CAL001']);
    });

    testWidgets('a demo code is used once', (WidgetTester tester) async {
      final List<String> codes = await pumpScanner(tester);

      await tester.tap(find.text('Gorra trucker'));
      await tester.tap(find.text('Mochila urbana'));
      await tester.pump();

      expect(codes, <String>[CatalogSeedData.barcodeFor('p-008')]);
    });
  });

  group('selling by scan', () {
    Future<CartCubit> pumpSale(WidgetTester tester, String code) async {
      final CartCubit cart = injector<CartCubit>();
      await pump(
        tester,
        Scaffold(
          body: SaleView(
            onOpenCatalog: ({String? categoryId}) {},
            onCheckout: () {},
            onManageCashRegister: () {},
            onScan: () async => code,
          ),
        ),
        providers: <AnyBlocProvider>[
          BlocProvider<CartCubit>.value(value: cart),
          BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
        ],
      );
      await tester.tap(find.byTooltip('Escanear código'));
      await settle(tester);
      return cart;
    }

    testWidgets("a variant's code adds that variant", (
      WidgetTester tester,
    ) async {
      final CartCubit cart = await pumpSale(
        tester,
        CatalogSeedData.barcodeFor('p-011', variantIndex: 2),
      );

      final CartLine line = cart.state.cart.lines.single;
      expect(line.product.name, 'Polera básica');
      expect(line.variant?.label, 'Negra · M');
      expect(
        find.text('Se agregó a la venta: Polera básica (Negra · M)'),
        findsOneWidget,
      );
    });

    testWidgets('an unknown code explains itself', (WidgetTester tester) async {
      final CartCubit cart = await pumpSale(tester, '123456');

      expect(cart.state.cart.isEmpty, isTrue);
      expect(
        find.text('Ningún producto tiene el código 123456.'),
        findsOneWidget,
      );
    });
  });

  group('inventory scan', () {
    testWidgets('opens the product or offers to create it', (
      WidgetTester tester,
    ) async {
      String code = CatalogSeedData.barcodeFor('p-008');
      final List<String> opened = <String>[];
      final List<String> created = <String>[];
      await pump(
        tester,
        InventoryScreen(
          onCreateProduct: () {},
          onOpenProduct: (Product product) => opened.add(product.name),
          onManageCategories: () {},
          onScan: () async => code,
          onCreateWithBarcode: created.add,
        ),
        providers: <AnyBlocProvider>[
          BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
        ],
      );

      await tester.tap(find.byTooltip('Escanear código'));
      await settle(tester);
      expect(opened, <String>['Gorra trucker blanca']);

      code = '7770000099001';
      await tester.tap(find.byTooltip('Escanear código'));
      await settle(tester);
      expect(find.text('Código sin producto'), findsOneWidget);
      await tester.tap(find.text('Crear producto con este código'));
      await tester.pumpAndSettle();

      expect(created, <String>['7770000099001']);
    });
  });
}
