import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/catalog_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart_line.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/cubit/cart_cubit.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/screens/product_search_screen.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/view_data/variant_selection.dart';
import 'package:cumavi_pos_mobile/features/sales/presentation/widgets/variant_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../helpers/load_app_fonts.dart';

/// Selling from the catalog: products with variants ask which one first.
void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<CartCubit> pumpCatalog(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final CartCubit cartCubit = injector<CartCubit>();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider<StateStreamableSource<Object?>>>[
          BlocProvider<CartCubit>.value(value: cartCubit),
          BlocProvider<CatalogCubit>(create: (_) => injector<CatalogCubit>()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: AppLocale.bolivianSpanish,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: ProductSearchScreen(onBack: () {}),
        ),
      ),
    );
    // The mocks answer after a simulated latency; advance the fake clock past
    // it before waiting for animations to finish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    return cartCubit;
  }

  Future<void> openPicker(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Elegir variante de Zapatillas urbanas'));
    await tester.pumpAndSettle();
  }

  Finder chip(String value) => find.widgetWithText(VariantValueChip, value);

  VariantValueChip chipOf(WidgetTester tester, String value) =>
      tester.widget<VariantValueChip>(chip(value));

  testWidgets('adds the chosen color and size with its quantity', (
    WidgetTester tester,
  ) async {
    final CartCubit cartCubit = await pumpCatalog(tester);

    expect(find.text('15 variantes'), findsOneWidget);
    await openPicker(tester);

    expect(find.text('Elige la variante'), findsOneWidget);
    expect(find.text('Falta elegir Color'), findsOneWidget);
    expect(find.text('Agregar · Bs 450,00'), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Agregar · Bs 450,00'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );

    await tester.tap(chip('Azul'));
    await tester.pumpAndSettle();

    expect(find.text('Falta elegir Talla'), findsOneWidget);
    // Azul has no 38 nor 42 left; 42 has no stock in any color.
    for (final String size in <String>['38', '42']) {
      expect(chipOf(tester, size).availability.isAvailable, isFalse);
    }
    expect(chipOf(tester, '38').isEnabled, isTrue);
    expect(chipOf(tester, '42').isEnabled, isFalse);
    for (final String size in <String>['39', '40', '41']) {
      expect(chipOf(tester, size).availability.isAvailable, isTrue);
    }

    await tester.tap(chip('40'));
    await tester.pumpAndSettle();
    expect(find.text('Quedan 2'), findsOneWidget);

    // The stepper stops at the 2 units of Azul · 40.
    for (int tap = 0; tap < 3; tap++) {
      await tester.tap(find.byTooltip('Sumar uno'));
      await tester.pump();
    }
    await tester.tap(find.text('Agregar · Bs 900,00'));
    await tester.pumpAndSettle();

    final List<CartLine> lines = cartCubit.state.cart.lines;
    expect(lines, hasLength(1));
    expect(lines.single.key, 'p-001#azul/40');
    expect(lines.single.variant?.label, 'Azul · 40');
    expect(lines.single.quantity, 2);
    expect(
      find.text('Se agregaron 2 a la venta: Zapatillas urbanas (Azul · 40)'),
      findsOneWidget,
    );
    expect(find.text('Elige la variante'), findsNothing);
  });

  testWidgets('counts the units already in the cart', (
    WidgetTester tester,
  ) async {
    final CartCubit cartCubit = await pumpCatalog(tester);

    await openPicker(tester);
    await tester.tap(chip('Azul'));
    await tester.pumpAndSettle();
    await tester.tap(chip('39'));
    await tester.pumpAndSettle();
    // Azul · 39 has a single unit.
    expect(find.text('Queda 1'), findsOneWidget);
    await tester.tap(find.text('Agregar · Bs 450,00'));
    await tester.pumpAndSettle();
    expect(cartCubit.state.cart.quantityOf('p-001'), 1);

    await openPicker(tester);
    await tester.tap(chip('Azul'));
    await tester.pumpAndSettle();

    expect(chipOf(tester, '39').availability.isAvailable, isFalse);

    // Choosing the size that is all in the cart drops the color instead of
    // getting stuck.
    await tester.tap(chip('39'));
    await tester.pumpAndSettle();
    expect(find.text('Falta elegir Color'), findsOneWidget);
    expect(
      chipOf(tester, 'Azul').availability,
      VariantValueAvailability.unavailableWithSelection,
    );
    expect(chipOf(tester, 'Rojo').availability.isAvailable, isTrue);
  });

  testWidgets('dismissing the picker adds nothing', (
    WidgetTester tester,
  ) async {
    final CartCubit cartCubit = await pumpCatalog(tester);

    await openPicker(tester);
    await tester.tap(find.byTooltip('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.text('Elige la variante'), findsNothing);
    expect(cartCubit.state.cart.isEmpty, isTrue);
  });

  testWidgets('a product without variants is added with one tap', (
    WidgetTester tester,
  ) async {
    final CartCubit cartCubit = await pumpCatalog(tester);

    final Finder addSunglasses = find.byTooltip(
      'Agregar Lentes de sol clásicos',
    );
    await tester.scrollUntilVisible(
      addSunglasses,
      200,
      scrollable: find.descendant(
        of: find.byType(GridView),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.ensureVisible(addSunglasses);
    await tester.pumpAndSettle();
    await tester.tap(addSunglasses);
    await tester.pumpAndSettle();

    expect(find.byType(VariantPickerSheet), findsNothing);
    expect(cartCubit.state.cart.quantityOfLine('p-006'), 1);
  });
}
