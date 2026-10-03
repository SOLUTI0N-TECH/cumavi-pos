import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/cubit/adjust_stock_cubit.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/cubit/receive_stock_cubit.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/cubit/stock_movements_cubit.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/screens/adjust_stock_screen.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/screens/receive_stock_screen.dart';
import 'package:cumavi_pos_mobile/features/inventory/presentation/screens/stock_movements_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/load_app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pump(WidgetTester tester, Widget home) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: AppLocale.bolivianSpanish,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: home,
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  // The mock answers after a real delay: read it outside the fake clock.
  Future<int?> stockOf(WidgetTester tester, String productId) =>
      tester.runAsync(
        () async =>
            (await injector<ProductRepository>().getProductById(productId))
                .valueOrNull!
                .stockQuantity,
      );

  testWidgets('counting the shelf adjusts the stock', (
    WidgetTester tester,
  ) async {
    int saved = 0;
    await pump(
      tester,
      BlocProvider<AdjustStockCubit>(
        create: (_) => injector<AdjustStockCubit>(param1: 'p-008'),
        child: AdjustStockScreen(onClose: () {}, onSaved: () => saved++),
      ),
    );

    expect(find.text('Ajustar stock'), findsOneWidget);
    expect(find.text('Gorra trucker blanca'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '15');
    await tester.pump();
    expect(find.text('15 (-3)'), findsOneWidget);

    await tester.tap(find.text('Guardar ajuste'));
    await settle(tester);

    expect(saved, 1);
    expect(await stockOf(tester, 'p-008'), 15);
  });

  testWidgets('a goods receipt starts with the product and saves it', (
    WidgetTester tester,
  ) async {
    int saved = 0;
    await pump(
      tester,
      BlocProvider<ReceiveStockCubit>(
        create: (_) => injector<ReceiveStockCubit>(),
        child: ReceiveStockScreen(
          initialProductId: 'p-008',
          onClose: () {},
          onSaved: () => saved++,
        ),
      ),
    );

    expect(find.text('Gorra trucker blanca'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump();
    expect(find.text('Registrar ingreso · 2 unidades'), findsOneWidget);

    await tester.tap(find.text('Registrar ingreso · 2 unidades'));
    await settle(tester);

    expect(saved, 1);
    expect(await stockOf(tester, 'p-008'), 20);
  });

  testWidgets('a product with variants asks which one arrived', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      BlocProvider<ReceiveStockCubit>(
        create: (_) => injector<ReceiveStockCubit>(),
        child: ReceiveStockScreen(
          initialProductId: 'p-011',
          onClose: () {},
          onSaved: () {},
        ),
      ),
    );

    expect(find.text('¿Qué variante llegó?'), findsOneWidget);
    await tester.tap(find.text('Gris · L'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Gris · L'), findsOneWidget);
    expect(find.text('Registrar ingreso · 1 unidad'), findsOneWidget);
  });

  testWidgets('the movements screen lists the store history', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      BlocProvider<StockMovementsCubit>(
        create: (_) => injector<StockMovementsCubit>(),
        child: StockMovementsScreen(onBack: () {}),
      ),
    );

    expect(find.text('Movimientos de stock'), findsOneWidget);
    expect(find.textContaining('Importadora Andina'), findsOneWidget);

    await tester.tap(find.text('Ajustes'));
    await settle(tester);
    expect(find.textContaining('Costura abierta'), findsOneWidget);
    expect(find.textContaining('Importadora Andina'), findsNothing);
  });
}
