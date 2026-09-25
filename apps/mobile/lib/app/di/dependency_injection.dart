import 'package:get_it/get_it.dart';

import '../../core/l10n/l10n.dart';
import '../../features/auth/data/datasources/in_memory_session_store.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/session_repository.dart';
import '../../features/auth/domain/usecases/get_session_info.dart';
import '../../features/auth/domain/usecases/request_phone_code.dart';
import '../../features/auth/domain/usecases/request_sign_in_code.dart';
import '../../features/auth/domain/usecases/save_business_profile.dart';
import '../../features/auth/domain/usecases/save_sales_setup.dart';
import '../../features/auth/domain/usecases/sign_in_with_email.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_in_with_phone.dart';
import '../../features/auth/domain/usecases/verify_phone_code.dart';
import '../../features/auth/presentation/cubit/registration_cubit.dart';
import '../../features/auth/presentation/cubit/session_cubit.dart';
import '../../features/auth/presentation/cubit/sign_in_cubit.dart';
import '../../features/cash_register/data/datasources/cash_register_data_source.dart';
import '../../features/cash_register/data/datasources/in_memory_cash_register_data_source.dart';
import '../../features/cash_register/data/repositories/cash_register_repository_impl.dart';
import '../../features/cash_register/domain/repositories/cash_register_repository.dart';
import '../../features/cash_register/domain/usecases/close_cash_session.dart';
import '../../features/cash_register/domain/usecases/get_cash_close_summary.dart';
import '../../features/cash_register/domain/usecases/get_current_cash_session.dart';
import '../../features/cash_register/domain/usecases/open_cash_session.dart';
import '../../features/cash_register/presentation/cubit/cash_close_cubit.dart';
import '../../features/cash_register/presentation/cubit/cash_register_cubit.dart';
import '../../features/catalog/data/datasources/in_memory_product_data_source.dart';
import '../../features/catalog/data/datasources/product_data_source.dart';
import '../../features/catalog/data/repositories/product_repository_impl.dart';
import '../../features/catalog/data/services/demo_photo_capturer.dart';
import '../../features/catalog/data/services/image_picker_photo_capturer.dart';
import '../../features/catalog/data/services/mock_image_background_remover.dart';
import '../../features/catalog/data/services/on_device_background_remover.dart';
import '../../features/catalog/domain/repositories/product_repository.dart';
import '../../features/catalog/domain/services/image_background_remover.dart';
import '../../features/catalog/domain/services/photo_capturer.dart';
import '../../features/catalog/domain/usecases/capture_product_photo.dart';
import '../../features/catalog/domain/usecases/create_product.dart';
import '../../features/catalog/domain/usecases/get_categories.dart';
import '../../features/catalog/domain/usecases/get_low_stock_products.dart';
import '../../features/catalog/domain/usecases/get_product.dart';
import '../../features/catalog/domain/usecases/get_products.dart';
import '../../features/catalog/domain/usecases/remove_photo_background.dart';
import '../../features/catalog/domain/usecases/update_product.dart';
import '../../features/catalog/presentation/cubit/catalog_cubit.dart';
import '../../features/catalog/presentation/cubit/product_detail_cubit.dart';
import '../../features/catalog/presentation/cubit/product_form_cubit.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_snapshot.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/sales/data/datasources/in_memory_sales_data_source.dart';
import '../../features/sales/data/datasources/sales_data_source.dart';
import '../../features/sales/data/repositories/sales_repository_impl.dart';
import '../../features/sales/data/services/bluetooth_receipt_printer.dart';
import '../../features/sales/data/services/demo_receipt_services.dart';
import '../../features/sales/data/services/device_receipt_sharer.dart';
import '../../features/sales/data/services/escpos_receipt_encoder.dart';
import '../../features/sales/data/services/receipt_document_renderer.dart';
import '../../features/sales/data/services/receipt_text_builder.dart';
import '../../features/sales/domain/entities/cart.dart';
import '../../features/sales/domain/repositories/sales_repository.dart';
import '../../features/sales/domain/services/receipt_printer.dart';
import '../../features/sales/domain/services/receipt_sharer.dart';
import '../../features/sales/domain/usecases/get_daily_sales_summary.dart';
import '../../features/sales/domain/usecases/get_next_sale_number.dart';
import '../../features/sales/domain/usecases/get_paired_printers.dart';
import '../../features/sales/domain/usecases/print_receipt.dart';
import '../../features/sales/domain/usecases/register_sale.dart';
import '../../features/sales/domain/usecases/share_receipt.dart';
import '../../features/sales/presentation/cubit/cart_cubit.dart';
import '../../features/sales/presentation/cubit/checkout_cubit.dart';
import '../../features/sales/presentation/cubit/print_receipt_cubit.dart';
import '../../features/sales/presentation/cubit/share_receipt_cubit.dart';

/// Service locator of the app.
final GetIt injector = GetIt.instance;

/// Which implementation of the device services (camera, background
/// removal, printer, sharing) the app uses.
enum DeviceServices {
  /// Real plugins. Android and iOS.
  native,

  /// Stand-ins that need no hardware. Tests, desktop and web.
  demo,
}

/// Registers every dependency.
///
/// Data sources are singletons because the mocks hold the state a backend
/// would hold; use cases are stateless singletons; cubits are factories,
/// except the ones that must survive navigation ([CartCubit],
/// [CashRegisterCubit]...).
void configureDependencies({
  DeviceServices deviceServices = DeviceServices.native,
}) {
  _registerLocalizations();
  _registerDataSources();
  _registerDeviceServices(deviceServices);
  _registerRepositories();
  _registerUseCases();
  _registerCubits();
}

/// Texts produced away from the widget tree (printed and shared receipts).
void _registerLocalizations() {
  injector
    ..registerLazySingleton<AppLocalizations>(
      () => lookupAppLocalizations(AppLocale.bolivianSpanish),
    )
    ..registerLazySingleton<ReceiptTextBuilder>(
      () => ReceiptTextBuilder(injector<AppLocalizations>()),
    );
}

void _registerDataSources() {
  injector
    ..registerLazySingleton<SessionRepository>(InMemorySessionStore.new)
    ..registerLazySingleton<ProductDataSource>(InMemoryProductDataSource.new)
    ..registerLazySingleton<SalesDataSource>(InMemorySalesDataSource.new)
    ..registerLazySingleton<CashRegisterDataSource>(
      InMemoryCashRegisterDataSource.new,
    );
}

void _registerDeviceServices(DeviceServices deviceServices) {
  switch (deviceServices) {
    case DeviceServices.native:
      injector
        ..registerLazySingleton<PhotoCapturer>(ImagePickerPhotoCapturer.new)
        ..registerLazySingleton<ImageBackgroundRemover>(
          OnDeviceBackgroundRemover.new,
        )
        ..registerLazySingleton<ReceiptPrinter>(
          () => BluetoothReceiptPrinter(
            encoder: EscPosReceiptEncoder(injector<AppLocalizations>()),
          ),
        )
        ..registerLazySingleton<ReceiptSharer>(
          () => DeviceReceiptSharer(
            renderer: ReceiptDocumentRenderer(injector<AppLocalizations>()),
            textBuilder: injector<ReceiptTextBuilder>(),
          ),
        );
    case DeviceServices.demo:
      injector
        ..registerLazySingleton<PhotoCapturer>(DemoPhotoCapturer.new)
        ..registerLazySingleton<ImageBackgroundRemover>(
          MockImageBackgroundRemover.new,
        )
        ..registerLazySingleton<ReceiptPrinter>(DemoReceiptPrinter.new)
        ..registerLazySingleton<ReceiptSharer>(DemoReceiptSharer.new);
  }
}

void _registerRepositories() {
  injector
    ..registerLazySingleton<AuthRepository>(
      () =>
          MockAuthRepository(sessionRepository: injector<SessionRepository>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(injector<ProductDataSource>()),
    )
    ..registerLazySingleton<SalesRepository>(
      () => SalesRepositoryImpl(
        dataSource: injector<SalesDataSource>(),
        sessionRepository: injector<SessionRepository>(),
      ),
    )
    ..registerLazySingleton<CashRegisterRepository>(
      () => CashRegisterRepositoryImpl(
        dataSource: injector<CashRegisterDataSource>(),
        sessionRepository: injector<SessionRepository>(),
      ),
    );
}

void _registerUseCases() {
  injector
    // Auth.
    ..registerLazySingleton<SignInWithEmail>(
      () => SignInWithEmail(injector<AuthRepository>()),
    )
    ..registerLazySingleton<SignInWithGoogle>(
      () => SignInWithGoogle(injector<AuthRepository>()),
    )
    ..registerLazySingleton<RequestPhoneCode>(
      () => RequestPhoneCode(injector<AuthRepository>()),
    )
    ..registerLazySingleton<RequestSignInCode>(
      () => RequestSignInCode(injector<AuthRepository>()),
    )
    ..registerLazySingleton<SignInWithPhone>(
      () => SignInWithPhone(injector<AuthRepository>()),
    )
    ..registerLazySingleton<VerifyPhoneCode>(
      () => VerifyPhoneCode(injector<AuthRepository>()),
    )
    ..registerLazySingleton<SaveBusinessProfile>(
      () => SaveBusinessProfile(injector<AuthRepository>()),
    )
    ..registerLazySingleton<SaveSalesSetup>(
      () => SaveSalesSetup(injector<AuthRepository>()),
    )
    ..registerLazySingleton<GetSessionInfo>(
      () => GetSessionInfo(injector<SessionRepository>()),
    )
    // Catalog.
    ..registerLazySingleton<GetProducts>(
      () => GetProducts(injector<ProductRepository>()),
    )
    ..registerLazySingleton<GetCategories>(
      () => GetCategories(injector<ProductRepository>()),
    )
    ..registerLazySingleton<GetLowStockProducts>(
      () => GetLowStockProducts(injector<ProductRepository>()),
    )
    ..registerLazySingleton<CreateProduct>(
      () => CreateProduct(injector<ProductRepository>()),
    )
    ..registerLazySingleton<UpdateProduct>(
      () => UpdateProduct(injector<ProductRepository>()),
    )
    ..registerLazySingleton<GetProduct>(
      () => GetProduct(injector<ProductRepository>()),
    )
    ..registerLazySingleton<RemovePhotoBackground>(
      () => RemovePhotoBackground(injector<ImageBackgroundRemover>()),
    )
    ..registerLazySingleton<CaptureProductPhoto>(
      () => CaptureProductPhoto(injector<PhotoCapturer>()),
    )
    // Sales.
    ..registerLazySingleton<RegisterSale>(
      () => RegisterSale(
        salesRepository: injector<SalesRepository>(),
        productRepository: injector<ProductRepository>(),
        cashRegisterRepository: injector<CashRegisterRepository>(),
      ),
    )
    ..registerLazySingleton<GetDailySalesSummary>(
      () => GetDailySalesSummary(injector<SalesRepository>()),
    )
    ..registerLazySingleton<GetNextSaleNumber>(
      () => GetNextSaleNumber(injector<SalesRepository>()),
    )
    ..registerLazySingleton<GetPairedPrinters>(
      () => GetPairedPrinters(injector<ReceiptPrinter>()),
    )
    ..registerLazySingleton<PrintReceipt>(
      () => PrintReceipt(injector<ReceiptPrinter>()),
    )
    ..registerLazySingleton<ShareReceipt>(
      () => ShareReceipt(injector<ReceiptSharer>()),
    )
    // Cash drawer.
    ..registerLazySingleton<GetCurrentCashSession>(
      () => GetCurrentCashSession(injector<CashRegisterRepository>()),
    )
    ..registerLazySingleton<OpenCashSession>(
      () => OpenCashSession(injector<CashRegisterRepository>()),
    )
    ..registerLazySingleton<CloseCashSession>(
      () => CloseCashSession(injector<CashRegisterRepository>()),
    )
    ..registerLazySingleton<GetCashCloseSummary>(
      () => GetCashCloseSummary(
        cashRegisterRepository: injector<CashRegisterRepository>(),
        salesRepository: injector<SalesRepository>(),
      ),
    )
    // Dashboard.
    ..registerLazySingleton<GetDashboardSnapshot>(
      () => GetDashboardSnapshot(
        salesRepository: injector<SalesRepository>(),
        cashRegisterRepository: injector<CashRegisterRepository>(),
        productRepository: injector<ProductRepository>(),
        sessionRepository: injector<SessionRepository>(),
      ),
    );
}

void _registerCubits() {
  injector
    // Session-scoped: the cart and the drawer must survive navigation.
    ..registerLazySingleton<SessionCubit>(
      () => SessionCubit(injector<GetSessionInfo>()),
    )
    ..registerLazySingleton<CartCubit>(
      () => CartCubit(injector<GetNextSaleNumber>()),
    )
    ..registerLazySingleton<CashRegisterCubit>(
      () => CashRegisterCubit(
        getCurrentCashSession: injector<GetCurrentCashSession>(),
        openCashSession: injector<OpenCashSession>(),
      ),
    )
    ..registerLazySingleton<DashboardCubit>(
      () => DashboardCubit(injector<GetDashboardSnapshot>()),
    )
    // Screen-scoped.
    ..registerFactory<SignInCubit>(
      () => SignInCubit(
        signInWithEmail: injector<SignInWithEmail>(),
        signInWithGoogle: injector<SignInWithGoogle>(),
        requestSignInCode: injector<RequestSignInCode>(),
        signInWithPhone: injector<SignInWithPhone>(),
      ),
    )
    ..registerFactory<RegistrationCubit>(
      () => RegistrationCubit(
        requestPhoneCode: injector<RequestPhoneCode>(),
        verifyPhoneCode: injector<VerifyPhoneCode>(),
        signInWithGoogle: injector<SignInWithGoogle>(),
        saveBusinessProfile: injector<SaveBusinessProfile>(),
        saveSalesSetup: injector<SaveSalesSetup>(),
      ),
    )
    ..registerFactory<CatalogCubit>(
      () => CatalogCubit(
        getProducts: injector<GetProducts>(),
        getCategories: injector<GetCategories>(),
      ),
    )
    ..registerFactory<ProductFormCubit>(
      () => ProductFormCubit(
        getCategories: injector<GetCategories>(),
        getProduct: injector<GetProduct>(),
        createProduct: injector<CreateProduct>(),
        updateProduct: injector<UpdateProduct>(),
        captureProductPhoto: injector<CaptureProductPhoto>(),
        removePhotoBackground: injector<RemovePhotoBackground>(),
      ),
    )
    ..registerFactory<PrintReceiptCubit>(
      () => PrintReceiptCubit(
        getPairedPrinters: injector<GetPairedPrinters>(),
        printReceipt: injector<PrintReceipt>(),
      ),
    )
    ..registerFactory<ShareReceiptCubit>(
      () => ShareReceiptCubit(shareReceipt: injector<ShareReceipt>()),
    )
    ..registerFactory<CashCloseCubit>(
      () => CashCloseCubit(
        getCashCloseSummary: injector<GetCashCloseSummary>(),
        closeCashSession: injector<CloseCashSession>(),
      ),
    )
    ..registerFactoryParam<ProductDetailCubit, String, void>(
      (String productId, _) => ProductDetailCubit(
        getProduct: injector<GetProduct>(),
        productId: productId,
      ),
    )
    ..registerFactoryParam<CheckoutCubit, Cart, void>(
      (Cart cart, _) =>
          CheckoutCubit(registerSale: injector<RegisterSale>(), cart: cart),
    );
}
