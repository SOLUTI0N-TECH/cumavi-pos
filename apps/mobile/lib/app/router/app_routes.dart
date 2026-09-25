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
  static const String cashRegisterClose = '/cash-register/close';
  static const String productForm = '/inventory/new';
  static const String productPhoto = '/inventory/new/photo';
  static const String productDetail = '/inventory/product/:id';
  static const String productEdit = '/inventory/product/:id/edit';
  static const String productEditPhoto = '/inventory/product/:id/edit/photo';

  static String productDetailPath(String productId) =>
      '/inventory/product/$productId';

  static String productEditPath(String productId) =>
      '${productDetailPath(productId)}/edit';

  static String productEditPhotoPath(String productId) =>
      '${productEditPath(productId)}/photo';
}
