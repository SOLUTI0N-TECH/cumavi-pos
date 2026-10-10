/// Every route path and name of the app in one place.
abstract final class AppRoutes {
  // Auth.
  static const String signIn = '/sign-in';
  static const String register = '/register';
  static const String registerVerification = '/register/verification';
  static const String registerBusiness = '/register/business';
  static const String registerSetup = '/register/setup';
  static const String registerReady = '/register/ready';

  // Shell branches.
  static const String home = '/home';
  static const String sales = '/sales';
  static const String inventory = '/inventory';

  // Pushed over the shell.
  static const String salesCatalog = '/sales/catalog';
  static const String salesCheckout = '/sales/checkout';
  static const String salesCompleted = '/sales/completed';
  static const String salesReceipt = '/sales/receipt';
  static const String salesHistory = '/sales/history';
  static const String saleDetail = '/sales/history/:id';
  static const String saleReturn = '/sales/history/:id/return';
  static const String cashRegisterClose = '/cash-register/close';
  static const String more = '/more';
  static const String moreBusiness = '/more/business';
  static const String categories = '/categories';
  static const String scan = '/scan';
  static const String orders = '/orders';
  static const String orderImport = '/orders/import';
  static const String orderDetail = '/orders/:id';
  static const String orderCheckout = '/orders/:id/checkout';
  static const String orderCompleted = '/orders/:id/completed';
  static const String onlineStore = '/online-store';
  static const String onlineStorePoster = '/online-store/poster';
  static const String productForm = '/inventory/new';
  static const String productPhoto = '/inventory/new/photo';
  static const String productDetail = '/inventory/product/:id';
  static const String productEdit = '/inventory/product/:id/edit';
  static const String productEditPhoto = '/inventory/product/:id/edit/photo';
  static const String productAdjustStock = '/inventory/product/:id/adjust';
  static const String receiveStock = '/inventory/receive';
  static const String stockMovements = '/inventory/movements';

  static String saleDetailPath(String saleId) => '/sales/history/$saleId';

  static String orderDetailPath(String orderId) => '/orders/$orderId';

  static String orderCheckoutPath(String orderId) =>
      '${orderDetailPath(orderId)}/checkout';

  static String orderCompletedPath(String orderId) =>
      '${orderDetailPath(orderId)}/completed';

  static String saleReturnPath(String saleId) =>
      '${saleDetailPath(saleId)}/return';

  static String productDetailPath(String productId) =>
      '/inventory/product/$productId';

  static String productEditPath(String productId) =>
      '${productDetailPath(productId)}/edit';

  static String productAdjustStockPath(String productId) =>
      '${productDetailPath(productId)}/adjust';

  static String receiveStockPath({String? productId}) => Uri(
    path: receiveStock,
    queryParameters: productId == null
        ? null
        : <String, String>{'product': productId},
  ).toString();

  static String stockMovementsPath({String? productId}) => Uri(
    path: stockMovements,
    queryParameters: productId == null
        ? null
        : <String, String>{'product': productId},
  ).toString();

  static String productEditPhotoPath(String productId) =>
      '${productEditPath(productId)}/photo';
}
