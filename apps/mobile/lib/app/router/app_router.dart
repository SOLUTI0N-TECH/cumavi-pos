import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/cubit/registration_cubit.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/cubit/sign_in_cubit.dart';
import '../../features/auth/presentation/screens/business_profile_screen.dart';
import '../../features/auth/presentation/screens/business_ready_screen.dart';
import '../../features/auth/presentation/screens/phone_verification_screen.dart';
import '../../features/auth/presentation/screens/register_account_screen.dart';
import '../../features/auth/presentation/screens/sales_setup_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/cash_register/presentation/cubit/cash_close_cubit.dart';
import '../../features/cash_register/presentation/cubit/cash_register_cubit.dart';
import '../../features/cash_register/presentation/screens/close_cash_session_screen.dart';
import '../../features/catalog/domain/entities/product.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../../features/catalog/presentation/cubit/product_detail_cubit.dart';
import '../../features/catalog/presentation/cubit/product_form_cubit.dart';
import '../../features/catalog/presentation/screens/background_removal_screen.dart';
import '../../features/catalog/presentation/screens/inventory_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/catalog/presentation/screens/product_form_screen.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/sales/domain/entities/sale.dart';
import '../../features/sales/presentation/cubit/cart_cubit.dart';
import '../../features/sales/presentation/cubit/checkout_cubit.dart';
import '../../features/sales/presentation/cubit/print_receipt_cubit.dart';
import '../../features/sales/presentation/cubit/share_receipt_cubit.dart';
import '../../features/sales/presentation/screens/checkout_screen.dart';
import '../../features/sales/presentation/screens/product_search_screen.dart';
import '../../features/sales/presentation/screens/receipt_screen.dart';
import '../../features/sales/presentation/screens/sale_completed_screen.dart';
import '../../features/sales/presentation/screens/sales_tab_screen.dart';
import '../../features/shell/presentation/screens/main_shell_screen.dart';
import '../di/dependency_injection.dart';
import 'app_routes.dart';

/// Builds the app router.
///
/// Screen-scoped cubits are created by the route that owns the screen; flows
/// spanning several screens (registration, product form) get a [ShellRoute]
/// so one cubit serves every step.
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.signIn,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.signIn,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<SignInCubit>(
            create: (_) => injector<SignInCubit>(),
            child: SignInScreen(
              onSignedIn: () => context.go(AppRoutes.home),
              onCreateAccount: () => context.go(AppRoutes.register),
            ),
          );
        },
      ),
      _registrationFlow(),
      _mainShell(),
      ..._salesRoutes(),
      GoRoute(
        path: AppRoutes.productDetail,
        builder: (BuildContext context, GoRouterState state) {
          final String productId = state.pathParameters['id']!;
          return BlocProvider<ProductDetailCubit>(
            create: (_) =>
                injector<ProductDetailCubit>(param1: productId)..load(),
            child: Builder(
              builder: (BuildContext innerContext) => ProductDetailScreen(
                onBack: () => innerContext.pop(),
                onEdit: () async {
                  await innerContext.push<void>(
                    AppRoutes.productEditPath(productId),
                  );
                  if (innerContext.mounted) {
                    unawaited(innerContext.read<ProductDetailCubit>().load());
                    unawaited(innerContext.read<DashboardCubit>().load());
                  }
                },
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.cashRegisterClose,
        builder: (BuildContext context, GoRouterState state) {
          return BlocProvider<CashCloseCubit>(
            create: (_) => injector<CashCloseCubit>(),
            child: CloseCashSessionScreen(
              onBack: () => context.pop(),
              onClosed: () {
                context.read<CashRegisterCubit>().markAsClosed();
                unawaited(context.read<DashboardCubit>().load());
                context.go(AppRoutes.sales);
              },
            ),
          );
        },
      ),
      _productFormFlow(),
    ],
  );
}

/// Registration steps share a single [RegistrationCubit].
ShellRoute _registrationFlow() {
  return ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return BlocProvider<RegistrationCubit>(
        create: (_) => injector<RegistrationCubit>(),
        child: child,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) {
          return RegisterAccountScreen(
            onBack: () => context.go(AppRoutes.signIn),
            onCodeSent: () => context.go(AppRoutes.registerVerification),
            onAccountReady: () => context.go(AppRoutes.registerBusiness),
            onSignIn: () => context.go(AppRoutes.signIn),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registerVerification,
        builder: (BuildContext context, GoRouterState state) {
          return PhoneVerificationScreen(
            onBack: () => context.go(AppRoutes.register),
            onVerified: () => context.go(AppRoutes.registerBusiness),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registerBusiness,
        builder: (BuildContext context, GoRouterState state) {
          return BusinessProfileScreen(
            onBack: () => context.go(AppRoutes.register),
            onSaved: () => context.go(AppRoutes.registerSetup),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registerSetup,
        builder: (BuildContext context, GoRouterState state) {
          return SalesSetupScreen(
            onBack: () => context.go(AppRoutes.registerBusiness),
            onCompleted: () => context.go(AppRoutes.registerReady),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.registerReady,
        builder: (BuildContext context, GoRouterState state) {
          return BusinessReadyScreen(
            onCreateProduct: () async {
              await context.read<SessionCubit>().refresh();
              if (context.mounted) context.go(AppRoutes.productForm);
            },
            onOpenCashRegister: () async {
              await context.read<SessionCubit>().refresh();
              if (context.mounted) context.go(AppRoutes.sales);
            },
            onGoHome: () async {
              await context.read<SessionCubit>().refresh();
              if (context.mounted) context.go(AppRoutes.home);
            },
          );
        },
      ),
    ],
  );
}

/// The three tabs of the POS.
StatefulShellRoute _mainShell() {
  return StatefulShellRoute.indexedStack(
    builder:
        (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) {
          return MainShellScreen(navigationShell: navigationShell);
        },
    branches: <StatefulShellBranch>[
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.home,
            builder: (BuildContext context, GoRouterState state) {
              return DashboardScreen(
                onStartSale: () => context.go(AppRoutes.sales),
                onOpenInventory: () => context.go(AppRoutes.inventory),
              );
            },
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.sales,
            builder: (BuildContext context, GoRouterState state) {
              return BlocProvider<CatalogCubit>(
                create: (_) => injector<CatalogCubit>(),
                child: SalesTabScreen(
                  onOpenCatalog: ({String? categoryId}) => context.push(
                    Uri(
                      path: AppRoutes.salesCatalog,
                      queryParameters: categoryId == null
                          ? null
                          : <String, String>{'category': categoryId},
                    ).toString(),
                  ),
                  onCheckout: () => context.push(AppRoutes.salesCheckout),
                  onManageCashRegister: () =>
                      context.push(AppRoutes.cashRegisterClose),
                ),
              );
            },
          ),
        ],
      ),
      StatefulShellBranch(
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutes.inventory,
            builder: (BuildContext context, GoRouterState state) {
              return BlocProvider<CatalogCubit>(
                create: (_) => injector<CatalogCubit>(),
                child: Builder(
                  builder: (BuildContext innerContext) => InventoryScreen(
                    onCreateProduct: () async {
                      await innerContext.push<void>(AppRoutes.productForm);
                      if (innerContext.mounted) {
                        unawaited(innerContext.read<CatalogCubit>().load());
                      }
                    },
                    onOpenProduct: (Product product) async {
                      await innerContext.push<void>(
                        AppRoutes.productDetailPath(product.id),
                      );
                      // Stock or data may have changed while editing.
                      if (innerContext.mounted) {
                        unawaited(innerContext.read<CatalogCubit>().load());
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}

/// Sale screens pushed over the shell: catalog, checkout, result, receipt.
List<RouteBase> _salesRoutes() {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.salesCatalog,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<CatalogCubit>(
          create: (_) => injector<CatalogCubit>(),
          child: ProductSearchScreen(
            initialCategoryId: state.uri.queryParameters['category'],
            onBack: () => context.pop(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.salesCheckout,
      builder: (BuildContext context, GoRouterState state) {
        final CartCubit cartCubit = context.read<CartCubit>();
        return BlocProvider<CheckoutCubit>(
          create: (_) => injector<CheckoutCubit>(param1: cartCubit.state.cart),
          child: CheckoutScreen(
            saleNumberLabel: cartCubit.state.formattedSaleNumber,
            onBack: () => context.pop(),
            onCompleted: (Sale sale) {
              cartCubit.clear();
              unawaited(context.read<DashboardCubit>().load());
              context.go(AppRoutes.salesCompleted, extra: sale);
            },
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.salesCompleted,
      builder: (BuildContext context, GoRouterState state) {
        final Sale sale = state.extra! as Sale;
        return _withReceiptActions(
          SaleCompletedScreen(
            sale: sale,
            onNewSale: () async {
              await context.read<CartCubit>().startNewSale();
              if (context.mounted) context.go(AppRoutes.sales);
            },
            onGoHome: () => context.go(AppRoutes.home),
            onOpenReceipt: () =>
                context.push(AppRoutes.salesReceipt, extra: sale),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.salesReceipt,
      builder: (BuildContext context, GoRouterState state) {
        return _withReceiptActions(
          ReceiptScreen(
            sale: state.extra! as Sale,
            onBack: () => context.pop(),
          ),
        );
      },
    ),
  ];
}

/// Screens that show a receipt can print it and share it.
Widget _withReceiptActions(Widget screen) {
  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<PrintReceiptCubit>(
        create: (_) => injector<PrintReceiptCubit>(),
      ),
      BlocProvider<ShareReceiptCubit>(
        create: (_) => injector<ShareReceiptCubit>(),
      ),
    ],
    child: screen,
  );
}

/// The product form and its photo editor share a [ProductFormCubit].
ShellRoute _productFormFlow() {
  return ShellRoute(
    builder: (BuildContext context, GoRouterState state, Widget child) {
      return BlocProvider<ProductFormCubit>(
        create: (_) => injector<ProductFormCubit>(),
        child: child,
      );
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.productForm,
        builder: (BuildContext context, GoRouterState state) {
          return ProductFormScreen(
            onClose: () => context.go(AppRoutes.inventory),
            onAdjustPhoto: () => context.push(AppRoutes.productPhoto),
            onSaved: (_) {
              unawaited(context.read<DashboardCubit>().load());
              context.go(AppRoutes.inventory);
            },
          );
        },
      ),
      GoRoute(
        path: AppRoutes.productPhoto,
        builder: (BuildContext context, GoRouterState state) {
          return BackgroundRemovalScreen(onDone: () => context.pop());
        },
      ),
      GoRoute(
        path: AppRoutes.productEdit,
        builder: (BuildContext context, GoRouterState state) {
          final String productId = state.pathParameters['id']!;
          return ProductFormScreen(
            productId: productId,
            onClose: () => context.pop(),
            onAdjustPhoto: () =>
                context.push(AppRoutes.productEditPhotoPath(productId)),
            onSaved: (_) => context.pop(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.productEditPhoto,
        builder: (BuildContext context, GoRouterState state) {
          return BackgroundRemovalScreen(onDone: () => context.pop());
        },
      ),
    ],
  );
}
