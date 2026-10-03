import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/cubit/categories_cubit.dart';
import 'package:cumavi_pos_mobile/features/catalog/presentation/screens/categories_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../helpers/load_app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  Future<void> pump(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      BlocProvider<CategoriesCubit>(
        create: (_) => injector<CategoriesCubit>(),
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: AppLocale.bolivianSpanish,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: CategoriesScreen(onBack: () {}),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  }

  testWidgets('lists the categories with their products', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    expect(find.text('Categorías'), findsWidgets);
    expect(find.text('Ropa'), findsOneWidget);
    expect(find.text('Calzado'), findsOneWidget);
    expect(find.text('Accesorios'), findsOneWidget);
    expect(find.text('Nueva categoría'), findsOneWidget);
  });

  testWidgets('creates a category and explains a taken name', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Nueva categoría'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ropa');
    await tester.pump();
    await tester.tap(find.text('Crear categoría'));
    await settle(tester);
    expect(
      find.text('Ya tienes una categoría con ese nombre.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Hogar');
    await tester.pump();
    await tester.tap(find.text('Crear categoría'));
    await settle(tester);

    expect(find.text('Hogar'), findsOneWidget);
    expect(find.text('Categoría creada'), findsOneWidget);
  });

  testWidgets('archives a category and restores it', (
    WidgetTester tester,
  ) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Opciones de Calzado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Archivar').last);
    await tester.pumpAndSettle();
    // Calzado has products, so the seller confirms.
    await tester.tap(find.widgetWithText(TextButton, 'Archivar'));
    await settle(tester);

    expect(find.text('Categoría archivada'), findsOneWidget);
    expect(find.text('ARCHIVADAS'), findsOneWidget);

    await tester.tap(find.text('Restaurar'));
    await settle(tester);

    expect(find.text('ARCHIVADAS'), findsNothing);
    expect(find.text('Calzado'), findsOneWidget);
  });
}
