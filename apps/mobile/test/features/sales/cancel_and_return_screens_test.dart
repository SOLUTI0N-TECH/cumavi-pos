import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/return_sale_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/sale_detail_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/return_sale_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/sale_detail_screen.dart';
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
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  // The mock answers after a real delay: read it outside the fake clock.
  Future<Sale?> saleOf(WidgetTester tester, String id) =>
      tester.runAsync<Sale?>(
        () async =>
            (await injector<SalesRepository>().getSaleById(id)).valueOrNull,
      );

  Widget detail(String saleId, {List<Receipt>? receipts}) =>
      BlocProvider<SaleDetailCubit>(
        create: (_) => injector<SaleDetailCubit>(param1: saleId),
        child: SaleDetailScreen(
          onBack: () {},
          onOpenReceipt: (Receipt receipt) => receipts?.add(receipt),
          onReturn: () async {},
        ),
      );

  testWidgets("today's sale can be cancelled with a reason", (
    WidgetTester tester,
  ) async {
    await pump(tester, detail('sale-seed-1'));

    expect(find.text('Anular'), findsOneWidget);
    expect(find.text('Devolver'), findsOneWidget);
    await tester.tap(find.text('Anular'));
    await tester.pumpAndSettle();
    expect(find.text('¿Anular la venta #0104?'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Se cobró dos veces');
    await tester.pump();
    await tester.tap(find.widgetWithText(TextButton, 'Anular'));
    await settle(tester);

    expect(find.text('Venta anulada'), findsOneWidget);
    expect(find.text('Se cobró dos veces'), findsOneWidget);
    // Cancelled: nothing more to undo.
    expect(find.text('Anular'), findsNothing);
    expect(find.text('Devolver'), findsNothing);
    expect((await saleOf(tester, 'sale-seed-1'))?.isCancelled, isTrue);
  });

  testWidgets('an older sale offers only the return, and lists them', (
    WidgetTester tester,
  ) async {
    final List<Receipt> receipts = <Receipt>[];
    await pump(tester, detail('sale-seed-d3-1', receipts: receipts));

    expect(find.text('Anular'), findsNothing);
    expect(find.text('Devolver'), findsOneWidget);
    expect(find.text('Devolución parcial'), findsOneWidget);
    expect(find.text('1 devuelta'), findsOneWidget);
    expect(find.text('D-0001 · 1 unidad'), findsOneWidget);

    await tester.tap(find.text('Ver comprobante').first);
    expect(receipts.single.isRefund, isTrue);
  });

  testWidgets('a return picks units, method and reason', (
    WidgetTester tester,
  ) async {
    int saved = 0;
    await pump(
      tester,
      BlocProvider<ReturnSaleCubit>(
        create: (_) => injector<ReturnSaleCubit>(param1: 'sale-seed-d2-1'),
        child: ReturnSaleScreen(onClose: () {}, onSaved: () => saved++),
      ),
    );

    expect(find.text('Chamarra de jean'), findsOneWidget);
    expect(find.text('M · Puede devolver 2'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump();
    expect(find.text('Vuelve al stock'), findsOneWidget);

    await tester.tap(find.text('Cambio de talla'));
    await tester.pump();
    await tester.tap(find.text('Devolver Bs 320,00'));
    await settle(tester);

    expect(saved, 1);
    expect(
      (await saleOf(tester, 'sale-seed-d2-1'))?.status,
      SaleStatus.partiallyReturned,
    );
  });
}
