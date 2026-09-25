import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/core/widgets/quantity_stepper.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/product_form_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/product_form_screen.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/widgets/variant_list_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../../helpers/load_app_fonts.dart';

/// Renders the product form at phone size with the demo catalog, to create a
/// product and to edit one with variants. Overflows fail the test, like in
/// `screens_render_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pumpForm(
    WidgetTester tester, {
    String? productId,
    Size size = const Size(1170, 2532),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: AppLocale.bolivianSpanish,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider<ProductFormCubit>(
          create: (_) => injector<ProductFormCubit>(),
          child: ProductFormScreen(
            productId: productId,
            onClose: () {},
            onSaved: (_) {},
            onAdjustPhoto: () {},
          ),
        ),
      ),
    );
    // The mocks answer after a simulated latency; advance the fake clock past
    // it before waiting for animations to finish.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  /// The form's vertical list (the photo strip scrolls sideways inside it).
  Finder formList() => find.byType(Scrollable).first;

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(finder, 300, scrollable: formList());
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  Future<void> tapInForm(WidgetTester tester, Finder finder) async {
    await scrollTo(tester, finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Finder inVariantList(Finder matching) =>
      find.descendant(of: find.byType(VariantListEditor), matching: matching);

  VoidCallback? saveAction(WidgetTester tester, String label) => tester
      .widget<FilledButton>(find.widgetWithText(FilledButton, label))
      .onPressed;

  testWidgets('create mode shows the empty form', (WidgetTester tester) async {
    await pumpForm(tester);

    expect(find.text('Nuevo producto'), findsOneWidget);
    expect(find.text('Quitar fondo'), findsOneWidget);
    expect(find.text('Más fotos'), findsOneWidget);
    expect(saveAction(tester, 'Guardar producto'), isNull);

    await scrollTo(tester, find.text('Agregar variantes (talla, color…)'));
    expect(find.text('Descripción (opcional)'), findsOneWidget);
    // A simple product: one stock and no variants yet.
    expect(find.byType(QuantityStepper), findsOneWidget);
    expect(find.byType(VariantListEditor), findsNothing);
  });

  testWidgets('a Talla type with S and M gives a stock row per size', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester);

    await tapInForm(tester, find.text('Agregar variantes (talla, color…)'));
    await tester.tap(find.text('Talla'));
    await tester.pumpAndSettle();

    // Until the type has values there is nothing to save.
    const String emptyHint =
        'Agrega al menos un valor para crear las variantes.';
    await scrollTo(tester, find.text(emptyHint));
    expect(find.byType(VariantListEditor), findsNothing);
    expect(find.byType(QuantityStepper), findsNothing);

    await tapInForm(tester, find.text('S'));
    await tapInForm(tester, find.text('M'));

    expect(find.text(emptyHint), findsNothing);
    await scrollTo(tester, find.byType(VariantListEditor));
    expect(find.text('2 variantes'), findsOneWidget);
    expect(inVariantList(find.byType(QuantityStepper)), findsNWidgets(2));
    // The single stock gives way to the one of each variant.
    expect(find.byType(QuantityStepper), findsNWidgets(2));

    // A used suggestion disappears (M is left as its chip and its row);
    // a typed value is added on "done".
    expect(find.text('M'), findsNWidgets(2));
    expect(find.text('XL'), findsOneWidget);
    await scrollTo(
      tester,
      find.widgetWithText(TextField, 'Nuevo valor de Talla'),
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Nuevo valor de Talla'),
      'XXL',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    await scrollTo(tester, find.byType(VariantListEditor));
    expect(find.text('3 variantes'), findsOneWidget);
    expect(inVariantList(find.text('XXL')), findsOneWidget);
  });

  testWidgets('edit mode prefills p-001 and groups its 15 variants by color', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, productId: 'p-001');

    expect(find.text('Editar producto'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Zapatillas urbanas'),
      findsOneWidget,
    );
    await scrollTo(tester, find.widgetWithText(TextField, '450,00'));
    expect(find.widgetWithText(TextField, '290,00'), findsOneWidget);
    expect(saveAction(tester, 'Guardar cambios'), isNotNull);

    await scrollTo(tester, find.byType(VariantListEditor));
    expect(find.text('15 variantes'), findsOneWidget);
    expect(find.text('12 unidades'), findsOneWidget);
    expect(inVariantList(find.byType(QuantityStepper)), findsNWidgets(15));
    for (final String color in <String>['Rojo', 'Azul', 'Negro']) {
      expect(inVariantList(find.text(color)), findsOneWidget);
    }
    // Rows show the size; the color is the group's title.
    expect(inVariantList(find.text('40')), findsNWidgets(3));
  });

  testWidgets('choosing a photo for a color applies it to all its sizes', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, productId: 'p-001');

    final Finder azul39 = find.byTooltip('Foto de Azul · 39');
    await tapInForm(tester, azul39);
    expect(find.text('Foto de la variante'), findsOneWidget);
    expect(find.text('Usar en todas las variantes Azul'), findsOneWidget);

    // The main (red) photo, for every blue size.
    await tester.tap(find.text('Principal'));
    await tester.pumpAndSettle();

    final ProductFormCubit cubit = BlocProvider.of<ProductFormCubit>(
      tester.element(find.byType(ProductFormScreen)),
    );
    final Iterable<String?> blueImages = cubit.state.variants
        .where(
          (ProductVariant variant) => variant.optionValues['Color'] == 'Azul',
        )
        .map((ProductVariant variant) => variant.imageId);
    expect(blueImages, everyElement(isNull));
  });

  testWidgets('the whole edit form fits a narrow phone', (
    WidgetTester tester,
  ) async {
    await pumpForm(tester, productId: 'p-001', size: const Size(1080, 2220));

    // Building every row on the way down reports any overflow.
    await scrollTo(tester, find.byTooltip('Foto de Negro · 42'));
    expect(tester.takeException(), isNull);
  });
}
