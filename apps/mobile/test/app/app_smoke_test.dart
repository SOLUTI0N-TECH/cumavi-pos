import 'package:cumavi_pos_mobile/app/app.dart';
import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/load_app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    await initializeDateFormatting('es');
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  testWidgets('the app starts on the sign-in screen', (
    WidgetTester tester,
  ) async {
    // Phone-sized surface (390x844 at 3x), the size the screens are built for.
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const CumaviPosApp());
    await tester.pump();

    expect(find.text('Hola de nuevo'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsOneWidget);
  });

  testWidgets('signs in with a phone and the demo SMS code', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Future<void> settle() async {
      // Past the mocks' simulated latency, then until animations end.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(const CumaviPosApp());
    await tester.pump();

    await tester.tap(find.text('Teléfono'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '71234567');
    await tester.pump();
    await tester.tap(find.text('Enviar código'));
    await settle();

    // No SMS is sent: the screen shows the code and fills it on tap.
    expect(find.text('Usa el código 123456'), findsOneWidget);
    await tester.tap(find.text('Usar'));
    await tester.pump();
    await tester.tap(find.text('Iniciar sesión'));
    await settle();

    expect(find.text('Hola, Carla'), findsOneWidget);
  });
}
