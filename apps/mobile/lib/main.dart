import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/di/dependency_injection.dart';
import 'core/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Spanish month and weekday names used across the app.
  initializeDateFormatting('es');

  // Camera, Bluetooth and sharing plugins only exist on phones; elsewhere
  // (desktop previews) the demo implementations keep every flow usable.
  configureDependencies(
    deviceServices: switch (defaultTargetPlatform) {
      TargetPlatform.android ||
      TargetPlatform.iOS when !kIsWeb => DeviceServices.native,
      _ => DeviceServices.demo,
    },
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CumaviPosApp());
}
