// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cumavi POS';

  @override
  String get commonDefaultBusinessName => 'Mi negocio';

  @override
  String get commonDefaultPrinterName => 'Impresora';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonBack => 'Volver';

  @override
  String get paymentMethodCash => 'Efectivo';

  @override
  String get paymentMethodQr => 'QR';

  @override
  String get paymentMethodCard => 'Tarjeta';

  @override
  String get paymentMethodBankTransfer => 'Transferencia';

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count artículos',
      one: '1 artículo',
    );
    return '$_temp0';
  }

  @override
  String get failureUnexpected =>
      'Ocurrió un error inesperado. Intenta nuevamente.';

  @override
  String get failureFullNameRequired => 'Ingresa tu nombre y apellido.';

  @override
  String get failureInvalidMobileNumber =>
      'Ingresa un celular boliviano de 8 dígitos.';

  @override
  String get failureInvalidEmail => 'Ingresa un correo válido.';

  @override
  String get failurePasswordTooShort =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get failureVerificationCodeIncomplete =>
      'Ingresa los 6 dígitos del código.';

  @override
  String get failureVerificationCodeInvalid =>
      'El código no es correcto. Revisa el SMS.';

  @override
  String get failureBusinessNameTooShort =>
      'El nombre del negocio debe tener 3 caracteres.';

  @override
  String get failureSalesCategoryRequired => 'Elige al menos una categoría.';

  @override
  String get failurePaymentMethodRequired =>
      'Elige al menos un método de pago.';

  @override
  String get failureBusinessProfileRequired =>
      'Primero registra los datos de tu negocio.';

  @override
  String get failureInvalidTaxId =>
      'El NIT debe tener solo números (entre 5 y 15).';

  @override
  String get failureNegativeOpeningAmount =>
      'El monto inicial no puede ser negativo.';

  @override
  String get failureNegativeCountedCash =>
      'El efectivo contado no puede ser negativo.';

  @override
  String get failureCashSessionAlreadyOpen => 'La caja ya está abierta.';

  @override
  String get failureCashSessionNotOpen => 'No hay una caja abierta.';

  @override
  String get failureProductNotFound => 'No encontramos el producto.';

  @override
  String get failureProductNameTooShort =>
      'El nombre del producto debe tener al menos 3 caracteres.';

  @override
  String get failureCategoryRequired => 'Elige una categoría.';

  @override
  String get failureCategoryNotFound => 'La categoría seleccionada no existe.';

  @override
  String get failureCategoryNameInvalid =>
      'El nombre de la categoría debe tener entre 2 y 30 caracteres.';

  @override
  String get failureCategoryNameTaken =>
      'Ya tienes una categoría con ese nombre.';

  @override
  String get failureInvalidSku =>
      'El SKU debe tener de 2 a 32 letras sin tilde, números, guiones o puntos.';

  @override
  String get failureInvalidBarcode =>
      'El código de barras debe tener de 4 a 32 letras o números.';

  @override
  String failureProductCodeRepeated(String code) {
    return 'El código $code está repetido en este producto.';
  }

  @override
  String failureProductCodeTaken(String productName) {
    return 'Ese código ya lo usa «$productName».';
  }

  @override
  String get failureProductCodeTakenGeneric =>
      'Ese código ya lo usa otro producto.';

  @override
  String failureProductCodeNotFound(String code) {
    return 'Ningún producto tiene el código $code.';
  }

  @override
  String get failureInvalidSalePrice =>
      'El precio de venta debe ser mayor a 0.';

  @override
  String get failureNegativeCostPrice => 'El costo no puede ser negativo.';

  @override
  String get failureCostAbovePrice =>
      'El costo no puede ser mayor al precio de venta.';

  @override
  String get failureNegativeStock => 'La cantidad no puede ser negativa.';

  @override
  String get failureIncompleteVariantOptions =>
      'Revisa las variantes: cada tipo necesita un nombre y al menos un valor, sin repetir.';

  @override
  String failureInsufficientStock(String productName) {
    return 'No hay stock suficiente de $productName.';
  }

  @override
  String get failureInsufficientStockGeneric =>
      'No hay stock suficiente para esta venta.';

  @override
  String get failureCameraPermissionDenied =>
      'Permite el acceso a la cámara y a las fotos en los ajustes.';

  @override
  String get failureCameraUnavailable =>
      'No pudimos abrir la cámara. Intenta nuevamente.';

  @override
  String get failureBackgroundRemovalFailed =>
      'No pudimos quitar el fondo. Prueba con otra foto o más luz.';

  @override
  String get failureSaleNotFound => 'No encontramos la venta.';

  @override
  String get failureEmptyCart => 'Agrega al menos un producto para cobrar.';

  @override
  String get failureInsufficientPayment =>
      'El monto recibido es menor al total.';

  @override
  String get failureCashSessionRequired =>
      'Abre la caja antes de registrar una venta.';

  @override
  String failureInvalidCopies(String maxCopies) {
    return 'Puedes imprimir entre 1 y $maxCopies copias.';
  }

  @override
  String get failurePrintersUnavailable =>
      'No pudimos leer las impresoras vinculadas.';

  @override
  String get failureBluetoothPermissionDenied =>
      'Permite el acceso a dispositivos cercanos para usar la impresora.';

  @override
  String get failureBluetoothDisabled => 'Activa el Bluetooth para imprimir.';

  @override
  String failurePrinterUnreachable(String printerName) {
    return 'No pudimos conectar con $printerName. Revisa que esté encendida y cerca.';
  }

  @override
  String get failurePrinterNotResponding =>
      'La impresora no respondió. Intenta nuevamente.';

  @override
  String get failurePrinterTimeout =>
      'La impresora tardó demasiado en responder.';

  @override
  String get failurePrintFailed => 'No pudimos imprimir el comprobante.';

  @override
  String get failureShareFailed => 'No pudimos compartir el comprobante.';

  @override
  String get failureWhatsAppUnavailable =>
      'No encontramos WhatsApp en este celular.';

  @override
  String get failureEmailAppUnavailable =>
      'No hay una app de correo configurada.';

  @override
  String get failurePhotoLibraryPermissionDenied =>
      'Permite el acceso a tus fotos para guardar.';

  @override
  String get shellHome => 'Inicio';

  @override
  String get shellSales => 'Ventas';

  @override
  String get shellInventory => 'Inventario';

  @override
  String get commonCloseTooltip => 'Cerrar';

  @override
  String get commonScanBarcodeTooltip => 'Escanear código';

  @override
  String get commonQuantityRemoveTooltip => 'Quitar';

  @override
  String get commonQuantityDecrementTooltip => 'Restar uno';

  @override
  String get commonQuantityIncrementTooltip => 'Sumar uno';

  @override
  String commonStepProgress(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String commonStepProgressLabel(String label) {
    return ' · $label';
  }

  @override
  String get authMethodEmail => 'Correo';

  @override
  String get authMethodPhone => 'Teléfono';

  @override
  String get authPhoneNumberLabel => 'Celular';

  @override
  String get authEmailLabel => 'Correo electrónico';

  @override
  String get authEmailHint => 'tucorreo@gmail.com';

  @override
  String get authPasswordLabel => 'Contraseña';

  @override
  String get authSendCode => 'Enviar código';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignInTitle => 'Hola de nuevo';

  @override
  String get authSignInSubtitle =>
      'Ingresa para abrir tu caja y empezar a vender.';

  @override
  String get authSignInWithGoogle => 'Continuar con Google';

  @override
  String get authSignInDivider => 'o ingresa con';

  @override
  String get authSignInPhoneHelper => 'Te enviaremos un código por SMS.';

  @override
  String get authSignInPasswordHint => 'Mínimo 8 caracteres';

  @override
  String get authSignInShowPassword => 'Mostrar contraseña';

  @override
  String get authSignInHidePassword => 'Ocultar contraseña';

  @override
  String get authSignInForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String authSignInPasswordResetSent(String email) {
    return 'Te enviamos un enlace a $email para cambiar tu contraseña.';
  }

  @override
  String get authSignInPasswordResetNeedsEmail =>
      'Escribe tu correo y te enviamos un enlace para cambiar tu contraseña.';

  @override
  String get authSignInNoAccountPrompt => '¿Aún no tienes cuenta?';

  @override
  String get authRegisterStepLabel => 'Tu cuenta';

  @override
  String get authRegisterTitle => 'Crea tu cuenta';

  @override
  String get authRegisterSubtitle =>
      'Registra tu negocio y vende desde tu celular.';

  @override
  String get authRegisterWithGoogle => 'Registrarme con Google';

  @override
  String get authRegisterDivider => 'o regístrate con';

  @override
  String get authRegisterFullNameLabel => 'Nombre y apellido';

  @override
  String get authRegisterFullNameHint => 'Ej. Carla Mamani';

  @override
  String get authRegisterPhoneHelper =>
      'Te enviaremos un código por SMS para verificarlo.';

  @override
  String get authRegisterPasswordHelper => 'Mínimo 8 caracteres.';

  @override
  String get authRegisterTermsPrefix => 'Acepto los ';

  @override
  String get authRegisterTermsLink => 'Términos';

  @override
  String get authRegisterTermsConnector => ' y la ';

  @override
  String get authRegisterPrivacyPolicyLink => 'Política de privacidad';

  @override
  String get authRegisterHaveAccountPrompt => '¿Ya tienes cuenta?';

  @override
  String get authPhoneVerificationStepLabel => 'Verificación';

  @override
  String get authPhoneVerificationTitle => 'Ingresa el código';

  @override
  String get authPhoneVerificationSentTo => 'Te enviamos 6 dígitos por SMS al ';

  @override
  String get authPhoneVerificationChangeNumber => 'Cambiar número';

  @override
  String get authPhoneVerificationResendHint =>
      'Si no te llega, pide otro código.';

  @override
  String get authPhoneVerificationResend => 'Reenviar';

  @override
  String get authPhoneVerificationSubmit => 'Verificar';

  @override
  String get authPhoneVerificationViaWhatsApp =>
      'Recibir el código por WhatsApp';

  @override
  String get authPhoneVerificationCodeResent => 'Te enviamos un nuevo código.';

  @override
  String get authPhoneVerificationCodeSentViaWhatsApp =>
      'Te enviamos el código por WhatsApp.';

  @override
  String authDemoCodeTitle(String code) {
    return 'Usa el código $code';
  }

  @override
  String get authDemoCodeMessage => 'Modo demo: no se envían SMS.';

  @override
  String get authDemoCodeUse => 'Usar';

  @override
  String get authBusinessProfileStepLabel => 'Tu negocio';

  @override
  String get authBusinessProfileTitle => 'Sobre tu negocio';

  @override
  String get authBusinessProfileSubtitle =>
      'Lo usamos en tu POS y en tus comprobantes.';

  @override
  String get authBusinessProfileLogoTitle => 'Logo del negocio';

  @override
  String get authBusinessProfileLogoReady => 'Listo. Toca para cambiarlo.';

  @override
  String get authBusinessProfileLogoOptional =>
      'Opcional. Aparece en tus comprobantes.';

  @override
  String get authBusinessProfileLogoSourceSubtitle =>
      'Aparece en tus comprobantes y en tu catálogo.';

  @override
  String get authBusinessProfileNameLabel => 'Nombre del negocio';

  @override
  String get authBusinessProfileNameHint => 'Ej. Illimani Store';

  @override
  String get authBusinessProfileTypeLabel => 'Tipo de negocio';

  @override
  String get authBusinessProfileDepartmentLabel => 'Departamento';

  @override
  String get authBusinessTypeClothingAndFootwear => 'Ropa y calzado';

  @override
  String get authBusinessTypeNeighborhoodStore => 'Tienda de barrio';

  @override
  String get authBusinessTypeFoodAndDrinks => 'Comida y bebidas';

  @override
  String get authBusinessTypeBeautyAndCare => 'Belleza y cuidado';

  @override
  String get authBusinessTypeTechnology => 'Tecnología';

  @override
  String get authBusinessTypeOther => 'Otro';

  @override
  String get authSalesSetupStepLabel => 'Cómo vendes';

  @override
  String get authSalesSetupTitle => 'Últimos detalles';

  @override
  String get authSalesSetupSubtitle => 'Puedes cambiarlos cuando quieras.';

  @override
  String get authSalesSetupCategoriesTitle => 'Categorías de tu inventario';

  @override
  String get authSalesSetupSuggestedFor => 'Sugeridas para ';

  @override
  String get authSalesSetupPaymentMethodsTitle =>
      '¿Cómo te pagan tus clientes?';

  @override
  String get authSalesSetupPaymentMethodsSubtitle =>
      'Aparecerán al momento de cobrar.';

  @override
  String get authSalesSetupTaxIdLabel => 'NIT';

  @override
  String get authSalesSetupTaxIdOptional => '(opcional)';

  @override
  String get authSalesSetupTaxIdHelper =>
      'Si lo agregas, se muestra en tus comprobantes.';

  @override
  String get authSalesSetupTaxIdHint => 'Número de NIT';

  @override
  String get authSalesSetupSubmit => 'Terminar registro';

  @override
  String get authBusinessReadyDefaultName => 'Tu negocio';

  @override
  String authBusinessReadyTitle(String businessName) {
    return '¡$businessName está lista!';
  }

  @override
  String get authBusinessReadySubtitle =>
      'Tu cuenta y tu punto de venta ya están configurados.';

  @override
  String get authBusinessReadyFirstStepsTitle => 'Primeros pasos';

  @override
  String get authBusinessReadyStepAccountTitle => 'Crear tu cuenta';

  @override
  String get authBusinessReadyStepAccountDone => 'Listo';

  @override
  String get authBusinessReadyStepProductsTitle => 'Agrega tus productos';

  @override
  String get authBusinessReadyStepProductsSubtitle =>
      'Con foto, precio y cantidad';

  @override
  String get authBusinessReadyStepSellTitle => 'Abre tu caja y vende';

  @override
  String get authBusinessReadyStepSellSubtitle => 'Registra tu primera venta';

  @override
  String get authBusinessReadyAddFirstProduct => 'Agregar mi primer producto';

  @override
  String get authBusinessReadyGoHome => 'Ir al inicio';

  @override
  String get dashboardLoadError => 'No pudimos cargar el resumen del día.';

  @override
  String get dashboardNotificationsTooltip => 'Notificaciones';

  @override
  String get dashboardNoNotifications => 'No tienes notificaciones nuevas.';

  @override
  String get dashboardGreeting => 'Hola';

  @override
  String dashboardGreetingWithName(String firstName) {
    return 'Hola, $firstName';
  }

  @override
  String dashboardLowStockTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos con stock bajo',
      one: '1 producto con stock bajo',
    );
    return '$_temp0';
  }

  @override
  String get dashboardLowStockSubtitle => 'Revisa tu inventario';

  @override
  String get dashboardCashCardNoShifts => 'Sin turnos';

  @override
  String get dashboardCashCardTodaySales => 'Ventas de hoy';

  @override
  String get dashboardCashCardSalesMetric => 'Ventas';

  @override
  String get dashboardCashCardAverageTicketMetric => 'Ticket prom.';

  @override
  String get dashboardCashCardCashInDrawerMetric => 'En caja';

  @override
  String get dashboardCashCardNewSale => 'Nueva venta';

  @override
  String get dashboardCashCardOpenCashRegister => 'Abrir caja';

  @override
  String dashboardCashCardOpenSince(String time) {
    return 'Caja abierta · desde $time';
  }

  @override
  String get dashboardCashCardClosed => 'Caja cerrada';

  @override
  String get dashboardPaymentBreakdownTitle => 'Métodos de pago';

  @override
  String get dashboardPaymentBreakdownPeriod => 'Hoy';

  @override
  String get dashboardPaymentBreakdownEmpty => 'Aún no registraste ventas hoy.';

  @override
  String get salesSaleTitle => 'Venta';

  @override
  String salesSaleNumber(String number) {
    return 'Venta $number';
  }

  @override
  String get salesCashRegisterOpenStatus => 'Caja abierta';

  @override
  String get salesSearchProductHint => 'Buscar producto';

  @override
  String get salesCartTitle => 'Carrito';

  @override
  String salesCartItemCountSuffix(String items) {
    return ' · $items';
  }

  @override
  String get salesCartClearButton => 'Vaciar';

  @override
  String get salesCartEmptyTitle => 'El carrito está vacío';

  @override
  String get salesCartEmptyMessage =>
      'Busca o escanea un producto para empezar la venta.';

  @override
  String get salesCartBrowseByCategory => 'Explorar por categoría';

  @override
  String salesStockLimitMessage(int count, String productName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Solo quedan $count unidades de $productName.',
      one: 'Solo queda 1 unidad de $productName.',
    );
    return '$_temp0';
  }

  @override
  String salesProductSoldOutMessage(String productName) {
    return '$productName está agotado.';
  }

  @override
  String salesSummaryTotalItems(String items) {
    return 'Total · $items';
  }

  @override
  String get salesSummarySubtotalLabel => 'Subtotal ';

  @override
  String get salesSummaryDiscountButton => 'Descuento';

  @override
  String get salesSummaryChargeButton => 'Cobrar';

  @override
  String get salesDiscountSheetTitle => 'Aplicar descuento';

  @override
  String get salesDiscountSheetSubtitle => 'Se resta del total de la venta.';

  @override
  String get salesDiscountSheetAmountLabel => 'Monto del descuento';

  @override
  String get salesDiscountSheetApplyButton => 'Aplicar';

  @override
  String salesCategoryProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String get salesProductSoldOutBadge => 'Agotado';

  @override
  String salesProductInStock(int count) {
    return '$count en stock';
  }

  @override
  String get salesProductOutOfStock => 'Sin stock';

  @override
  String salesProductAddTooltip(String productName) {
    return 'Agregar $productName';
  }

  @override
  String salesCartLineUnitPrice(String price) {
    return '$price c/u';
  }

  @override
  String get salesSearchBackTooltip => 'Volver a la venta';

  @override
  String get salesSearchHint => 'Nombre o código';

  @override
  String get salesSearchAllCategories => 'Todos';

  @override
  String get salesSearchNoResultsTitle => 'Sin resultados';

  @override
  String get salesSearchNoResultsMessage =>
      'Prueba con otro nombre o cambia de categoría.';

  @override
  String get salesSearchViewSaleButton => 'Ver venta';

  @override
  String get salesCheckoutTitle => 'Cobrar venta';

  @override
  String salesCheckoutSubtitle(String number, String items) {
    return 'Venta $number · $items';
  }

  @override
  String get salesCheckoutTotalLabel => 'Total a cobrar';

  @override
  String get salesCheckoutSeeDetailButton => 'Ver detalle';

  @override
  String get salesCheckoutPaymentMethodLabel => 'Método de pago';

  @override
  String get salesCheckoutAmountReceivedLabel => 'Monto recibido';

  @override
  String get salesCheckoutExactAmount => 'Exacto';

  @override
  String get salesCheckoutChangeTitle => 'Cambio a devolver';

  @override
  String get salesCheckoutConfirmButton => 'Confirmar cobro';

  @override
  String get salesCompletedTitle => 'Venta registrada';

  @override
  String salesCompletedSubtitle(String number, String date, String time) {
    return 'Venta $number · $date, $time';
  }

  @override
  String get salesCompletedDetailTitle => 'Detalle';

  @override
  String get salesCompletedTotalLabel => 'Total';

  @override
  String get salesCompletedReceivedLabel => 'Recibido';

  @override
  String get salesCompletedChangeLabel => 'Cambio';

  @override
  String get salesCompletedNewSaleButton => 'Nueva venta';

  @override
  String get salesCompletedGoHomeButton => 'Volver al inicio';

  @override
  String get salesReceiptActionView => 'Comprobante';

  @override
  String get salesReceiptActionPrint => 'Imprimir';

  @override
  String get salesReceiptActionShare => 'Compartir';

  @override
  String get salesReceiptScreenTitle => 'Comprobante';

  @override
  String salesReceiptStoreLocation(String department, String country) {
    return '$department, $country';
  }

  @override
  String salesReceiptStoreDetails(String location, String taxId) {
    return '$location · $taxId';
  }

  @override
  String get salesPrintSheetTitle => 'Imprimir comprobante';

  @override
  String salesPrintSheetSubtitle(String number, String total) {
    return 'N° $number · $total';
  }

  @override
  String get salesPrintSheetPrinterLabel => 'Impresora';

  @override
  String get salesPrintSheetNoPrinters =>
      'No hay impresoras vinculadas. Vincula tu impresora térmica desde los ajustes de Bluetooth del celular.';

  @override
  String get salesPrintSheetSearchPrinters => 'Buscar impresoras vinculadas';

  @override
  String get salesPrintSheetPaperLabel => 'Papel';

  @override
  String get salesPrintSheetCopiesLabel => 'Copias';

  @override
  String get salesPrintSheetPrintButton => 'Imprimir';

  @override
  String get salesPrintSheetPrintedMessage =>
      'Comprobante enviado a la impresora.';

  @override
  String get salesShareSheetTitle => 'Compartir comprobante';

  @override
  String salesShareSheetReceiptSummary(
    String total,
    String paymentMethod,
    String items,
  ) {
    return '$total · $paymentMethod · $items';
  }

  @override
  String get salesShareSheetFormatLabel => 'Formato';

  @override
  String get salesShareSheetImageFormat => 'Imagen';

  @override
  String get salesShareSheetWhatsAppLabel => 'Enviar al WhatsApp del cliente';

  @override
  String get salesShareSheetPhoneHint => 'Número de celular';

  @override
  String get salesShareSheetWhatsAppTooltip => 'Enviar por WhatsApp';

  @override
  String get salesShareSheetWhatsAppHint =>
      'Se envía el detalle de la venta como mensaje.';

  @override
  String get salesShareSheetSaveTarget => 'Guardar';

  @override
  String get salesShareSheetEmailTarget => 'Correo';

  @override
  String get salesShareSheetOtherAppsTarget => 'Otras apps';

  @override
  String get salesShareSheetWhatsAppOpening =>
      'Abriendo WhatsApp con el comprobante…';

  @override
  String get salesShareSheetEmailOpening => 'Abriendo tu app de correo…';

  @override
  String get salesShareSheetSaved => 'Comprobante guardado.';

  @override
  String get salesShareSheetReady => 'Comprobante listo para compartir.';

  @override
  String get receiptNumberLabel => 'Comprobante N°';

  @override
  String receiptNumberTitle(String number) {
    return 'Comprobante N° $number';
  }

  @override
  String receiptDocumentTitle(String number) {
    return 'Comprobante $number';
  }

  @override
  String receiptEmailSubject(String number, String businessName) {
    return 'Comprobante N° $number · $businessName';
  }

  @override
  String receiptFileName(String number) {
    return 'comprobante-$number';
  }

  @override
  String get receiptDateLabel => 'Fecha';

  @override
  String get receiptCashierLabel => 'Atendió';

  @override
  String get receiptSubtotalLabel => 'Subtotal';

  @override
  String get receiptDiscountLabel => 'Descuento';

  @override
  String get receiptTotalLabel => 'TOTAL';

  @override
  String get receiptChangeLabel => 'Cambio';

  @override
  String receiptTaxId(String taxId) {
    return 'NIT $taxId';
  }

  @override
  String get receiptCountry => 'Bolivia';

  @override
  String get receiptThanks => '¡Gracias por tu compra!';

  @override
  String get receiptMadeWith => 'Hecho con Cumavi POS';

  @override
  String get receiptMadeWithPrefix => 'Hecho con';

  @override
  String get cashRegisterTitle => 'Ventas';

  @override
  String get cashRegisterClosedStatus => 'Caja cerrada';

  @override
  String get cashRegisterOpenHeadline => 'Abre la caja para empezar a vender';

  @override
  String get cashRegisterOpenDescription =>
      'Ingresa el efectivo con el que inicias el día. La caja queda abierta hasta que la cierres.';

  @override
  String get cashRegisterOpeningAmountLabel => 'Monto inicial en efectivo';

  @override
  String get cashRegisterCashierLabel => 'Cajero';

  @override
  String get cashRegisterNoCashier => 'Sin cajero';

  @override
  String get cashRegisterOpenedAtLabel => 'Apertura';

  @override
  String get cashRegisterOpenAction => 'Abrir caja';

  @override
  String get cashRegisterOpenFailed => 'No pudimos abrir la caja.';

  @override
  String get cashRegisterCloseTitle => 'Cerrar caja';

  @override
  String cashRegisterCloseSubtitle(String time) {
    return 'Abierta hoy desde las $time';
  }

  @override
  String get cashRegisterCloseLoadFailed =>
      'No pudimos cargar el cierre de caja.';

  @override
  String get cashRegisterOpeningAmount => 'Monto inicial';

  @override
  String cashRegisterSalesByMethod(String method) {
    return 'Ventas con $method';
  }

  @override
  String get cashRegisterTotalSold => 'Total vendido';

  @override
  String cashRegisterSaleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventas',
      one: '1 venta',
    );
    return ' · $_temp0';
  }

  @override
  String get cashRegisterExpectedCash => 'Efectivo esperado';

  @override
  String get cashRegisterExpectedCashFormula =>
      'Monto inicial + ventas en efectivo';

  @override
  String get cashRegisterCountedCashLabel => 'Efectivo contado';

  @override
  String get cashRegisterShortage => 'Faltante';

  @override
  String get cashRegisterSurplus => 'Sobrante';

  @override
  String get cashRegisterNoteLabel => 'Observación';

  @override
  String get cashRegisterNoteHint => 'Explica la diferencia (opcional)';

  @override
  String get cashRegisterConfirmClose => 'Confirmar cierre';

  @override
  String get catalogInventoryTitle => 'Inventario';

  @override
  String get catalogInventorySearchHint => 'Buscar producto';

  @override
  String get catalogInventoryFilterAll => 'Todos';

  @override
  String catalogInventoryProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String catalogInventoryLowStockSuffix(int count) {
    return ' · $count con stock bajo';
  }

  @override
  String get catalogInventoryCreateProduct => 'Crear producto';

  @override
  String get catalogInventoryEmptyTitle => 'Sin productos';

  @override
  String get catalogInventoryEmptyMessage =>
      'Crea tu primer producto para empezar a vender.';

  @override
  String catalogProductTileSubtitle(String categoryName, String cost) {
    return '$categoryName · Costo $cost';
  }

  @override
  String catalogStockBadgeUnits(int count) {
    return '$count u.';
  }

  @override
  String catalogStockBadgeLow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count',
      one: 'Queda 1',
    );
    return '$_temp0';
  }

  @override
  String get catalogStockBadgeOutOfStock => 'Agotado';

  @override
  String get catalogProductFormTitle => 'Nuevo producto';

  @override
  String get catalogProductFormNameLabel => 'Nombre';

  @override
  String get catalogProductFormNameHint => 'Ej. Zapatillas urbanas café';

  @override
  String get catalogProductFormCategoryLabel => 'Categoría';

  @override
  String get catalogProductFormQuantityLabel => 'Cantidad';

  @override
  String get catalogProductFormQuantityCaption => 'Unidades en stock';

  @override
  String get catalogProductFormSalePriceLabel => 'Precio de venta';

  @override
  String get catalogProductFormCostLabel => 'Costo';

  @override
  String get catalogProductFormProfitTitle => 'Ganancia c/u';

  @override
  String catalogProductFormProfitValue(String amount, String margin) {
    return '$amount · $margin';
  }

  @override
  String get catalogProductFormSave => 'Guardar producto';

  @override
  String get catalogPhotoFieldRemoveBackgroundLabel => 'Quitar fondo';

  @override
  String get catalogPhotoFieldRemoveBackgroundDescription =>
      'El producto queda sobre fondo blanco';

  @override
  String get catalogPhotoFieldProcessing => 'Procesando la foto…';

  @override
  String get catalogPhotoFieldEmptyTitle => 'Tomar foto del producto';

  @override
  String get catalogPhotoFieldEmptySubtitle => 'Le quitamos el fondo por ti';

  @override
  String get catalogPhotoFieldBackgroundRemovedBadge => 'Fondo quitado';

  @override
  String get catalogPhotoFieldAdjust => 'Ajustar';

  @override
  String get catalogPhotoFieldChangePhotoTooltip => 'Cambiar foto';

  @override
  String get catalogPhotoSourceTitle => 'Foto del producto';

  @override
  String get catalogPhotoSourceSubtitle =>
      'Le quitamos el fondo automáticamente.';

  @override
  String get catalogPhotoSourceCamera => 'Tomar foto';

  @override
  String get catalogPhotoSourceCameraDescription => 'Usa la cámara del celular';

  @override
  String get catalogPhotoSourceGallery => 'Elegir de la galería';

  @override
  String get catalogPhotoSourceGalleryDescription =>
      'Una foto que ya tengas guardada';

  @override
  String get catalogBackgroundRemovalNoPhoto =>
      'Toma una foto del producto para editarla.';

  @override
  String get catalogBackgroundRemovalTitle => 'Quitar fondo';

  @override
  String get catalogBackgroundRemovalDefaultSubtitle => 'Foto del producto';

  @override
  String get catalogBackgroundRemovalDone => 'Fondo quitado';

  @override
  String get catalogBackgroundRemovalCompareHint => 'Desliza para comparar';

  @override
  String get catalogBackgroundRemovalRetake => 'Repetir foto';

  @override
  String get catalogBackgroundRemovalUsePhoto => 'Usar foto';

  @override
  String get catalogBackgroundOptionWhite => 'Blanco';

  @override
  String get catalogBackgroundOptionTransparent => 'Transparente';

  @override
  String get catalogBackgroundOptionOriginal => 'Original';

  @override
  String get catalogBeforeAfterBeforeLabel => 'Original';

  @override
  String get catalogBeforeAfterAfterLabel => 'Sin fondo';

  @override
  String catalogProductTileVariantSummary(int count, String options) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes · $options',
      one: '1 variante · $options',
    );
    return '$_temp0';
  }

  @override
  String get catalogDetailTitle => 'Producto';

  @override
  String get catalogDetailEdit => 'Editar producto';

  @override
  String get catalogDetailLoadErrorTitle => 'No pudimos cargar el producto';

  @override
  String catalogDetailPhotoLabel(int current, int total) {
    return 'Foto $current de $total';
  }

  @override
  String get catalogDetailPricesTitle => 'Precios';

  @override
  String get catalogDetailStockTitle => 'Stock';

  @override
  String catalogDetailStockUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'unidades en stock',
      one: 'unidad en stock',
    );
    return '$_temp0';
  }

  @override
  String get catalogDetailStockSoldOutLabel => 'Variantes agotadas';

  @override
  String get catalogDetailDescriptionTitle => 'Descripción';

  @override
  String get catalogDetailVariantsTitle => 'Variantes';

  @override
  String catalogDetailVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String catalogDetailGroupSoldOut(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count agotadas',
      one: '1 agotada',
      zero: 'Todas con stock',
    );
    return '$_temp0';
  }

  @override
  String catalogDetailCreatedAt(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Agregado el $dateString';
  }

  @override
  String get catalogDetailViewPhotoTooltip => 'Ver foto';

  @override
  String get catalogProductFormEditTitle => 'Editar producto';

  @override
  String get catalogProductFormSaveChanges => 'Guardar cambios';

  @override
  String get catalogProductFormLoadErrorTitle => 'No pudimos abrir el producto';

  @override
  String get catalogProductFormDataSection => 'Datos del producto';

  @override
  String get catalogProductFormPriceSection => 'Precio';

  @override
  String get catalogProductFormStockSection => 'Stock y variantes';

  @override
  String get catalogProductFormOptional => '(opcional)';

  @override
  String get catalogProductFormDescriptionLabel => 'Descripción';

  @override
  String get catalogProductFormDescriptionHint =>
      'Material, cuidados o detalles que ayuden a vender';

  @override
  String get catalogProductFormGalleryTitle => 'Más fotos';

  @override
  String get catalogProductFormGalleryCaption =>
      'Otros colores o ángulos. Cada variante puede usar una de estas fotos.';

  @override
  String get catalogProductFormGalleryAdd => 'Agregar';

  @override
  String get catalogProductFormGalleryRemoveTooltip => 'Quitar foto';

  @override
  String get catalogProductFormGallerySourceTitle => 'Agregar foto';

  @override
  String get catalogProductFormGallerySourceSubtitle =>
      'Se guarda tal cual, sin quitar el fondo.';

  @override
  String get catalogProductFormAddVariants =>
      'Agregar variantes (talla, color…)';

  @override
  String get catalogProductFormAddVariantsCaption =>
      'Vende por talla o color, con stock para cada una.';

  @override
  String catalogProductFormTotalStock(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unidades',
      one: '1 unidad',
    );
    return '$_temp0';
  }

  @override
  String get catalogVariantTypeSheetTitle => 'Tipo de variante';

  @override
  String get catalogVariantTypeSheetSubtitle =>
      'Elige uno o escribe otro, como Material.';

  @override
  String get catalogVariantTypeColor => 'Color';

  @override
  String get catalogVariantTypeColorDescription => 'Negro, blanco, rojo…';

  @override
  String get catalogVariantTypeSize => 'Talla';

  @override
  String get catalogVariantTypeSizeDescription =>
      'S, M, L o números como 38 y 40';

  @override
  String get catalogVariantTypeCustomLabel => 'Otro tipo';

  @override
  String get catalogVariantTypeCustomHint => 'Ej. Material';

  @override
  String get catalogVariantTypeAdd => 'Agregar';

  @override
  String get catalogVariantTypeRenameTitle => 'Cambiar nombre';

  @override
  String get catalogVariantTypeNameLabel => 'Nombre del tipo';

  @override
  String get catalogVariantSizeSuggestions => 'S,M,L,XL';

  @override
  String get catalogVariantColorSuggestions => 'Negro,Blanco,Rojo,Azul,Gris';

  @override
  String catalogVariantValueHint(String option) {
    return 'Nuevo valor de $option';
  }

  @override
  String get catalogVariantValueAddTooltip => 'Agregar valor';

  @override
  String catalogVariantValueRemoveTooltip(String value) {
    return 'Quitar $value';
  }

  @override
  String get catalogVariantOptionEmptyHint =>
      'Agrega al menos un valor para crear las variantes.';

  @override
  String get catalogVariantOptionRenameTooltip => 'Cambiar nombre';

  @override
  String get catalogVariantOptionRemoveTooltip => 'Quitar tipo';

  @override
  String get catalogVariantAddAnotherType => 'Agregar otro tipo';

  @override
  String catalogVariantRemoveTypeTitle(String option) {
    return '¿Quitar $option?';
  }

  @override
  String get catalogVariantRemoveTypeMessage =>
      'Se borran sus valores y el stock cargado en esas variantes.';

  @override
  String get catalogVariantRemoveTypeConfirm => 'Quitar';

  @override
  String catalogVariantListTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String get catalogVariantListCaption =>
      'Toca la foto para cambiarla o el nombre para sus códigos.';

  @override
  String catalogVariantPhotoTooltip(String variant) {
    return 'Foto de $variant';
  }

  @override
  String get catalogVariantImageSheetTitle => 'Foto de la variante';

  @override
  String get catalogVariantImageMain => 'Principal';

  @override
  String get catalogVariantImageAdd => 'Nueva foto';

  @override
  String catalogVariantImageApplyToGroup(String value) {
    return 'Usar en todas las variantes $value';
  }

  @override
  String get catalogVariantImageGalleryHint =>
      'Sube más fotos para que cada color muestre la suya.';

  @override
  String get salesVariantSheetTitle => 'Elige la variante';

  @override
  String salesVariantMissingOption(String option) {
    return 'Falta elegir $option';
  }

  @override
  String salesVariantAllInCart(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Las $count unidades ya están en la venta',
      one: 'La única unidad ya está en la venta',
    );
    return '$_temp0';
  }

  @override
  String salesVariantInCart(int count) {
    return '$count en la venta';
  }

  @override
  String get salesVariantQuantityLabel => 'Cantidad';

  @override
  String salesVariantAddButton(String total) {
    return 'Agregar · $total';
  }

  @override
  String salesVariantProductName(String productName, String variantLabel) {
    return '$productName ($variantLabel)';
  }

  @override
  String salesVariantAddedMessage(int count, String productName) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se agregaron $count a la venta: $productName',
      one: 'Se agregó a la venta: $productName',
    );
    return '$_temp0';
  }

  @override
  String salesVariantCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count variantes',
      one: '1 variante',
    );
    return '$_temp0';
  }

  @override
  String salesVariantChooseTooltip(String productName) {
    return 'Elegir variante de $productName';
  }

  @override
  String salesVariantValueUnavailable(String value) {
    return '$value, sin stock';
  }

  @override
  String get accountMoreTitle => 'Más';

  @override
  String get accountOpenMenuTooltip => 'Tu cuenta y tu negocio';

  @override
  String get accountSectionBusiness => 'Negocio';

  @override
  String get accountProviderGoogle => 'Google';

  @override
  String get accountProviderEmail => 'correo';

  @override
  String get accountProviderPhone => 'teléfono';

  @override
  String accountSignedInWith(String method) {
    return 'Ingresaste con $method';
  }

  @override
  String get accountBusinessEdit => 'Editar datos del negocio';

  @override
  String get accountBusinessNoTaxId => 'Sin NIT';

  @override
  String get accountSignOut => 'Cerrar sesión';

  @override
  String get accountSignOutTitle => '¿Cerrar sesión?';

  @override
  String get accountSignOutMessage =>
      'Tendrás que ingresar de nuevo para vender.';

  @override
  String get accountSignOutCashOpen =>
      'La caja queda abierta. Podrás cerrarla cuando vuelvas a ingresar.';

  @override
  String accountVersion(String app, String version, String build) {
    return '$app · versión $version ($build)';
  }

  @override
  String get accountBusinessTitle => 'Datos del negocio';

  @override
  String get accountBusinessSubtitle =>
      'Así aparece tu tienda en los comprobantes y en tu catálogo.';

  @override
  String get accountBusinessLogoChange => 'Cambiar logo';

  @override
  String get accountBusinessTaxIdLabel => 'NIT';

  @override
  String get accountBusinessOptional => '(opcional)';

  @override
  String get accountBusinessTaxIdHint => 'Ej.: 1020304050';

  @override
  String get accountBusinessTaxIdHelper => 'Se imprime en tus comprobantes.';

  @override
  String get accountBusinessSave => 'Guardar cambios';

  @override
  String get accountBusinessSaved => 'Datos del negocio guardados';

  @override
  String get accountSectionOperation => 'Operación';

  @override
  String get accountOperationCategoriesHint =>
      'Crea, ordena y archiva tus categorías';

  @override
  String get catalogCategoriesTitle => 'Categorías';

  @override
  String get catalogCategoriesSubtitle =>
      'Arrastra para ordenarlas como las ves al vender.';

  @override
  String get catalogCategoriesNew => 'Nueva categoría';

  @override
  String get catalogCategoriesCreate => 'Crear categoría';

  @override
  String get catalogCategoriesCreated => 'Categoría creada';

  @override
  String get catalogCategoriesRename => 'Renombrar';

  @override
  String get catalogCategoriesRenameTitle => 'Renombrar categoría';

  @override
  String get catalogCategoriesRenamed => 'Categoría renombrada';

  @override
  String get catalogCategoriesArchive => 'Archivar';

  @override
  String catalogCategoriesArchiveTitle(String name) {
    return '¿Archivar $name?';
  }

  @override
  String catalogCategoriesArchiveMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sus $count productos siguen',
      one: 'Su producto sigue',
    );
    return '$_temp0 en tu inventario. La categoría ya no aparecerá al crear productos ni en los filtros.';
  }

  @override
  String get catalogCategoriesArchived => 'Categoría archivada';

  @override
  String get catalogCategoriesUndo => 'Deshacer';

  @override
  String get catalogCategoriesArchivedSection => 'Archivadas';

  @override
  String get catalogCategoriesRestore => 'Restaurar';

  @override
  String get catalogCategoriesRestored => 'Categoría restaurada';

  @override
  String catalogCategoriesProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
      zero: 'Sin productos',
    );
    return '$_temp0';
  }

  @override
  String get catalogCategoriesEmptyTitle => 'Todavía no tienes categorías';

  @override
  String get catalogCategoriesEmptyMessage =>
      'Crea la primera para ordenar tu inventario.';

  @override
  String catalogCategoriesMenu(String name) {
    return 'Opciones de $name';
  }

  @override
  String get catalogCategoriesDragHandle => 'Arrastrar para ordenar';

  @override
  String get catalogCategoriesManage => 'Gestionar';

  @override
  String get catalogCategoryNameHint => 'Ej.: Ropa de niños';

  @override
  String catalogProductFormArchivedCategory(String name) {
    return '$name (archivada)';
  }

  @override
  String get scannerSellTitle => 'Escanear producto';

  @override
  String get scannerSellSubtitle =>
      'Apunta al código de barras y se agrega a la venta.';

  @override
  String get scannerFindTitle => 'Buscar por código';

  @override
  String get scannerFindSubtitle =>
      'Apunta al código de barras para abrir el producto.';

  @override
  String get scannerAssignTitle => 'Escanear código';

  @override
  String get scannerAssignSubtitle =>
      'Apunta al código de barras de la etiqueta.';

  @override
  String get scannerTorchTooltip => 'Linterna';

  @override
  String get scannerDemoCamera =>
      'La cámara no está disponible en este dispositivo. Escribe el código o usa uno de prueba.';

  @override
  String get scannerTypeTitle => '¿No lo lee? Escríbelo';

  @override
  String get scannerTypeHint => 'Ej.: 7770000008001';

  @override
  String get scannerTypeSubmit => 'Usar código';

  @override
  String get scannerDemoCodesTitle => 'Códigos de prueba';

  @override
  String get scannerDemoCodesCaption =>
      'Toca uno para probar sin etiquetas impresas.';

  @override
  String get catalogProductFormCodesSection => 'Códigos';

  @override
  String get catalogProductFormSkuLabel => 'SKU';

  @override
  String get catalogProductFormSkuHint => 'Ej.: CAL-001';

  @override
  String get catalogProductFormGenerateSku => 'Generar';

  @override
  String get catalogProductFormBarcodeLabel => 'Código de barras';

  @override
  String get catalogProductFormBarcodeHint => 'Escanéalo o escríbelo';

  @override
  String get catalogProductFormCodesCaption =>
      'Con el código de barras, escanear la etiqueta agrega el producto a la venta.';

  @override
  String get catalogProductFormCodesVariantsCaption =>
      'Cada variante puede tener su propio SKU y código de barras: tócala en la lista de stock.';

  @override
  String catalogVariantCodesTitle(String variant) {
    return 'Códigos · $variant';
  }

  @override
  String get catalogVariantAddCodes => 'Agregar SKU o código';

  @override
  String get catalogScanUnknownTitle => 'Código sin producto';

  @override
  String catalogScanUnknownMessage(String code) {
    return 'Ningún producto tiene el código $code. ¿Quieres crear uno con este código?';
  }

  @override
  String get catalogScanUnknownCreate => 'Crear producto con este código';

  @override
  String get salesHistoryTitle => 'Historial de ventas';

  @override
  String salesHistorySummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventas · $total',
      one: '1 venta · $total',
      zero: 'Sin ventas',
    );
    return '$_temp0';
  }

  @override
  String get salesHistorySearchHint => 'Buscar por número de venta';

  @override
  String get salesHistorySearchingAllDates => 'Buscando en todas las fechas.';

  @override
  String get salesHistoryPeriodToday => 'Hoy';

  @override
  String get salesHistoryPeriodYesterday => 'Ayer';

  @override
  String get salesHistoryPeriodLast7Days => 'Últimos 7 días';

  @override
  String get salesHistoryPeriodCustom => 'Elegir fechas';

  @override
  String salesHistoryRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get salesHistoryAllMethods => 'Todos los pagos';

  @override
  String salesHistoryDayTotal(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ventas · $total',
      one: '1 venta · $total',
    );
    return '$_temp0';
  }

  @override
  String salesHistoryMoreProducts(int count, String first) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$first y $count productos más',
      one: '$first y 1 producto más',
    );
    return '$_temp0';
  }

  @override
  String get salesHistoryEmptyTitle => 'No hay ventas en estas fechas';

  @override
  String get salesHistoryEmptyMessage =>
      'Prueba con otro período o método de pago.';

  @override
  String get salesHistoryNumberNotFoundTitle => 'No encontramos esa venta';

  @override
  String salesHistoryNumberNotFoundMessage(String number) {
    return 'Ninguna venta tiene el número $number.';
  }

  @override
  String saleDetailTitle(String number) {
    return 'Venta $number';
  }

  @override
  String get saleDetailTitleLoading => 'Venta';

  @override
  String get saleDetailLoadError => 'No pudimos abrir esta venta';

  @override
  String saleDetailProducts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count productos',
      one: '1 producto',
    );
    return '$_temp0';
  }

  @override
  String saleDetailUnitPrice(int quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get saleDetailSubtotal => 'Subtotal';

  @override
  String get saleDetailDiscount => 'Descuento';

  @override
  String get saleDetailTotal => 'Total';

  @override
  String get saleDetailPayment => 'Pago';

  @override
  String get saleDetailMethod => 'Método';

  @override
  String get saleDetailReceived => 'Recibido';

  @override
  String get saleDetailChange => 'Cambio';

  @override
  String get saleDetailCashier => 'Atendió';

  @override
  String get saleDetailViewReceipt => 'Ver comprobante';

  @override
  String get accountOperationSalesHistoryHint =>
      'Busca una venta y vuelve a imprimir o compartir su comprobante';

  @override
  String get dashboardCashCardHistory => 'Ver historial';

  @override
  String get cashRegisterViewSales => 'Ver las ventas del día';

  @override
  String get failureInvalidStockQuantity => 'La cantidad debe ser mayor a 0.';

  @override
  String get failureAdjustmentReasonRequired => 'Elige el motivo del ajuste.';

  @override
  String get failureNoStockChange =>
      'El conteo es igual al stock actual: no hay nada que ajustar.';

  @override
  String get failureEmptyGoodsReceipt =>
      'Agrega al menos un producto al ingreso.';

  @override
  String get catalogProductFormStockLockedTitle => 'El stock no se edita aquí';

  @override
  String get catalogProductFormStockLockedCaption =>
      'Cámbialo con «Ingreso» o «Ajustar» en el detalle del producto, así queda registrado.';

  @override
  String get accountOperationMovementsHint =>
      'Ingresos, ajustes y ventas de cada producto';

  @override
  String get inventoryMovementsTitle => 'Movimientos de stock';

  @override
  String get inventorySeeAll => 'Ver todos';

  @override
  String get inventoryNoMovements => 'Sin movimientos todavía';

  @override
  String get inventoryNoMovementsMessage => 'Prueba con otro tipo o período.';

  @override
  String get inventoryAddStock => 'Ingreso';

  @override
  String get inventoryAdjust => 'Ajustar';

  @override
  String get inventoryTypeInitial => 'Inventario inicial';

  @override
  String get inventoryTypePurchase => 'Ingreso';

  @override
  String get inventoryTypeAdjustment => 'Ajuste';

  @override
  String get inventoryTypeSale => 'Venta';

  @override
  String get inventoryTypeCancellation => 'Venta anulada';

  @override
  String get inventoryTypeReturn => 'Devolución';

  @override
  String get inventoryReasonCount => 'Conteo';

  @override
  String get inventoryReasonDamage => 'Dañado';

  @override
  String get inventoryReasonLoss => 'Pérdida';

  @override
  String get inventoryReasonOther => 'Otro';

  @override
  String inventoryMovementWhen(String date, String user) {
    return '$date · $user';
  }

  @override
  String inventoryStockAfter(int count) {
    return 'Stock $count';
  }

  @override
  String get inventoryFilterAll => 'Todos';

  @override
  String get inventoryFilterPurchases => 'Ingresos';

  @override
  String get inventoryFilterAdjustments => 'Ajustes';

  @override
  String get inventoryFilterSales => 'Ventas';

  @override
  String get inventoryPeriodLast30Days => 'Últimos 30 días';

  @override
  String get inventoryPeriodAll => 'Todo';

  @override
  String get inventoryAdjustTitle => 'Ajustar stock';

  @override
  String get inventoryAdjustSave => 'Guardar ajuste';

  @override
  String get inventoryAdjustSaved => 'Stock ajustado';

  @override
  String get inventoryVariantLabel => 'Variante';

  @override
  String inventoryVariantWithStock(String variant, int count) {
    return '$variant · $count u.';
  }

  @override
  String get inventoryModeCount => 'Contar';

  @override
  String get inventoryModeAdd => 'Agregar';

  @override
  String get inventoryModeRemove => 'Quitar';

  @override
  String get inventoryQuantityCounted => 'Unidades contadas';

  @override
  String get inventoryQuantityToAdd => 'Unidades a agregar';

  @override
  String get inventoryQuantityToRemove => 'Unidades a quitar';

  @override
  String get inventoryQuantityHint => '0';

  @override
  String get inventoryCurrentStock => 'Stock actual';

  @override
  String get inventoryNewStock => 'Nuevo stock';

  @override
  String get inventoryNotEnoughStock => 'No alcanza';

  @override
  String get inventoryReasonTitle => 'Motivo';

  @override
  String get inventoryNoteLabel => 'Nota';

  @override
  String get inventoryAdjustNoteHint => 'Ej.: se encontró en el depósito';

  @override
  String get inventoryReceiveTitle => 'Ingreso de mercadería';

  @override
  String get inventoryReceiveSubtitle => 'Registra lo que llegó a tu tienda';

  @override
  String get inventoryReceiveEmptyTitle => '¿Qué llegó hoy?';

  @override
  String get inventoryReceiveEmptyMessage =>
      'Agrega los productos que recibiste, o escanéalos.';

  @override
  String get inventoryReceiveAddProduct => 'Agregar producto';

  @override
  String get inventoryReceiveSave => 'Registrar ingreso';

  @override
  String inventoryReceiveSaveUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Registrar ingreso · $count unidades',
      one: 'Registrar ingreso · 1 unidad',
    );
    return '$_temp0';
  }

  @override
  String inventoryReceiveSaved(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se agregaron $count unidades al stock',
      one: 'Se agregó 1 unidad al stock',
    );
    return '$_temp0';
  }

  @override
  String get inventorySupplierLabel => 'Proveedor o nota';

  @override
  String get inventorySupplierHint => 'Ej.: Importadora Andina';

  @override
  String inventoryStockNow(int count) {
    return 'Stock actual: $count';
  }

  @override
  String get inventoryRemoveLine => 'Quitar del ingreso';

  @override
  String get inventoryUnitCostLabel => 'Costo c/u';

  @override
  String get inventoryPickProductTitle => 'Agregar producto';

  @override
  String get inventoryPickProductHint => 'Buscar por nombre o código';

  @override
  String get inventoryPickVariantSubtitle => '¿Qué variante llegó?';

  @override
  String get failureSaleAlreadyCancelled => 'Esta venta ya fue anulada.';

  @override
  String get failureSaleHasReturns =>
      'Esta venta ya tiene devoluciones: registra otra devolución en lugar de anularla.';

  @override
  String get failureSaleCancelWindowClosed =>
      'Solo puedes anular ventas de la caja abierta. Para ventas anteriores registra una devolución.';

  @override
  String get failureReturnWindowClosed =>
      'Pasaron más de 30 días desde la venta: ya no se puede devolver.';

  @override
  String get failureReturnQuantityExceeded =>
      'No puedes devolver más unidades de las que quedan en la venta.';

  @override
  String get failureInvalidRefundMethod =>
      'El reembolso se hace con el mismo método de la venta o en efectivo.';

  @override
  String get failureEmptyReturn => 'Elige al menos una unidad para devolver.';

  @override
  String get failureReasonRequired => 'Escribe el motivo.';

  @override
  String get receiptMarkCancelled => 'ANULADA';

  @override
  String get receiptMarkPartiallyReturned => 'CON DEVOLUCIÓN PARCIAL';

  @override
  String get receiptMarkReturned => 'DEVUELTA';

  @override
  String get receiptMarkRefund => 'DEVOLUCIÓN';

  @override
  String receiptRefundOf(String number) {
    return 'De la venta $number';
  }

  @override
  String get salesRefundReceiptTitle => 'Comprobante de devolución';

  @override
  String get saleStatusCancelled => 'Anulada';

  @override
  String get saleStatusPartiallyReturned => 'Devolución parcial';

  @override
  String get saleStatusReturned => 'Devuelta';

  @override
  String get saleDetailCancel => 'Anular';

  @override
  String get saleDetailReturn => 'Devolver';

  @override
  String get saleDetailCancelled =>
      'Venta anulada: sus productos volvieron al stock';

  @override
  String get saleDetailCancelledTitle => 'Venta anulada';

  @override
  String saleDetailCancelTitle(String number) {
    return '¿Anular la venta $number?';
  }

  @override
  String saleDetailCancelMessage(String total) {
    return 'Sus $total salen de las ventas y de la caja, y sus productos vuelven al stock.';
  }

  @override
  String get saleDetailReasonHint => 'Motivo, ej.: se cobró dos veces';

  @override
  String get saleDetailRefunded => 'Devuelto';

  @override
  String get saleDetailReturnsTitle => 'Devoluciones';

  @override
  String saleDetailReturnSummary(String number, int units) {
    String _temp0 = intl.Intl.pluralLogic(
      units,
      locale: localeName,
      other: '$units unidades',
      one: '1 unidad',
    );
    return '$number · $_temp0';
  }

  @override
  String saleDetailReturnedUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count devueltas',
      one: '1 devuelta',
    );
    return '$_temp0';
  }

  @override
  String get returnTitle => 'Devolución';

  @override
  String get returnWhatTitle => '¿Qué devuelve el cliente?';

  @override
  String returnDiscountNote(String discount) {
    return 'El descuento de $discount se reparte entre los productos.';
  }

  @override
  String returnReturnable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Puede devolver $count',
      one: 'Puede devolver 1',
    );
    return '$_temp0';
  }

  @override
  String returnLineRefund(String amount) {
    return 'Se devuelve $amount';
  }

  @override
  String get returnRestock => 'Vuelve al stock';

  @override
  String get returnNoRestock =>
      'No se podrá vender (por ejemplo, está dañado).';

  @override
  String get returnRefundTitle => 'Reembolso';

  @override
  String get returnReasonHint => 'Otro motivo';

  @override
  String get returnSave => 'Registrar devolución';

  @override
  String returnSaveAmount(String amount) {
    return 'Devolver $amount';
  }

  @override
  String returnSaved(String number, String amount) {
    return 'Devolución $number registrada: $amount';
  }

  @override
  String cashRegisterRefunds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Devoluciones ($count)',
      one: 'Devoluciones (1)',
    );
    return '$_temp0';
  }

  @override
  String get receiptRefundTotalLabel => 'TOTAL DEVUELTO';

  @override
  String get receiptRefundClosing => '¡Gracias por tu visita!';

  @override
  String get accountOnlineStoreHint =>
      'Tu link, el póster QR, horarios y cómo recibes pedidos';

  @override
  String get accountOrdersHint => 'Pedidos de tu catálogo en línea';

  @override
  String get catalogProductFormShowOnline => 'Mostrar en la tienda en línea';

  @override
  String get catalogProductFormShowOnlineCaption =>
      'Los clientes lo ven en tu catálogo y pueden pedirlo.';

  @override
  String get failureOrderNotFound => 'No encontramos ese pedido.';

  @override
  String get failureInvalidOrderTransition =>
      'El pedido ya no está en un estado que permita esto. Actualiza la pantalla.';

  @override
  String get failureOrderNotEditable =>
      'Solo puedes editar pedidos nuevos o confirmados.';

  @override
  String get failureOrderEmpty => 'El pedido debe tener al menos un producto.';

  @override
  String get failureInvalidDeliveryFee =>
      'El costo de envío no puede ser negativo.';

  @override
  String get failureInvalidOrderLink =>
      'No encontramos un pedido en ese texto. Pega el mensaje o el link completo.';

  @override
  String get failureOrderFromAnotherStore => 'Ese pedido es de otra tienda.';

  @override
  String get failureStoreDisabled =>
      'Tu tienda en línea está desactivada. Actívala en Más → Tienda en línea.';

  @override
  String get failureInvalidOpeningHours =>
      'Revisa el horario: cada tramo debe cerrar después de abrir y no pueden superponerse.';

  @override
  String get failureOnlineFulfillmentRequired =>
      'Activa al menos el recojo en tienda o el envío.';

  @override
  String get failureOnlinePaymentMethodRequired =>
      'Elige al menos un método de pago para los pedidos en línea.';

  @override
  String get failurePhoneAppUnavailable =>
      'No pudimos abrir la app de llamadas.';

  @override
  String get failureLinkUnavailable => 'No pudimos abrir el link.';

  @override
  String get onlineStoreTitle => 'Tienda en línea';

  @override
  String get onlineStoreSubtitle => 'Tu catálogo para recibir pedidos';

  @override
  String get onlineStoreEnabled => 'Tienda activa';

  @override
  String get onlineStoreEnabledOn =>
      'Tus clientes ven tu catálogo y pueden pedir.';

  @override
  String get onlineStoreEnabledOff =>
      'Tu link muestra que la tienda no recibe pedidos.';

  @override
  String get onlineStoreOpenNow => 'Abierta ahora';

  @override
  String get onlineStoreClosedNow => 'Cerrada ahora';

  @override
  String get onlineStoreCopyLink => 'Copiar';

  @override
  String get onlineStoreShareLink => 'Compartir';

  @override
  String get onlineStoreOpenLink => 'Abrir';

  @override
  String get onlineStoreLinkCopied => 'Link copiado';

  @override
  String onlineStoreShareMessage(String business, String url) {
    return 'Haz tu pedido en $business: $url';
  }

  @override
  String get onlineStorePosterAction => 'Póster QR';

  @override
  String get onlineStorePosterScreenSubtitle =>
      'Imprímelo y pégalo en tu mostrador o puerta';

  @override
  String get onlineStorePosterTitle => 'Escanea y pide';

  @override
  String get onlineStorePosterSubtitle =>
      'Mira nuestros productos y haz tu pedido desde el celular.';

  @override
  String get onlineStorePosterFileName => 'poster-tienda';

  @override
  String get onlineStorePublicTitle => 'Datos públicos';

  @override
  String get onlineStoreTaglineLabel => 'Frase de tu tienda';

  @override
  String get onlineStoreTaglineHint => 'Ej.: Ropa, calzado y accesorios';

  @override
  String get onlineStoreWhatsAppLabel => 'WhatsApp para pedidos';

  @override
  String get onlineStoreFulfillmentTitle => 'Entrega';

  @override
  String get onlineStorePickupCaption => 'El cliente recoge en tu tienda.';

  @override
  String get onlineStoreDeliveryCaption =>
      'Lo llevas a su dirección; el costo lo pones al confirmar.';

  @override
  String get onlineStoreDeliveryNoteLabel => 'Nota de envío';

  @override
  String get onlineStoreDeliveryNoteHint =>
      'Ej.: Envíos en el día dentro de la ciudad';

  @override
  String get onlineStoreHoursTitle => 'Horario';

  @override
  String get onlineStoreHoursSheetSubtitle =>
      'Puedes poner varios tramos, como mañana y tarde.';

  @override
  String get onlineStoreClosedDay => 'Cerrado';

  @override
  String get onlineStoreAddRange => 'Agregar horario';

  @override
  String get onlineStoreRemoveRange => 'Quitar horario';

  @override
  String get onlineStoreOutsideHours => 'Recibir pedidos fuera de horario';

  @override
  String get onlineStoreOutsideHoursCaption =>
      'La web avisa al cliente cuándo abres.';

  @override
  String get onlineStoreCatalogTitle => 'Catálogo';

  @override
  String onlineStoreProductsOnline(int online, int total) {
    return '$online de $total productos se muestran en línea';
  }

  @override
  String get onlineStoreProductsOnlineCaption =>
      'Elige cuáles al crear o editar cada producto.';

  @override
  String get onlineStoreShowOutOfStock => 'Mostrar productos agotados';

  @override
  String get onlineStoreShowOutOfStockCaption =>
      'Se ven como agotados y no se pueden pedir.';

  @override
  String get onlineStorePaymentsTitle => 'Pagos en línea';

  @override
  String get onlineStoreSaved => 'Tienda en línea guardada';

  @override
  String get ordersTitle => 'Pedidos en línea';

  @override
  String get ordersSubtitle => 'Los pedidos de tu catálogo web';

  @override
  String get ordersImportTooltip => 'Importar pedido de WhatsApp';

  @override
  String get ordersFilterNew => 'Nuevos';

  @override
  String get ordersFilterInProgress => 'En curso';

  @override
  String get ordersFilterDelivered => 'Entregados';

  @override
  String get ordersFilterCancelled => 'Cancelados';

  @override
  String get ordersDemoTitle => 'Modo demo';

  @override
  String get ordersDemoMessage =>
      'Los pedidos de la web llegarán aquí al conectar el servidor.';

  @override
  String get ordersDemoSimulate => 'Simular pedido';

  @override
  String get ordersEmptyNewTitle => 'No hay pedidos nuevos';

  @override
  String get ordersEmptyNewMessage =>
      'Cuando un cliente pida desde tu catálogo, aparecerá aquí.';

  @override
  String get ordersEmptyTitle => 'No hay pedidos aquí';

  @override
  String get ordersEmptyMessage => 'Prueba con otra pestaña.';

  @override
  String ordersCardNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevos',
      one: '1 nuevo',
    );
    return '$_temp0';
  }

  @override
  String ordersCardInProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count en curso',
      one: '1 en curso',
    );
    return '$_temp0';
  }

  @override
  String get ordersCardEmpty => 'Sin pedidos pendientes';

  @override
  String get orderStatusNew => 'Nuevo';

  @override
  String get orderStatusConfirmed => 'Confirmado';

  @override
  String get orderStatusReady => 'Listo';

  @override
  String get orderStatusDelivered => 'Entregado';

  @override
  String get orderStatusCancelled => 'Cancelado';

  @override
  String get orderFulfillmentPickup => 'Recojo en tienda';

  @override
  String get orderFulfillmentDelivery => 'Envío a domicilio';

  @override
  String orderPlacedMinutesAgo(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'Hace $minutes min',
      one: 'Hace 1 min',
      zero: 'Ahora',
    );
    return '$_temp0';
  }

  @override
  String orderPlacedToday(String time) {
    return 'Hoy · $time';
  }

  @override
  String orderPlacedYesterday(String time) {
    return 'Ayer · $time';
  }

  @override
  String orderDetailTitle(String number) {
    return 'Pedido $number';
  }

  @override
  String get orderDetailTitleLoading => 'Pedido';

  @override
  String get orderDetailLoadError => 'No pudimos abrir este pedido';

  @override
  String get orderImportedNote => 'Llegó por el link de WhatsApp.';

  @override
  String orderCancelReason(String reason) {
    return 'Cancelado: $reason';
  }

  @override
  String get orderCustomerTitle => 'Cliente';

  @override
  String get orderCall => 'Llamar';

  @override
  String get orderWhatsApp => 'WhatsApp';

  @override
  String get orderDeliveryFeePending => 'Por definir';

  @override
  String get orderPaymentMethod => 'Pagará con';

  @override
  String get orderHistoryTitle => 'Historial';

  @override
  String get orderHistoryPlaced => 'Pedido recibido';

  @override
  String get orderHistoryEdited => 'Pedido editado';

  @override
  String get orderActionConfirm => 'Confirmar pedido';

  @override
  String get orderActionReady => 'Marcar como listo';

  @override
  String get orderActionCheckout => 'Cobrar pedido';

  @override
  String get orderActionViewSale => 'Ver venta';

  @override
  String get orderActionEdit => 'Editar';

  @override
  String get orderActionCancel => 'Cancelar pedido';

  @override
  String get orderNotifyAction => 'Avisar';

  @override
  String get orderConfirmedToast => 'Pedido confirmado';

  @override
  String get orderReadyToast => 'Pedido listo';

  @override
  String get orderCancelledToast => 'Pedido cancelado';

  @override
  String get orderEditedToast => 'Pedido actualizado';

  @override
  String get orderDeliveryFeeTitle => 'Costo de envío';

  @override
  String get orderDeliveryFeeSubtitle =>
      'Se suma al total del pedido. Déjalo vacío si el envío es gratis.';

  @override
  String orderCancelTitle(String number) {
    return '¿Cancelar el pedido $number?';
  }

  @override
  String get orderCancelMessage =>
      'El cliente verá que fue cancelado. Elige o escribe el motivo.';

  @override
  String get orderCancelReasonNoStock => 'Sin stock';

  @override
  String get orderCancelReasonNoAnswer => 'El cliente no respondió';

  @override
  String get orderCancelReasonCustomer => 'El cliente canceló';

  @override
  String orderEditTitle(String number) {
    return 'Editar pedido $number';
  }

  @override
  String orderEditSave(String total) {
    return 'Guardar · $total';
  }

  @override
  String get orderCompletedBackToOrder => 'Volver al pedido';

  @override
  String orderArrivedToast(String number, String total) {
    return 'Nuevo pedido $number · $total';
  }

  @override
  String get orderArrivedView => 'Ver';

  @override
  String get orderImportTitle => 'Importar pedido';

  @override
  String get orderImportSubtitle => 'De un mensaje de WhatsApp de tu catálogo';

  @override
  String get orderImportFieldLabel => 'Mensaje o link del pedido';

  @override
  String get orderImportFieldHint =>
      'Pega aquí el mensaje que te llegó por WhatsApp';

  @override
  String get orderImportPaste => 'Pegar';

  @override
  String get orderImportAction => 'Importar pedido';

  @override
  String get orderImportHowTitle => '¿Cómo funciona?';

  @override
  String get orderImportHowMessage =>
      'Cada pedido de tu catálogo web llega por WhatsApp con un link. Tócalo en este celular para abrirlo aquí, o copia el mensaje y pégalo arriba.';

  @override
  String orderImportedToast(String number) {
    return 'Pedido $number en tu bandeja';
  }

  @override
  String orderMessageNew(String name, String number, String store) {
    return 'Hola $name, te escribimos de $store por tu pedido $number.';
  }

  @override
  String orderMessageConfirmed(String name, String number, String total) {
    return 'Hola $name, confirmamos tu pedido $number. Total: $total. ¡Ya lo estamos preparando!';
  }

  @override
  String orderMessageConfirmedDelivery(
    String name,
    String number,
    String fee,
    String total,
  ) {
    return 'Hola $name, confirmamos tu pedido $number. Envío: $fee. Total: $total. ¡Ya lo estamos preparando!';
  }

  @override
  String orderMessageReadyPickup(String name, String number, String store) {
    return 'Hola $name, tu pedido $number está listo. Puedes recogerlo en $store.';
  }

  @override
  String orderMessageReadyDelivery(String name, String number) {
    return 'Hola $name, tu pedido $number está listo y va en camino.';
  }

  @override
  String orderMessageDelivered(String name, String number) {
    return 'Hola $name, ¡gracias por tu compra! Tu pedido $number fue entregado.';
  }

  @override
  String orderMessageCancelled(String name, String number, String reason) {
    return 'Hola $name, lamentamos avisarte que tu pedido $number fue cancelado: $reason.';
  }

  @override
  String get receiptDeliveryLabel => 'Envío';

  @override
  String get saleDetailChannel => 'Origen';

  @override
  String saleDetailOnlineOrder(String number) {
    return 'Pedido en línea $number';
  }
}
