import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/cubit/session_cubit.dart';
import '../features/cash_register/presentation/cubit/cash_register_cubit.dart';
import '../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../features/orders/presentation/cubit/orders_badge_cubit.dart';
import '../features/sales/presentation/cubit/cart_cubit.dart';
import 'di/dependency_injection.dart';
import 'router/app_router.dart';

/// Root widget: session-wide cubits, theme and router.
class CumaviPosApp extends StatefulWidget {
  const CumaviPosApp({super.key});

  @override
  State<CumaviPosApp> createState() => _CumaviPosAppState();
}

class _CumaviPosAppState extends State<CumaviPosApp> {
  final GoRouter _router = createAppRouter();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SessionCubit>(
          create: (_) => injector<SessionCubit>()..refresh(),
        ),
        BlocProvider<CartCubit>(create: (_) => injector<CartCubit>()),
        BlocProvider<CashRegisterCubit>(
          create: (_) => injector<CashRegisterCubit>(),
        ),
        BlocProvider<DashboardCubit>(create: (_) => injector<DashboardCubit>()),
        BlocProvider<OrdersBadgeCubit>(
          create: (_) => injector<OrdersBadgeCubit>()..load(),
        ),
      ],
      child: MaterialApp.router(
        onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: _router,
        locale: AppLocale.bolivianSpanish,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
