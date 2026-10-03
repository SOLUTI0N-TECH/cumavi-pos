import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/features/account/presentation/cubit/business_settings_cubit.dart';
import 'package:cumavi_pos_mobile/features/account/presentation/cubit/sign_out_cubit.dart';
import 'package:cumavi_pos_mobile/features/account/presentation/screens/business_settings_screen.dart';
import 'package:cumavi_pos_mobile/features/account/presentation/screens/more_screen.dart';
import 'package:cumavi_pos_mobile/features/auth/data/datasources/in_memory_session_store.dart';
import 'package:cumavi_pos_mobile/features/auth/domain/repositories/session_repository.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/cubit/session_cubit.dart';
import 'package:cumavi_pos_mobile/features/cash_register/presentation/cubit/cash_register_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../helpers/load_app_fonts.dart';

typedef AnyBlocProvider = BlocProvider<StateStreamableSource<Object?>>;

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
    PackageInfo.setMockInitialValues(
      appName: 'Cumavi POS',
      packageName: 'bo.solutiontech.cumavi_pos_mobile',
      version: '0.1.0',
      buildNumber: '1',
      buildSignature: '',
    );
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

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <AnyBlocProvider>[
          BlocProvider<SessionCubit>(
            create: (_) => injector<SessionCubit>()..refresh(),
          ),
          BlocProvider<CashRegisterCubit>(
            create: (_) => injector<CashRegisterCubit>()..load(),
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
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('"Más" shows the account and the business', (
    WidgetTester tester,
  ) async {
    await pump(
      tester,
      MoreScreen(
        onBack: () {},
        onEditBusiness: () {},
        onOpenCategories: () {},
        onOpenSalesHistory: () {},
        onOpenStockMovements: () {},
        onSignedOut: () {},
      ),
      providers: <AnyBlocProvider>[
        BlocProvider<SignOutCubit>(create: (_) => injector<SignOutCubit>()),
      ],
    );

    expect(find.text('Más'), findsOneWidget);
    expect(find.text('Carla Mamani'), findsOneWidget);
    expect(find.text('+591 76543210'), findsOneWidget);
    expect(find.text('Ingresaste con teléfono'), findsOneWidget);
    expect(find.text('Illimani Store'), findsOneWidget);
    expect(find.text('NIT 1020304050'), findsOneWidget);
    expect(find.text('Cumavi POS · versión 0.1.0 (1)'), findsOneWidget);
  });

  testWidgets('signing out asks first, warns about the open drawer and '
      'keeps the store', (WidgetTester tester) async {
    bool signedOut = false;
    await pump(
      tester,
      MoreScreen(
        onBack: () {},
        onEditBusiness: () {},
        onOpenCategories: () {},
        onOpenSalesHistory: () {},
        onOpenStockMovements: () {},
        onSignedOut: () => signedOut = true,
      ),
      providers: <AnyBlocProvider>[
        BlocProvider<SignOutCubit>(create: (_) => injector<SignOutCubit>()),
      ],
    );

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    // The demo store has the cash drawer open.
    expect(
      find.text(
        'La caja queda abierta. Podrás cerrarla cuando vuelvas a ingresar.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Cerrar sesión').last);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final SessionRepository session = injector<SessionRepository>();
    expect(signedOut, isTrue);
    expect(session.isSignedIn, isFalse);
    expect(session.currentBusiness, InMemorySessionStore.demoBusiness);
  });

  testWidgets('business settings save the new data', (
    WidgetTester tester,
  ) async {
    bool saved = false;
    await pump(
      tester,
      BusinessSettingsScreen(onBack: () {}, onSaved: () => saved = true),
      providers: <AnyBlocProvider>[
        BlocProvider<BusinessSettingsCubit>(
          create: (_) => injector<BusinessSettingsCubit>(
            param1: InMemorySessionStore.demoBusiness,
          ),
        ),
      ],
    );

    expect(find.text('Datos del negocio'), findsOneWidget);
    expect(find.text('1020304050'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Illimani Store'),
      'Tienda Illimani',
    );
    await tester.pump();
    await tester.tap(find.text('Guardar cambios'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(saved, isTrue);
    expect(
      injector<SessionRepository>().currentBusiness?.name,
      'Tienda Illimani',
    );
  });
}
