import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/domain/payment_method.dart';
import '../../core/l10n/l10n.dart';
import '../../features/account/presentation/cubit/business_settings_cubit.dart';
import '../../features/account/presentation/cubit/sign_out_cubit.dart';
import '../../features/account/presentation/screens/business_settings_screen.dart';
import '../../features/account/presentation/screens/more_screen.dart';
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
import '../../features/catalog/data/datasources/catalog_seed_data.dart';
import '../../features/catalog/domain/entities/product.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../../features/catalog/presentation/cubit/categories_cubit.dart';
import '../../features/catalog/presentation/cubit/product_detail_cubit.dart';
import '../../features/catalog/presentation/cubit/product_form_cubit.dart';
import '../../features/catalog/presentation/scanner/barcode_camera.dart';
import '../../features/catalog/presentation/scanner/scanner_screen.dart';
import '../../features/catalog/presentation/screens/background_removal_screen.dart';
import '../../features/catalog/presentation/screens/categories_screen.dart';
import '../../features/catalog/presentation/screens/inventory_screen.dart';
import '../../features/catalog/presentation/screens/product_detail_screen.dart';
import '../../features/catalog/presentation/screens/product_form_screen.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inventory/presentation/cubit/adjust_stock_cubit.dart';
import '../../features/inventory/presentation/cubit/receive_stock_cubit.dart';
import '../../features/inventory/presentation/cubit/stock_movements_cubit.dart';
import '../../features/inventory/presentation/screens/adjust_stock_screen.dart';
import '../../features/inventory/presentation/screens/receive_stock_screen.dart';
import '../../features/inventory/presentation/screens/stock_movements_screen.dart';
import '../../features/online_store/domain/services/store_poster_service.dart';
import '../../features/online_store/presentation/cubit/online_store_cubit.dart';
import '../../features/online_store/presentation/screens/online_store_screen.dart';
import '../../features/online_store/presentation/screens/store_poster_screen.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/orders/domain/usecases/order_usecases.dart';
import '../../features/orders/presentation/cubit/import_order_cubit.dart';
import '../../features/orders/presentation/cubit/order_detail_cubit.dart';
import '../../features/orders/presentation/cubit/orders_inbox_cubit.dart';
import '../../features/orders/presentation/screens/import_order_screen.dart';
import '../../features/orders/presentation/screens/order_detail_screen.dart';
import '../../features/orders/presentation/screens/orders_inbox_screen.dart';
import '../../features/sales/domain/entities/receipt.dart';
import '../../features/sales/domain/entities/sale.dart';
import '../../features/sales/presentation/cubit/cart_cubit.dart';
import '../../features/sales/presentation/cubit/checkout_cubit.dart';
import '../../features/sales/presentation/cubit/print_receipt_cubit.dart';
import '../../features/sales/presentation/cubit/return_sale_cubit.dart';
import '../../features/sales/presentation/cubit/sale_detail_cubit.dart';
import '../../features/sales/presentation/cubit/sales_history_cubit.dart';
import '../../features/sales/presentation/cubit/share_receipt_cubit.dart';
import '../../features/sales/presentation/screens/checkout_screen.dart';
import '../../features/sales/presentation/screens/product_search_screen.dart';
import '../../features/sales/presentation/screens/receipt_screen.dart';
import '../../features/sales/presentation/screens/return_sale_screen.dart';
import '../../features/sales/presentation/screens/sale_completed_screen.dart';
import '../../features/sales/presentation/screens/sale_detail_screen.dart';
import '../../features/sales/presentation/screens/sales_history_screen.dart';
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
      ..._accountRoutes(),
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
                onReceiveStock: () => _moveStock(
                  innerContext,
                  AppRoutes.receiveStockPath(productId: productId),
                ),
                onAdjustStock: () => _moveStock(
                  innerContext,
                  AppRoutes.productAdjustStockPath(productId),
                ),
                onOpenMovements: () => innerContext.push(
                  AppRoutes.stockMovementsPath(productId: productId),
                  // The history's subtitle.
                  extra: innerContext
                      .read<ProductDetailCubit>()
                      .state
                      .product
                      ?.name,
                ),
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
              onOpenSales: () => context.push(AppRoutes.salesHistory),
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
      _scannerRoute(),
      ..._stockRoutes(),
      ..._orderRoutes(),
    ],
  );
}

/// Opens a stock screen from a product's detail and refreshes the detail
/// (and Inicio's low stock) when the seller comes back.
Future<void> _moveStock(BuildContext context, String location) async {
  await context.push<void>(location);
  if (context.mounted) {
    unawaited(context.read<ProductDetailCubit>().load());
    unawaited(context.read<DashboardCubit>().load());
  }
}

/// Leaves a screen that may be the first one (opened from a link).
void _leave(BuildContext context) =>
    context.canPop() ? context.pop() : context.go(AppRoutes.home);

/// Online orders (inbox, detail, charging, import by link) and the online
/// store settings with its QR poster.
List<RouteBase> _orderRoutes() {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.orders,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<OrdersInboxCubit>(
          create: (_) => injector<OrdersInboxCubit>(),
          child: OrdersInboxScreen(
            onBack: () => _leave(context),
            onOpenOrder: (Order order) =>
                context.push(AppRoutes.orderDetailPath(order.id)),
            onImport: () => context.push(AppRoutes.orderImport),
          ),
        );
      },
    ),
    // Also the target of `cumavipos://pos/orders/import?d=…`, the link in
    // the web's WhatsApp message (feature 13).
    GoRoute(
      path: AppRoutes.orderImport,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<ImportOrderCubit>(
          create: (_) => injector<ImportOrderCubit>(),
          child: ImportOrderScreen(
            initialLink: state.uri.queryParameters['d'],
            onClose: () => _leave(context),
            onImported: (Order order) =>
                context.pushReplacement(AppRoutes.orderDetailPath(order.id)),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderDetail,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<OrderDetailCubit>(
          create: (_) =>
              injector<OrderDetailCubit>(param1: state.pathParameters['id']),
          child: OrderDetailScreen(
            onBack: () => _leave(context),
            onCheckout: (OrderCheckout checkout) => context.push(
              AppRoutes.orderCheckoutPath(checkout.order.id),
              extra: checkout,
            ),
            onOpenSale: (String saleId) =>
                context.push(AppRoutes.saleDetailPath(saleId)),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderCheckout,
      builder: (BuildContext context, GoRouterState state) {
        final OrderCheckout checkout = state.extra! as OrderCheckout;
        final PaymentMethod method = checkout.order.paymentMethod;
        return BlocProvider<CheckoutCubit>(
          create: (_) => CheckoutCubit(
            registerSale: injector<CheckoutOrder>(param1: checkout.order.id),
            cart: checkout.cart,
            paymentMethod: method,
          ),
          child: CheckoutScreen(
            saleNumberLabel: context
                .read<CartCubit>()
                .state
                .formattedSaleNumber,
            onBack: () => context.pop(),
            onCompleted: (Sale sale) {
              unawaited(context.read<DashboardCubit>().load());
              unawaited(context.read<CartCubit>().loadSaleNumber());
              context.pushReplacement(
                AppRoutes.orderCompletedPath(checkout.order.id),
                extra: sale,
              );
            },
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.orderCompleted,
      builder: (BuildContext context, GoRouterState state) {
        final Sale sale = state.extra! as Sale;
        return _withReceiptActions(
          SaleCompletedScreen(
            sale: sale,
            primaryLabel: context.l10n.orderCompletedBackToOrder,
            onNewSale: () => context.pop(),
            onGoHome: () => context.go(AppRoutes.home),
            onOpenReceipt: () =>
                context.push(AppRoutes.salesReceipt, extra: sale),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.onlineStore,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<OnlineStoreCubit>(
          create: (_) => injector<OnlineStoreCubit>(),
          child: Builder(
            builder: (BuildContext innerContext) => OnlineStoreScreen(
              onBack: () => _leave(innerContext),
              onOpenPoster: () {
                final OnlineStoreCubit cubit = innerContext
                    .read<OnlineStoreCubit>();
                innerContext.push(
                  AppRoutes.onlineStorePoster,
                  extra: StorePoster(
                    businessName:
                        innerContext
                            .read<SessionCubit>()
                            .state
                            .business
                            ?.name ??
                        innerContext.l10n.commonDefaultBusinessName,
                    url: cubit.storeUrl ?? '',
                    tagline: cubit.state.saved?.tagline ?? '',
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.onlineStorePoster,
      builder: (BuildContext context, GoRouterState state) {
        return StorePosterScreen(
          poster: state.extra! as StorePoster,
          service: injector<StorePosterService>(),
          onBack: () => context.pop(),
        );
      },
    ),
  ];
}

/// Goods receipt, stock adjustment and the movements history.
List<RouteBase> _stockRoutes() {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.receiveStock,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<ReceiveStockCubit>(
          create: (_) => injector<ReceiveStockCubit>(),
          child: ReceiveStockScreen(
            initialProductId: state.uri.queryParameters['product'],
            onScan: () => _scan(context, ScanPurpose.find),
            onClose: () => context.pop(),
            onSaved: () => context.pop(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.productAdjustStock,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<AdjustStockCubit>(
          create: (_) =>
              injector<AdjustStockCubit>(param1: state.pathParameters['id']),
          child: AdjustStockScreen(
            onClose: () => context.pop(),
            onSaved: () => context.pop(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.stockMovements,
      builder: (BuildContext context, GoRouterState state) {
        final String? productId = state.uri.queryParameters['product'];
        return BlocProvider<StockMovementsCubit>(
          create: (_) => injector<StockMovementsCubit>(param1: productId),
          child: StockMovementsScreen(
            productName: state.extra as String?,
            onBack: () => context.pop(),
          ),
        );
      },
    ),
  ];
}

/// Opens the scanner; resolves with the code, or `null` if it was closed.
Future<String?> _scan(BuildContext context, ScanPurpose purpose) =>
    context.push<String>(
      Uri(
        path: AppRoutes.scan,
        queryParameters: <String, String>{'purpose': purpose.name},
      ).toString(),
    );

GoRoute _scannerRoute() {
  return GoRoute(
    path: AppRoutes.scan,
    builder: (BuildContext context, GoRouterState state) {
      return ScannerScreen(
        purpose:
            ScanPurpose.values
                .asNameMap()[state.uri.queryParameters['purpose']] ??
            ScanPurpose.sell,
        camera: injector<BarcodeCamera>(),
        // While the catalog is mocked, codes of the demo products.
        demoCodes: CatalogSeedData.demoScanCodes,
        onCode: (String code) => context.pop(code),
        onClose: () => context.pop(),
      );
    },
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
          return MainShellScreen(
            navigationShell: navigationShell,
            onOpenOrder: (String orderId) =>
                context.push(AppRoutes.orderDetailPath(orderId)),
          );
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
                onOpenMore: () => context.push(AppRoutes.more),
                onOpenSalesHistory: () => context.push(AppRoutes.salesHistory),
                onOpenOrders: () => context.push(AppRoutes.orders),
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
                  onScan: () => _scan(context, ScanPurpose.sell),
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
                    onManageCategories: () async {
                      await innerContext.push<void>(AppRoutes.categories);
                      // Names, order or archived categories may have changed.
                      if (innerContext.mounted) {
                        unawaited(innerContext.read<CatalogCubit>().load());
                      }
                    },
                    onScan: () => _scan(innerContext, ScanPurpose.find),
                    onReceiveStock: () async {
                      await innerContext.push<void>(AppRoutes.receiveStock);
                      if (innerContext.mounted) {
                        unawaited(innerContext.read<CatalogCubit>().load());
                        unawaited(innerContext.read<DashboardCubit>().load());
                      }
                    },
                    onCreateWithBarcode: (String barcode) async {
                      await innerContext.push<void>(
                        Uri(
                          path: AppRoutes.productForm,
                          queryParameters: <String, String>{'barcode': barcode},
                        ).toString(),
                      );
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
            onScan: () => _scan(context, ScanPurpose.sell),
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
      path: AppRoutes.salesHistory,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<SalesHistoryCubit>(
          create: (_) => injector<SalesHistoryCubit>(),
          child: SalesHistoryScreen(
            onBack: () => context.pop(),
            onOpenSale: (Sale sale) =>
                context.push(AppRoutes.saleDetailPath(sale.id)),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.saleDetail,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<SaleDetailCubit>(
          create: (_) =>
              injector<SaleDetailCubit>(param1: state.pathParameters['id']),
          child: SaleDetailScreen(
            onBack: () => context.pop(),
            onOpenReceipt: (Receipt receipt) =>
                context.push(AppRoutes.salesReceipt, extra: receipt),
            onReturn: () async {
              await context.push<void>(
                AppRoutes.saleReturnPath(state.pathParameters['id']!),
              );
              // Inicio shows net sales: a refund changes them.
              if (context.mounted) {
                unawaited(context.read<DashboardCubit>().load());
              }
            },
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.saleReturn,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<ReturnSaleCubit>(
          create: (_) =>
              injector<ReturnSaleCubit>(param1: state.pathParameters['id']),
          child: ReturnSaleScreen(
            onClose: () => context.pop(),
            onSaved: () => context.pop(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.salesReceipt,
      builder: (BuildContext context, GoRouterState state) {
        return _withReceiptActions(
          ReceiptScreen(
            // A sale's receipt, or a return's (built by the sale detail).
            receipt: switch (state.extra) {
              final Receipt receipt => receipt,
              final Object? sale => Receipt(sale: sale! as Sale),
            },
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

/// The "Más" hub, the business settings and the categories.
List<RouteBase> _accountRoutes() {
  return <RouteBase>[
    GoRoute(
      path: AppRoutes.categories,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<CategoriesCubit>(
          create: (_) => injector<CategoriesCubit>(),
          child: CategoriesScreen(onBack: () => context.pop()),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.more,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<SignOutCubit>(
          create: (_) => injector<SignOutCubit>(),
          child: MoreScreen(
            onBack: () => context.pop(),
            onEditBusiness: () => context.push(AppRoutes.moreBusiness),
            onOpenCategories: () => context.push(AppRoutes.categories),
            onOpenSalesHistory: () => context.push(AppRoutes.salesHistory),
            onOpenStockMovements: () =>
                context.push(AppRoutes.stockMovementsPath()),
            onOpenOrders: () => context.push(AppRoutes.orders),
            onOpenOnlineStore: () => context.push(AppRoutes.onlineStore),
            onSignedOut: () async {
              context.read<CartCubit>().clear();
              await context.read<SessionCubit>().refresh();
              if (context.mounted) context.go(AppRoutes.signIn);
            },
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.moreBusiness,
      redirect: (BuildContext context, GoRouterState state) =>
          context.read<SessionCubit>().state.business == null
          ? AppRoutes.more
          : null,
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<BusinessSettingsCubit>(
          create: (_) => injector<BusinessSettingsCubit>(
            param1: context.read<SessionCubit>().state.business,
          ),
          child: BusinessSettingsScreen(
            onBack: () => context.pop(),
            onSaved: () async {
              unawaited(context.read<DashboardCubit>().load());
              await context.read<SessionCubit>().refresh();
              if (context.mounted) context.pop();
            },
          ),
        );
      },
    ),
  ];
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
            initialBarcode: state.uri.queryParameters['barcode'],
            onScanBarcode: () => _scan(context, ScanPurpose.assign),
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
            onScanBarcode: () => _scan(context, ScanPurpose.assign),
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
