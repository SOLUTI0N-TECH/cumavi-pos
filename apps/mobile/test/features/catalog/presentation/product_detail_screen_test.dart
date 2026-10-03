import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_detail_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../helpers/load_app_fonts.dart';

/// Renders the inventory's product detail at phone size with the demo
/// catalog. Overflows fail the test, like in `screens_render_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pumpDetail(
    WidgetTester tester,
    String productId, {
    Future<void> Function()? onEdit,
  }) async {
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
        home: BlocProvider<ProductDetailCubit>(
          create: (_) =>
              injector<ProductDetailCubit>(param1: productId)..load(),
          child: ProductDetailScreen(
            onBack: () {},
            onEdit: onEdit ?? () async {},
            onReceiveStock: () {},
            onAdjustStock: () {},
            onOpenMovements: () {},
          ),
        ),
      ),
    );
    // The mocks answer after a simulated latency; advance the fake clock past
    // it before waiting for animations to finish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Finder text(String value) => find.text(value, skipOffstage: false);

  testWidgets('product with color and size variants groups them by color', (
    WidgetTester tester,
  ) async {
    int edits = 0;
    await pumpDetail(tester, 'p-001', onEdit: () async => edits++);

    expect(text('Zapatillas urbanas'), findsOneWidget);
    expect(text('Calzado'), findsOneWidget);
    expect(text('Precio de venta'), findsOneWidget);
    expect(text('Bs 450,00'), findsOneWidget);
    expect(text('Bs 290,00'), findsOneWidget);
    expect(text('Bs 160,00 · 35,6 %'), findsOneWidget);
    // 15 variants: 12 units in total and 7 of them sold out.
    expect(text('12'), findsOneWidget);
    expect(text('7'), findsOneWidget);
    expect(text('Rojo, Azul, Negro'), findsOneWidget);
    expect(text('38, 39, 40, 41, 42'), findsOneWidget);
    // One group per color with its subtotal and a row per size.
    for (final String color in <String>['Rojo', 'Azul', 'Negro']) {
      expect(text(color), findsOneWidget);
    }
    expect(text('7 u.'), findsOneWidget);
    expect(text('4 agotadas'), findsOneWidget);
    expect(text('38'), findsNWidgets(3));
    expect(text('Agotado'), findsNWidgets(7));
    expect(text('Editar producto'), findsOneWidget);

    await tester.tap(find.text('Editar producto'));
    await tester.tap(find.byTooltip('Editar producto'));
    expect(edits, 2);
  });

  testWidgets('thumbnails switch the gallery photo', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, 'p-001');

    final Finder pages = find.byType(PageView);
    expect(tester.widget<PageView>(pages).controller!.page, 0);

    await tester.tap(find.bySemanticsLabel('Foto 3 de 3'));
    await tester.pumpAndSettle();

    expect(tester.widget<PageView>(pages).controller!.page, 2);
  });

  testWidgets('simple product shows its stock without a variants section', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, 'p-006');

    expect(text('Lentes de sol clásicos'), findsOneWidget);
    expect(text('14 u.'), findsOneWidget);
    expect(text('Protección UV400, marco de acetato.'), findsOneWidget);
    expect(text('Variantes'), findsNothing);
    expect(find.byType(PageView), findsOneWidget);
    expect(find.bySemanticsLabel('Foto 1 de 1'), findsNothing);
  });

  testWidgets('size-only product lists every size in one block', (
    WidgetTester tester,
  ) async {
    await pumpDetail(tester, 'p-002');

    expect(text('Chamarra de cuero'), findsOneWidget);
    expect(text('S, M, L'), findsOneWidget);
    // M and L also appear in the movements card (their initial stock).
    for (final String size in <String>['S', 'M', 'L']) {
      expect(text(size), findsWidgets);
    }
    expect(text('Movimientos de stock'), findsOneWidget);
    expect(text('Agotado'), findsOneWidget);
    expect(text('Queda 1'), findsNWidgets(2));
    expect(text('Quedan 2'), findsOneWidget);
  });

  testWidgets('unknown product offers to retry', (WidgetTester tester) async {
    await pumpDetail(tester, 'missing');

    expect(text('No pudimos cargar el producto'), findsOneWidget);
    expect(text('Reintentar'), findsOneWidget);
    expect(text('Editar producto'), findsNothing);
  });
}
