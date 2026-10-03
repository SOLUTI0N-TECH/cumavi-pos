import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/sale_detail_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/sales_history_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/sales_history_screen.dart';
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

  testWidgets('history lists today, filters and finds by number', (
    WidgetTester tester,
  ) async {
    final List<Sale> opened = <Sale>[];
    await pump(
      tester,
      BlocProvider<SalesHistoryCubit>(
        create: (_) => injector<SalesHistoryCubit>(),
        child: SalesHistoryScreen(onBack: () {}, onOpenSale: opened.add),
      ),
    );

    expect(find.text('Historial de ventas'), findsOneWidget);
    expect(find.textContaining('18 ventas'), findsWidgets);

    await tester.tap(find.text('Ayer').first);
    await settle(tester);
    expect(find.textContaining('6 ventas'), findsWidgets);

    await tester.enterText(find.byType(TextField), '5');
    await settle(tester);
    expect(find.text('Buscando en todas las fechas.'), findsOneWidget);
    expect(find.textContaining('#0005 ·'), findsOneWidget);

    await tester.tap(find.textContaining('#0005 ·'));
    expect(opened.single.number, 5);

    await tester.enterText(find.byType(TextField), '9999');
    await settle(tester);
    expect(find.text('No encontramos esa venta'), findsOneWidget);
  });

  testWidgets('sale detail shows the lines and opens the receipt', (
    WidgetTester tester,
  ) async {
    final List<Receipt> receipts = <Receipt>[];
    await pump(
      tester,
      BlocProvider<SaleDetailCubit>(
        create: (_) => injector<SaleDetailCubit>(param1: 'sale-seed-1'),
        child: SaleDetailScreen(
          onBack: () {},
          onOpenReceipt: receipts.add,
          onReturn: () async {},
        ),
      ),
    );

    expect(find.text('Venta #0104'), findsOneWidget);
    expect(find.text('Polera estampada Original'), findsOneWidget);
    expect(find.text('Atendió'), findsOneWidget);
    expect(find.text('Cambio'), findsOneWidget);

    await tester.tap(find.text('Ver comprobante'));
    expect(receipts.single.sale.id, 'sale-seed-1');
  });
}
