import 'package:cumavi_pos_mobile/app/di/dependency_injection.dart';
import 'package:cumavi_pos_mobile/core/l10n/l10n.dart';
import 'package:cumavi_pos_mobile/core/theme/app_theme.dart';
import 'package:cumavi_pos_mobile/core/widgets/app_image.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/cubit/registration_cubit.dart';
import 'package:cumavi_pos_mobile/features/auth/presentation/screens/business_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../helpers/load_app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  setUp(() async {
    await GetIt.instance.reset();
    configureDependencies(deviceServices: DeviceServices.demo);
  });

  testWidgets('tapping the logo offers camera or gallery and shows the photo', (
    WidgetTester tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1170, 2532)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final RegistrationCubit cubit = injector<RegistrationCubit>();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: AppLocale.bolivianSpanish,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: BlocProvider<RegistrationCubit>.value(
          value: cubit,
          child: BusinessProfileScreen(onBack: () {}, onSaved: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.photo_camera_outlined));
    await tester.pumpAndSettle();
    // The sheet speaks about the logo, not a product photo.
    expect(find.text('Tomar foto'), findsOneWidget);
    expect(find.text('Elegir de la galería'), findsOneWidget);
    expect(
      find.text('Aparece en tus comprobantes y en tu catálogo.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Elegir de la galería'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(cubit.state.logoPath, isNotNull);
    expect(find.byType(AppImage), findsOneWidget);
    expect(find.text('Listo. Toca para cambiarlo.'), findsOneWidget);
    await cubit.close();
  });
}
