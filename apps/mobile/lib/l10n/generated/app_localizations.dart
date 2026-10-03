import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Cumavi POS'**
  String get appTitle;

  /// No description provided for @commonDefaultBusinessName.
  ///
  /// In es, this message translates to:
  /// **'Mi negocio'**
  String get commonDefaultBusinessName;

  /// No description provided for @commonDefaultPrinterName.
  ///
  /// In es, this message translates to:
  /// **'Impresora'**
  String get commonDefaultPrinterName;

  /// No description provided for @commonRetry.
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get commonCancel;

  /// No description provided for @commonContinue.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get commonContinue;

  /// No description provided for @commonSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get commonSave;

  /// No description provided for @commonBack.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get commonBack;

  /// No description provided for @paymentMethodCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get paymentMethodCash;

  /// No description provided for @paymentMethodQr.
  ///
  /// In es, this message translates to:
  /// **'QR'**
  String get paymentMethodQr;

  /// No description provided for @paymentMethodCard.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get paymentMethodCard;

  /// No description provided for @paymentMethodBankTransfer.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get paymentMethodBankTransfer;

  /// No description provided for @itemCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 artículo} other{{count} artículos}}'**
  String itemCount(int count);

  /// No description provided for @failureUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Ocurrió un error inesperado. Intenta nuevamente.'**
  String get failureUnexpected;

  /// No description provided for @failureFullNameRequired.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tu nombre y apellido.'**
  String get failureFullNameRequired;

  /// No description provided for @failureInvalidMobileNumber.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un celular boliviano de 8 dígitos.'**
  String get failureInvalidMobileNumber;

  /// No description provided for @failureInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'Ingresa un correo válido.'**
  String get failureInvalidEmail;

  /// No description provided for @failurePasswordTooShort.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 8 caracteres.'**
  String get failurePasswordTooShort;

  /// No description provided for @failureVerificationCodeIncomplete.
  ///
  /// In es, this message translates to:
  /// **'Ingresa los 6 dígitos del código.'**
  String get failureVerificationCodeIncomplete;

  /// No description provided for @failureVerificationCodeInvalid.
  ///
  /// In es, this message translates to:
  /// **'El código no es correcto. Revisa el SMS.'**
  String get failureVerificationCodeInvalid;

  /// No description provided for @failureBusinessNameTooShort.
  ///
  /// In es, this message translates to:
  /// **'El nombre del negocio debe tener 3 caracteres.'**
  String get failureBusinessNameTooShort;

  /// No description provided for @failureSalesCategoryRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige al menos una categoría.'**
  String get failureSalesCategoryRequired;

  /// No description provided for @failurePaymentMethodRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige al menos un método de pago.'**
  String get failurePaymentMethodRequired;

  /// No description provided for @failureBusinessProfileRequired.
  ///
  /// In es, this message translates to:
  /// **'Primero registra los datos de tu negocio.'**
  String get failureBusinessProfileRequired;

  /// No description provided for @failureInvalidTaxId.
  ///
  /// In es, this message translates to:
  /// **'El NIT debe tener solo números (entre 5 y 15).'**
  String get failureInvalidTaxId;

  /// No description provided for @failureNegativeOpeningAmount.
  ///
  /// In es, this message translates to:
  /// **'El monto inicial no puede ser negativo.'**
  String get failureNegativeOpeningAmount;

  /// No description provided for @failureNegativeCountedCash.
  ///
  /// In es, this message translates to:
  /// **'El efectivo contado no puede ser negativo.'**
  String get failureNegativeCountedCash;

  /// No description provided for @failureCashSessionAlreadyOpen.
  ///
  /// In es, this message translates to:
  /// **'La caja ya está abierta.'**
  String get failureCashSessionAlreadyOpen;

  /// No description provided for @failureCashSessionNotOpen.
  ///
  /// In es, this message translates to:
  /// **'No hay una caja abierta.'**
  String get failureCashSessionNotOpen;

  /// No description provided for @failureProductNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos el producto.'**
  String get failureProductNotFound;

  /// No description provided for @failureProductNameTooShort.
  ///
  /// In es, this message translates to:
  /// **'El nombre del producto debe tener al menos 3 caracteres.'**
  String get failureProductNameTooShort;

  /// No description provided for @failureCategoryRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige una categoría.'**
  String get failureCategoryRequired;

  /// No description provided for @failureCategoryNotFound.
  ///
  /// In es, this message translates to:
  /// **'La categoría seleccionada no existe.'**
  String get failureCategoryNotFound;

  /// No description provided for @failureCategoryNameInvalid.
  ///
  /// In es, this message translates to:
  /// **'El nombre de la categoría debe tener entre 2 y 30 caracteres.'**
  String get failureCategoryNameInvalid;

  /// No description provided for @failureCategoryNameTaken.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes una categoría con ese nombre.'**
  String get failureCategoryNameTaken;

  /// No description provided for @failureInvalidSku.
  ///
  /// In es, this message translates to:
  /// **'El SKU debe tener de 2 a 32 letras sin tilde, números, guiones o puntos.'**
  String get failureInvalidSku;

  /// No description provided for @failureInvalidBarcode.
  ///
  /// In es, this message translates to:
  /// **'El código de barras debe tener de 4 a 32 letras o números.'**
  String get failureInvalidBarcode;

  /// No description provided for @failureProductCodeRepeated.
  ///
  /// In es, this message translates to:
  /// **'El código {code} está repetido en este producto.'**
  String failureProductCodeRepeated(String code);

  /// No description provided for @failureProductCodeTaken.
  ///
  /// In es, this message translates to:
  /// **'Ese código ya lo usa «{productName}».'**
  String failureProductCodeTaken(String productName);

  /// No description provided for @failureProductCodeTakenGeneric.
  ///
  /// In es, this message translates to:
  /// **'Ese código ya lo usa otro producto.'**
  String get failureProductCodeTakenGeneric;

  /// No description provided for @failureProductCodeNotFound.
  ///
  /// In es, this message translates to:
  /// **'Ningún producto tiene el código {code}.'**
  String failureProductCodeNotFound(String code);

  /// No description provided for @failureInvalidSalePrice.
  ///
  /// In es, this message translates to:
  /// **'El precio de venta debe ser mayor a 0.'**
  String get failureInvalidSalePrice;

  /// No description provided for @failureNegativeCostPrice.
  ///
  /// In es, this message translates to:
  /// **'El costo no puede ser negativo.'**
  String get failureNegativeCostPrice;

  /// No description provided for @failureCostAbovePrice.
  ///
  /// In es, this message translates to:
  /// **'El costo no puede ser mayor al precio de venta.'**
  String get failureCostAbovePrice;

  /// No description provided for @failureNegativeStock.
  ///
  /// In es, this message translates to:
  /// **'La cantidad no puede ser negativa.'**
  String get failureNegativeStock;

  /// No description provided for @failureIncompleteVariantOptions.
  ///
  /// In es, this message translates to:
  /// **'Revisa las variantes: cada tipo necesita un nombre y al menos un valor, sin repetir.'**
  String get failureIncompleteVariantOptions;

  /// No description provided for @failureInsufficientStock.
  ///
  /// In es, this message translates to:
  /// **'No hay stock suficiente de {productName}.'**
  String failureInsufficientStock(String productName);

  /// No description provided for @failureInsufficientStockGeneric.
  ///
  /// In es, this message translates to:
  /// **'No hay stock suficiente para esta venta.'**
  String get failureInsufficientStockGeneric;

  /// No description provided for @failureCameraPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permite el acceso a la cámara y a las fotos en los ajustes.'**
  String get failureCameraPermissionDenied;

  /// No description provided for @failureCameraUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la cámara. Intenta nuevamente.'**
  String get failureCameraUnavailable;

  /// No description provided for @failureBackgroundRemovalFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos quitar el fondo. Prueba con otra foto o más luz.'**
  String get failureBackgroundRemovalFailed;

  /// No description provided for @failureSaleNotFound.
  ///
  /// In es, this message translates to:
  /// **'No encontramos la venta.'**
  String get failureSaleNotFound;

  /// No description provided for @failureEmptyCart.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un producto para cobrar.'**
  String get failureEmptyCart;

  /// No description provided for @failureInsufficientPayment.
  ///
  /// In es, this message translates to:
  /// **'El monto recibido es menor al total.'**
  String get failureInsufficientPayment;

  /// No description provided for @failureCashSessionRequired.
  ///
  /// In es, this message translates to:
  /// **'Abre la caja antes de registrar una venta.'**
  String get failureCashSessionRequired;

  /// No description provided for @failureInvalidCopies.
  ///
  /// In es, this message translates to:
  /// **'Puedes imprimir entre 1 y {maxCopies} copias.'**
  String failureInvalidCopies(String maxCopies);

  /// No description provided for @failurePrintersUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos leer las impresoras vinculadas.'**
  String get failurePrintersUnavailable;

  /// No description provided for @failureBluetoothPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permite el acceso a dispositivos cercanos para usar la impresora.'**
  String get failureBluetoothPermissionDenied;

  /// No description provided for @failureBluetoothDisabled.
  ///
  /// In es, this message translates to:
  /// **'Activa el Bluetooth para imprimir.'**
  String get failureBluetoothDisabled;

  /// No description provided for @failurePrinterUnreachable.
  ///
  /// In es, this message translates to:
  /// **'No pudimos conectar con {printerName}. Revisa que esté encendida y cerca.'**
  String failurePrinterUnreachable(String printerName);

  /// No description provided for @failurePrinterNotResponding.
  ///
  /// In es, this message translates to:
  /// **'La impresora no respondió. Intenta nuevamente.'**
  String get failurePrinterNotResponding;

  /// No description provided for @failurePrinterTimeout.
  ///
  /// In es, this message translates to:
  /// **'La impresora tardó demasiado en responder.'**
  String get failurePrinterTimeout;

  /// No description provided for @failurePrintFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos imprimir el comprobante.'**
  String get failurePrintFailed;

  /// No description provided for @failureShareFailed.
  ///
  /// In es, this message translates to:
  /// **'No pudimos compartir el comprobante.'**
  String get failureShareFailed;

  /// No description provided for @failureWhatsAppUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No encontramos WhatsApp en este celular.'**
  String get failureWhatsAppUnavailable;

  /// No description provided for @failureEmailAppUnavailable.
  ///
  /// In es, this message translates to:
  /// **'No hay una app de correo configurada.'**
  String get failureEmailAppUnavailable;

  /// No description provided for @failurePhotoLibraryPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Permite el acceso a tus fotos para guardar.'**
  String get failurePhotoLibraryPermissionDenied;

  /// Bottom navigation: dashboard tab.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get shellHome;

  /// Bottom navigation: sales tab.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get shellSales;

  /// Bottom navigation: inventory tab.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get shellInventory;

  /// Tooltip of the close (x) button of bottom sheets and full-screen forms.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get commonCloseTooltip;

  /// Tooltip of the barcode scanner button inside the search bar.
  ///
  /// In es, this message translates to:
  /// **'Escanear código'**
  String get commonScanBarcodeTooltip;

  /// Quantity stepper: tooltip of the minus button when it deletes the line (quantity 1).
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get commonQuantityRemoveTooltip;

  /// Quantity stepper: tooltip of the minus button.
  ///
  /// In es, this message translates to:
  /// **'Restar uno'**
  String get commonQuantityDecrementTooltip;

  /// Quantity stepper: tooltip of the plus button.
  ///
  /// In es, this message translates to:
  /// **'Sumar uno'**
  String get commonQuantityIncrementTooltip;

  /// Step header of multi-step flows (registration). Rendered bold, followed by commonStepProgressLabel in a lighter style: "Paso 1 de 4 · Tu cuenta".
  ///
  /// In es, this message translates to:
  /// **'Paso {current} de {total}'**
  String commonStepProgress(int current, int total);

  /// Name of the current step, rendered right after commonStepProgress in a lighter style (hence the leading separator).
  ///
  /// In es, this message translates to:
  /// **' · {label}'**
  String commonStepProgressLabel(String label);

  /// Segment of the credential selector (sign in and registration).
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get authMethodEmail;

  /// Segment of the credential selector (sign in and registration).
  ///
  /// In es, this message translates to:
  /// **'Teléfono'**
  String get authMethodPhone;

  /// No description provided for @authPhoneNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Celular'**
  String get authPhoneNumberLabel;

  /// No description provided for @authEmailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get authEmailLabel;

  /// Example address shown as the email field placeholder.
  ///
  /// In es, this message translates to:
  /// **'tucorreo@gmail.com'**
  String get authEmailHint;

  /// No description provided for @authPasswordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get authPasswordLabel;

  /// No description provided for @authSendCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get authSendCode;

  /// No description provided for @authCreateAccount.
  ///
  /// In es, this message translates to:
  /// **'Crear cuenta'**
  String get authCreateAccount;

  /// No description provided for @authSignIn.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get authSignIn;

  /// No description provided for @authSignInTitle.
  ///
  /// In es, this message translates to:
  /// **'Hola de nuevo'**
  String get authSignInTitle;

  /// No description provided for @authSignInSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa para abrir tu caja y empezar a vender.'**
  String get authSignInSubtitle;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get authSignInWithGoogle;

  /// Text between the two lines that separate Google from the other sign-in methods.
  ///
  /// In es, this message translates to:
  /// **'o ingresa con'**
  String get authSignInDivider;

  /// No description provided for @authSignInPhoneHelper.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código por SMS.'**
  String get authSignInPhoneHelper;

  /// No description provided for @authSignInPasswordHint.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get authSignInPasswordHint;

  /// No description provided for @authSignInShowPassword.
  ///
  /// In es, this message translates to:
  /// **'Mostrar contraseña'**
  String get authSignInShowPassword;

  /// No description provided for @authSignInHidePassword.
  ///
  /// In es, this message translates to:
  /// **'Ocultar contraseña'**
  String get authSignInHidePassword;

  /// No description provided for @authSignInForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get authSignInForgotPassword;

  /// No description provided for @authSignInPasswordResetSent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un enlace a {email} para cambiar tu contraseña.'**
  String authSignInPasswordResetSent(String email);

  /// No description provided for @authSignInPasswordResetNeedsEmail.
  ///
  /// In es, this message translates to:
  /// **'Escribe tu correo y te enviamos un enlace para cambiar tu contraseña.'**
  String get authSignInPasswordResetNeedsEmail;

  /// Followed on the same line by the underlined authCreateAccount link.
  ///
  /// In es, this message translates to:
  /// **'¿Aún no tienes cuenta?'**
  String get authSignInNoAccountPrompt;

  /// Name of registration step 1, shown next to "Paso 1 de 4".
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta'**
  String get authRegisterStepLabel;

  /// No description provided for @authRegisterTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tu negocio y vende desde tu celular.'**
  String get authRegisterSubtitle;

  /// No description provided for @authRegisterWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Registrarme con Google'**
  String get authRegisterWithGoogle;

  /// Text between the two lines that separate Google from the other registration methods.
  ///
  /// In es, this message translates to:
  /// **'o regístrate con'**
  String get authRegisterDivider;

  /// No description provided for @authRegisterFullNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre y apellido'**
  String get authRegisterFullNameLabel;

  /// No description provided for @authRegisterFullNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Carla Mamani'**
  String get authRegisterFullNameHint;

  /// No description provided for @authRegisterPhoneHelper.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código por SMS para verificarlo.'**
  String get authRegisterPhoneHelper;

  /// No description provided for @authRegisterPasswordHelper.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres.'**
  String get authRegisterPasswordHelper;

  /// Terms checkbox, span 1 of 4: authRegisterTermsPrefix + authRegisterTermsLink (underlined) + authRegisterTermsConnector + authRegisterPrivacyPolicyLink (underlined) = "Acepto los Términos y la Política de privacidad". Keep the surrounding spaces.
  ///
  /// In es, this message translates to:
  /// **'Acepto los '**
  String get authRegisterTermsPrefix;

  /// Terms checkbox, span 2 of 4 (underlined). See authRegisterTermsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Términos'**
  String get authRegisterTermsLink;

  /// Terms checkbox, span 3 of 4. See authRegisterTermsPrefix. Keep the surrounding spaces.
  ///
  /// In es, this message translates to:
  /// **' y la '**
  String get authRegisterTermsConnector;

  /// Terms checkbox, span 4 of 4 (underlined). See authRegisterTermsPrefix.
  ///
  /// In es, this message translates to:
  /// **'Política de privacidad'**
  String get authRegisterPrivacyPolicyLink;

  /// Followed on the same line by the underlined authSignIn link.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta?'**
  String get authRegisterHaveAccountPrompt;

  /// Name of registration step 2, shown next to "Paso 2 de 4".
  ///
  /// In es, this message translates to:
  /// **'Verificación'**
  String get authPhoneVerificationStepLabel;

  /// No description provided for @authPhoneVerificationTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código'**
  String get authPhoneVerificationTitle;

  /// Followed by the phone number in bold ("+591 7654 3210"). Keep the trailing space.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos 6 dígitos por SMS al '**
  String get authPhoneVerificationSentTo;

  /// No description provided for @authPhoneVerificationChangeNumber.
  ///
  /// In es, this message translates to:
  /// **'Cambiar número'**
  String get authPhoneVerificationChangeNumber;

  /// No description provided for @authPhoneVerificationResendHint.
  ///
  /// In es, this message translates to:
  /// **'Si no te llega, pide otro código.'**
  String get authPhoneVerificationResendHint;

  /// No description provided for @authPhoneVerificationResend.
  ///
  /// In es, this message translates to:
  /// **'Reenviar'**
  String get authPhoneVerificationResend;

  /// No description provided for @authPhoneVerificationSubmit.
  ///
  /// In es, this message translates to:
  /// **'Verificar'**
  String get authPhoneVerificationSubmit;

  /// No description provided for @authPhoneVerificationViaWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'Recibir el código por WhatsApp'**
  String get authPhoneVerificationViaWhatsApp;

  /// No description provided for @authPhoneVerificationCodeResent.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos un nuevo código.'**
  String get authPhoneVerificationCodeResent;

  /// No description provided for @authPhoneVerificationCodeSentViaWhatsApp.
  ///
  /// In es, this message translates to:
  /// **'Te enviamos el código por WhatsApp.'**
  String get authPhoneVerificationCodeSentViaWhatsApp;

  /// Demo banner shown while no SMS is sent.
  ///
  /// In es, this message translates to:
  /// **'Usa el código {code}'**
  String authDemoCodeTitle(String code);

  /// No description provided for @authDemoCodeMessage.
  ///
  /// In es, this message translates to:
  /// **'Modo demo: no se envían SMS.'**
  String get authDemoCodeMessage;

  /// Fills the demo code in the code boxes.
  ///
  /// In es, this message translates to:
  /// **'Usar'**
  String get authDemoCodeUse;

  /// Name of registration step 3, shown next to "Paso 3 de 4".
  ///
  /// In es, this message translates to:
  /// **'Tu negocio'**
  String get authBusinessProfileStepLabel;

  /// No description provided for @authBusinessProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Sobre tu negocio'**
  String get authBusinessProfileTitle;

  /// No description provided for @authBusinessProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Lo usamos en tu POS y en tus comprobantes.'**
  String get authBusinessProfileSubtitle;

  /// No description provided for @authBusinessProfileLogoTitle.
  ///
  /// In es, this message translates to:
  /// **'Logo del negocio'**
  String get authBusinessProfileLogoTitle;

  /// No description provided for @authBusinessProfileLogoReady.
  ///
  /// In es, this message translates to:
  /// **'Listo. Toca para cambiarlo.'**
  String get authBusinessProfileLogoReady;

  /// No description provided for @authBusinessProfileLogoOptional.
  ///
  /// In es, this message translates to:
  /// **'Opcional. Aparece en tus comprobantes.'**
  String get authBusinessProfileLogoOptional;

  /// No description provided for @authBusinessProfileLogoSourceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aparece en tus comprobantes y en tu catálogo.'**
  String get authBusinessProfileLogoSourceSubtitle;

  /// No description provided for @authBusinessProfileNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del negocio'**
  String get authBusinessProfileNameLabel;

  /// No description provided for @authBusinessProfileNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Illimani Store'**
  String get authBusinessProfileNameHint;

  /// No description provided for @authBusinessProfileTypeLabel.
  ///
  /// In es, this message translates to:
  /// **'Tipo de negocio'**
  String get authBusinessProfileTypeLabel;

  /// No description provided for @authBusinessProfileDepartmentLabel.
  ///
  /// In es, this message translates to:
  /// **'Departamento'**
  String get authBusinessProfileDepartmentLabel;

  /// No description provided for @authBusinessTypeClothingAndFootwear.
  ///
  /// In es, this message translates to:
  /// **'Ropa y calzado'**
  String get authBusinessTypeClothingAndFootwear;

  /// No description provided for @authBusinessTypeNeighborhoodStore.
  ///
  /// In es, this message translates to:
  /// **'Tienda de barrio'**
  String get authBusinessTypeNeighborhoodStore;

  /// No description provided for @authBusinessTypeFoodAndDrinks.
  ///
  /// In es, this message translates to:
  /// **'Comida y bebidas'**
  String get authBusinessTypeFoodAndDrinks;

  /// No description provided for @authBusinessTypeBeautyAndCare.
  ///
  /// In es, this message translates to:
  /// **'Belleza y cuidado'**
  String get authBusinessTypeBeautyAndCare;

  /// No description provided for @authBusinessTypeTechnology.
  ///
  /// In es, this message translates to:
  /// **'Tecnología'**
  String get authBusinessTypeTechnology;

  /// No description provided for @authBusinessTypeOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get authBusinessTypeOther;

  /// Name of registration step 4, shown next to "Paso 4 de 4".
  ///
  /// In es, this message translates to:
  /// **'Cómo vendes'**
  String get authSalesSetupStepLabel;

  /// No description provided for @authSalesSetupTitle.
  ///
  /// In es, this message translates to:
  /// **'Últimos detalles'**
  String get authSalesSetupTitle;

  /// No description provided for @authSalesSetupSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Puedes cambiarlos cuando quieras.'**
  String get authSalesSetupSubtitle;

  /// No description provided for @authSalesSetupCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías de tu inventario'**
  String get authSalesSetupCategoriesTitle;

  /// Followed by the business type name in a stronger style ("Sugeridas para Ropa y calzado"). Keep the trailing space.
  ///
  /// In es, this message translates to:
  /// **'Sugeridas para '**
  String get authSalesSetupSuggestedFor;

  /// No description provided for @authSalesSetupPaymentMethodsTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cómo te pagan tus clientes?'**
  String get authSalesSetupPaymentMethodsTitle;

  /// No description provided for @authSalesSetupPaymentMethodsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aparecerán al momento de cobrar.'**
  String get authSalesSetupPaymentMethodsSubtitle;

  /// Bolivian tax identification number.
  ///
  /// In es, this message translates to:
  /// **'NIT'**
  String get authSalesSetupTaxIdLabel;

  /// No description provided for @authSalesSetupTaxIdOptional.
  ///
  /// In es, this message translates to:
  /// **'(opcional)'**
  String get authSalesSetupTaxIdOptional;

  /// No description provided for @authSalesSetupTaxIdHelper.
  ///
  /// In es, this message translates to:
  /// **'Si lo agregas, se muestra en tus comprobantes.'**
  String get authSalesSetupTaxIdHelper;

  /// No description provided for @authSalesSetupTaxIdHint.
  ///
  /// In es, this message translates to:
  /// **'Número de NIT'**
  String get authSalesSetupTaxIdHint;

  /// No description provided for @authSalesSetupSubmit.
  ///
  /// In es, this message translates to:
  /// **'Terminar registro'**
  String get authSalesSetupSubmit;

  /// Used in the title when the business has no name yet.
  ///
  /// In es, this message translates to:
  /// **'Tu negocio'**
  String get authBusinessReadyDefaultName;

  /// No description provided for @authBusinessReadyTitle.
  ///
  /// In es, this message translates to:
  /// **'¡{businessName} está lista!'**
  String authBusinessReadyTitle(String businessName);

  /// No description provided for @authBusinessReadySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta y tu punto de venta ya están configurados.'**
  String get authBusinessReadySubtitle;

  /// No description provided for @authBusinessReadyFirstStepsTitle.
  ///
  /// In es, this message translates to:
  /// **'Primeros pasos'**
  String get authBusinessReadyFirstStepsTitle;

  /// No description provided for @authBusinessReadyStepAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Crear tu cuenta'**
  String get authBusinessReadyStepAccountTitle;

  /// No description provided for @authBusinessReadyStepAccountDone.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get authBusinessReadyStepAccountDone;

  /// No description provided for @authBusinessReadyStepProductsTitle.
  ///
  /// In es, this message translates to:
  /// **'Agrega tus productos'**
  String get authBusinessReadyStepProductsTitle;

  /// No description provided for @authBusinessReadyStepProductsSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Con foto, precio y cantidad'**
  String get authBusinessReadyStepProductsSubtitle;

  /// No description provided for @authBusinessReadyStepSellTitle.
  ///
  /// In es, this message translates to:
  /// **'Abre tu caja y vende'**
  String get authBusinessReadyStepSellTitle;

  /// No description provided for @authBusinessReadyStepSellSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra tu primera venta'**
  String get authBusinessReadyStepSellSubtitle;

  /// No description provided for @authBusinessReadyAddFirstProduct.
  ///
  /// In es, this message translates to:
  /// **'Agregar mi primer producto'**
  String get authBusinessReadyAddFirstProduct;

  /// No description provided for @authBusinessReadyGoHome.
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get authBusinessReadyGoHome;

  /// No description provided for @dashboardLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el resumen del día.'**
  String get dashboardLoadError;

  /// No description provided for @dashboardNotificationsTooltip.
  ///
  /// In es, this message translates to:
  /// **'Notificaciones'**
  String get dashboardNotificationsTooltip;

  /// No description provided for @dashboardNoNotifications.
  ///
  /// In es, this message translates to:
  /// **'No tienes notificaciones nuevas.'**
  String get dashboardNoNotifications;

  /// Home greeting when the user's first name is unknown.
  ///
  /// In es, this message translates to:
  /// **'Hola'**
  String get dashboardGreeting;

  /// No description provided for @dashboardGreetingWithName.
  ///
  /// In es, this message translates to:
  /// **'Hola, {firstName}'**
  String dashboardGreetingWithName(String firstName);

  /// No description provided for @dashboardLowStockTitle.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto con stock bajo} other{{count} productos con stock bajo}}'**
  String dashboardLowStockTitle(int count);

  /// No description provided for @dashboardLowStockSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Revisa tu inventario'**
  String get dashboardLowStockSubtitle;

  /// No description provided for @dashboardCashCardNoShifts.
  ///
  /// In es, this message translates to:
  /// **'Sin turnos'**
  String get dashboardCashCardNoShifts;

  /// No description provided for @dashboardCashCardTodaySales.
  ///
  /// In es, this message translates to:
  /// **'Ventas de hoy'**
  String get dashboardCashCardTodaySales;

  /// Caption under the number of sales made today.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get dashboardCashCardSalesMetric;

  /// Caption under the average amount per sale ('prom.' = promedio).
  ///
  /// In es, this message translates to:
  /// **'Ticket prom.'**
  String get dashboardCashCardAverageTicketMetric;

  /// Caption under the cash currently in the drawer.
  ///
  /// In es, this message translates to:
  /// **'En caja'**
  String get dashboardCashCardCashInDrawerMetric;

  /// No description provided for @dashboardCashCardNewSale.
  ///
  /// In es, this message translates to:
  /// **'Nueva venta'**
  String get dashboardCashCardNewSale;

  /// No description provided for @dashboardCashCardOpenCashRegister.
  ///
  /// In es, this message translates to:
  /// **'Abrir caja'**
  String get dashboardCashCardOpenCashRegister;

  /// No description provided for @dashboardCashCardOpenSince.
  ///
  /// In es, this message translates to:
  /// **'Caja abierta · desde {time}'**
  String dashboardCashCardOpenSince(String time);

  /// No description provided for @dashboardCashCardClosed.
  ///
  /// In es, this message translates to:
  /// **'Caja cerrada'**
  String get dashboardCashCardClosed;

  /// No description provided for @dashboardPaymentBreakdownTitle.
  ///
  /// In es, this message translates to:
  /// **'Métodos de pago'**
  String get dashboardPaymentBreakdownTitle;

  /// Period the payment method breakdown covers.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get dashboardPaymentBreakdownPeriod;

  /// No description provided for @dashboardPaymentBreakdownEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no registraste ventas hoy.'**
  String get dashboardPaymentBreakdownEmpty;

  /// Header of the sales tab while the cash drawer is open.
  ///
  /// In es, this message translates to:
  /// **'Venta'**
  String get salesSaleTitle;

  /// Sale identifier shown under screen titles.
  ///
  /// In es, this message translates to:
  /// **'Venta {number}'**
  String salesSaleNumber(String number);

  /// Status pill on the sales header; tapping it manages the cash drawer.
  ///
  /// In es, this message translates to:
  /// **'Caja abierta'**
  String get salesCashRegisterOpenStatus;

  /// No description provided for @salesSearchProductHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto'**
  String get salesSearchProductHint;

  /// Bold first part of the cart header, followed by salesCartItemCountSuffix in a lighter style.
  ///
  /// In es, this message translates to:
  /// **'Carrito'**
  String get salesCartTitle;

  /// Lighter second part of the cart header, right after salesCartTitle: "Carrito · 3 artículos". Keep the leading space.
  ///
  /// In es, this message translates to:
  /// **' · {items}'**
  String salesCartItemCountSuffix(String items);

  /// No description provided for @salesCartClearButton.
  ///
  /// In es, this message translates to:
  /// **'Vaciar'**
  String get salesCartClearButton;

  /// No description provided for @salesCartEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'El carrito está vacío'**
  String get salesCartEmptyTitle;

  /// No description provided for @salesCartEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Busca o escanea un producto para empezar la venta.'**
  String get salesCartEmptyMessage;

  /// No description provided for @salesCartBrowseByCategory.
  ///
  /// In es, this message translates to:
  /// **'Explorar por categoría'**
  String get salesCartBrowseByCategory;

  /// Snackbar when the cart already holds all the stock of a product.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Solo queda 1 unidad de {productName}.} other{Solo quedan {count} unidades de {productName}.}}'**
  String salesStockLimitMessage(int count, String productName);

  /// Snackbar when the seller tries to add a product with no stock.
  ///
  /// In es, this message translates to:
  /// **'{productName} está agotado.'**
  String salesProductSoldOutMessage(String productName);

  /// Summary panel while the cart is empty.
  ///
  /// In es, this message translates to:
  /// **'Total · {items}'**
  String salesSummaryTotalItems(String items);

  /// Summary panel; followed by the subtotal amount in bold. Keep the trailing space.
  ///
  /// In es, this message translates to:
  /// **'Subtotal '**
  String get salesSummarySubtotalLabel;

  /// Opens the discount sheet while no discount is applied.
  ///
  /// In es, this message translates to:
  /// **'Descuento'**
  String get salesSummaryDiscountButton;

  /// Main button of the summary panel; the total is shown next to it.
  ///
  /// In es, this message translates to:
  /// **'Cobrar'**
  String get salesSummaryChargeButton;

  /// No description provided for @salesDiscountSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Aplicar descuento'**
  String get salesDiscountSheetTitle;

  /// No description provided for @salesDiscountSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Se resta del total de la venta.'**
  String get salesDiscountSheetSubtitle;

  /// No description provided for @salesDiscountSheetAmountLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto del descuento'**
  String get salesDiscountSheetAmountLabel;

  /// No description provided for @salesDiscountSheetApplyButton.
  ///
  /// In es, this message translates to:
  /// **'Aplicar'**
  String get salesDiscountSheetApplyButton;

  /// Product count on a category shortcut of the empty cart.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto} other{{count} productos}}'**
  String salesCategoryProductCount(int count);

  /// No description provided for @salesProductSoldOutBadge.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get salesProductSoldOutBadge;

  /// No description provided for @salesProductInStock.
  ///
  /// In es, this message translates to:
  /// **'{count} en stock'**
  String salesProductInStock(int count);

  /// No description provided for @salesProductOutOfStock.
  ///
  /// In es, this message translates to:
  /// **'Sin stock'**
  String get salesProductOutOfStock;

  /// No description provided for @salesProductAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Agregar {productName}'**
  String salesProductAddTooltip(String productName);

  /// Unit price under a cart line ("c/u" = cada uno).
  ///
  /// In es, this message translates to:
  /// **'{price} c/u'**
  String salesCartLineUnitPrice(String price);

  /// No description provided for @salesSearchBackTooltip.
  ///
  /// In es, this message translates to:
  /// **'Volver a la venta'**
  String get salesSearchBackTooltip;

  /// No description provided for @salesSearchHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre o código'**
  String get salesSearchHint;

  /// Category filter chip that shows every product.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get salesSearchAllCategories;

  /// No description provided for @salesSearchNoResultsTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin resultados'**
  String get salesSearchNoResultsTitle;

  /// No description provided for @salesSearchNoResultsMessage.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro nombre o cambia de categoría.'**
  String get salesSearchNoResultsMessage;

  /// No description provided for @salesSearchViewSaleButton.
  ///
  /// In es, this message translates to:
  /// **'Ver venta'**
  String get salesSearchViewSaleButton;

  /// No description provided for @salesCheckoutTitle.
  ///
  /// In es, this message translates to:
  /// **'Cobrar venta'**
  String get salesCheckoutTitle;

  /// No description provided for @salesCheckoutSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Venta {number} · {items}'**
  String salesCheckoutSubtitle(String number, String items);

  /// No description provided for @salesCheckoutTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total a cobrar'**
  String get salesCheckoutTotalLabel;

  /// No description provided for @salesCheckoutSeeDetailButton.
  ///
  /// In es, this message translates to:
  /// **'Ver detalle'**
  String get salesCheckoutSeeDetailButton;

  /// No description provided for @salesCheckoutPaymentMethodLabel.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get salesCheckoutPaymentMethodLabel;

  /// No description provided for @salesCheckoutAmountReceivedLabel.
  ///
  /// In es, this message translates to:
  /// **'Monto recibido'**
  String get salesCheckoutAmountReceivedLabel;

  /// Quick amount chip that fills in the exact total.
  ///
  /// In es, this message translates to:
  /// **'Exacto'**
  String get salesCheckoutExactAmount;

  /// No description provided for @salesCheckoutChangeTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambio a devolver'**
  String get salesCheckoutChangeTitle;

  /// No description provided for @salesCheckoutConfirmButton.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cobro'**
  String get salesCheckoutConfirmButton;

  /// No description provided for @salesCompletedTitle.
  ///
  /// In es, this message translates to:
  /// **'Venta registrada'**
  String get salesCompletedTitle;

  /// No description provided for @salesCompletedSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Venta {number} · {date}, {time}'**
  String salesCompletedSubtitle(String number, String date, String time);

  /// No description provided for @salesCompletedDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Detalle'**
  String get salesCompletedDetailTitle;

  /// No description provided for @salesCompletedTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get salesCompletedTotalLabel;

  /// No description provided for @salesCompletedReceivedLabel.
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get salesCompletedReceivedLabel;

  /// No description provided for @salesCompletedChangeLabel.
  ///
  /// In es, this message translates to:
  /// **'Cambio'**
  String get salesCompletedChangeLabel;

  /// No description provided for @salesCompletedNewSaleButton.
  ///
  /// In es, this message translates to:
  /// **'Nueva venta'**
  String get salesCompletedNewSaleButton;

  /// No description provided for @salesCompletedGoHomeButton.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get salesCompletedGoHomeButton;

  /// Action that opens the receipt of the sale.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get salesReceiptActionView;

  /// Action that opens the print sheet of the receipt.
  ///
  /// In es, this message translates to:
  /// **'Imprimir'**
  String get salesReceiptActionPrint;

  /// Action that opens the share sheet of the receipt.
  ///
  /// In es, this message translates to:
  /// **'Compartir'**
  String get salesReceiptActionShare;

  /// No description provided for @salesReceiptScreenTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprobante'**
  String get salesReceiptScreenTitle;

  /// Store location on the on-screen receipt header. {country} is receiptCountry.
  ///
  /// In es, this message translates to:
  /// **'{department}, {country}'**
  String salesReceiptStoreLocation(String department, String country);

  /// On-screen receipt header line when the store has a tax id. {location} is the store location and {taxId} is receiptTaxId.
  ///
  /// In es, this message translates to:
  /// **'{location} · {taxId}'**
  String salesReceiptStoreDetails(String location, String taxId);

  /// No description provided for @salesPrintSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Imprimir comprobante'**
  String get salesPrintSheetTitle;

  /// No description provided for @salesPrintSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'N° {number} · {total}'**
  String salesPrintSheetSubtitle(String number, String total);

  /// No description provided for @salesPrintSheetPrinterLabel.
  ///
  /// In es, this message translates to:
  /// **'Impresora'**
  String get salesPrintSheetPrinterLabel;

  /// No description provided for @salesPrintSheetNoPrinters.
  ///
  /// In es, this message translates to:
  /// **'No hay impresoras vinculadas. Vincula tu impresora térmica desde los ajustes de Bluetooth del celular.'**
  String get salesPrintSheetNoPrinters;

  /// No description provided for @salesPrintSheetSearchPrinters.
  ///
  /// In es, this message translates to:
  /// **'Buscar impresoras vinculadas'**
  String get salesPrintSheetSearchPrinters;

  /// No description provided for @salesPrintSheetPaperLabel.
  ///
  /// In es, this message translates to:
  /// **'Papel'**
  String get salesPrintSheetPaperLabel;

  /// No description provided for @salesPrintSheetCopiesLabel.
  ///
  /// In es, this message translates to:
  /// **'Copias'**
  String get salesPrintSheetCopiesLabel;

  /// No description provided for @salesPrintSheetPrintButton.
  ///
  /// In es, this message translates to:
  /// **'Imprimir'**
  String get salesPrintSheetPrintButton;

  /// No description provided for @salesPrintSheetPrintedMessage.
  ///
  /// In es, this message translates to:
  /// **'Comprobante enviado a la impresora.'**
  String get salesPrintSheetPrintedMessage;

  /// No description provided for @salesShareSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Compartir comprobante'**
  String get salesShareSheetTitle;

  /// No description provided for @salesShareSheetReceiptSummary.
  ///
  /// In es, this message translates to:
  /// **'{total} · {paymentMethod} · {items}'**
  String salesShareSheetReceiptSummary(
    String total,
    String paymentMethod,
    String items,
  );

  /// No description provided for @salesShareSheetFormatLabel.
  ///
  /// In es, this message translates to:
  /// **'Formato'**
  String get salesShareSheetFormatLabel;

  /// No description provided for @salesShareSheetImageFormat.
  ///
  /// In es, this message translates to:
  /// **'Imagen'**
  String get salesShareSheetImageFormat;

  /// No description provided for @salesShareSheetWhatsAppLabel.
  ///
  /// In es, this message translates to:
  /// **'Enviar al WhatsApp del cliente'**
  String get salesShareSheetWhatsAppLabel;

  /// No description provided for @salesShareSheetPhoneHint.
  ///
  /// In es, this message translates to:
  /// **'Número de celular'**
  String get salesShareSheetPhoneHint;

  /// No description provided for @salesShareSheetWhatsAppTooltip.
  ///
  /// In es, this message translates to:
  /// **'Enviar por WhatsApp'**
  String get salesShareSheetWhatsAppTooltip;

  /// No description provided for @salesShareSheetWhatsAppHint.
  ///
  /// In es, this message translates to:
  /// **'Se envía el detalle de la venta como mensaje.'**
  String get salesShareSheetWhatsAppHint;

  /// Share destination that saves the receipt on the device.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get salesShareSheetSaveTarget;

  /// No description provided for @salesShareSheetEmailTarget.
  ///
  /// In es, this message translates to:
  /// **'Correo'**
  String get salesShareSheetEmailTarget;

  /// No description provided for @salesShareSheetOtherAppsTarget.
  ///
  /// In es, this message translates to:
  /// **'Otras apps'**
  String get salesShareSheetOtherAppsTarget;

  /// No description provided for @salesShareSheetWhatsAppOpening.
  ///
  /// In es, this message translates to:
  /// **'Abriendo WhatsApp con el comprobante…'**
  String get salesShareSheetWhatsAppOpening;

  /// No description provided for @salesShareSheetEmailOpening.
  ///
  /// In es, this message translates to:
  /// **'Abriendo tu app de correo…'**
  String get salesShareSheetEmailOpening;

  /// No description provided for @salesShareSheetSaved.
  ///
  /// In es, this message translates to:
  /// **'Comprobante guardado.'**
  String get salesShareSheetSaved;

  /// No description provided for @salesShareSheetReady.
  ///
  /// In es, this message translates to:
  /// **'Comprobante listo para compartir.'**
  String get salesShareSheetReady;

  /// No description provided for @receiptNumberLabel.
  ///
  /// In es, this message translates to:
  /// **'Comprobante N°'**
  String get receiptNumberLabel;

  /// No description provided for @receiptNumberTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprobante N° {number}'**
  String receiptNumberTitle(String number);

  /// No description provided for @receiptDocumentTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprobante {number}'**
  String receiptDocumentTitle(String number);

  /// No description provided for @receiptEmailSubject.
  ///
  /// In es, this message translates to:
  /// **'Comprobante N° {number} · {businessName}'**
  String receiptEmailSubject(String number, String businessName);

  /// Name of exported receipt files, without extension.
  ///
  /// In es, this message translates to:
  /// **'comprobante-{number}'**
  String receiptFileName(String number);

  /// No description provided for @receiptDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get receiptDateLabel;

  /// No description provided for @receiptCashierLabel.
  ///
  /// In es, this message translates to:
  /// **'Atendió'**
  String get receiptCashierLabel;

  /// No description provided for @receiptSubtotalLabel.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get receiptSubtotalLabel;

  /// No description provided for @receiptDiscountLabel.
  ///
  /// In es, this message translates to:
  /// **'Descuento'**
  String get receiptDiscountLabel;

  /// No description provided for @receiptTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'TOTAL'**
  String get receiptTotalLabel;

  /// No description provided for @receiptChangeLabel.
  ///
  /// In es, this message translates to:
  /// **'Cambio'**
  String get receiptChangeLabel;

  /// No description provided for @receiptTaxId.
  ///
  /// In es, this message translates to:
  /// **'NIT {taxId}'**
  String receiptTaxId(String taxId);

  /// No description provided for @receiptCountry.
  ///
  /// In es, this message translates to:
  /// **'Bolivia'**
  String get receiptCountry;

  /// No description provided for @receiptThanks.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu compra!'**
  String get receiptThanks;

  /// No description provided for @receiptMadeWith.
  ///
  /// In es, this message translates to:
  /// **'Hecho con Cumavi POS'**
  String get receiptMadeWith;

  /// Followed by the Cumavi logo and the product name on the on-screen receipt.
  ///
  /// In es, this message translates to:
  /// **'Hecho con'**
  String get receiptMadeWithPrefix;

  /// Header of the Ventas tab while the cash drawer is closed (same name as the shellSales tab).
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get cashRegisterTitle;

  /// Status pill next to the header while the cash drawer is closed.
  ///
  /// In es, this message translates to:
  /// **'Caja cerrada'**
  String get cashRegisterClosedStatus;

  /// No description provided for @cashRegisterOpenHeadline.
  ///
  /// In es, this message translates to:
  /// **'Abre la caja para empezar a vender'**
  String get cashRegisterOpenHeadline;

  /// No description provided for @cashRegisterOpenDescription.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el efectivo con el que inicias el día. La caja queda abierta hasta que la cierres.'**
  String get cashRegisterOpenDescription;

  /// Label of the opening float input when opening the cash drawer.
  ///
  /// In es, this message translates to:
  /// **'Monto inicial en efectivo'**
  String get cashRegisterOpeningAmountLabel;

  /// No description provided for @cashRegisterCashierLabel.
  ///
  /// In es, this message translates to:
  /// **'Cajero'**
  String get cashRegisterCashierLabel;

  /// Shown as the cashier name while nobody is signed in.
  ///
  /// In es, this message translates to:
  /// **'Sin cajero'**
  String get cashRegisterNoCashier;

  /// Label of the opening date and time of the cash drawer.
  ///
  /// In es, this message translates to:
  /// **'Apertura'**
  String get cashRegisterOpenedAtLabel;

  /// No description provided for @cashRegisterOpenAction.
  ///
  /// In es, this message translates to:
  /// **'Abrir caja'**
  String get cashRegisterOpenAction;

  /// Fallback error when opening the cash drawer fails without a specific reason.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir la caja.'**
  String get cashRegisterOpenFailed;

  /// No description provided for @cashRegisterCloseTitle.
  ///
  /// In es, this message translates to:
  /// **'Cerrar caja'**
  String get cashRegisterCloseTitle;

  /// Subtitle of the close-drawer screen. {time} is the opening time, already formatted.
  ///
  /// In es, this message translates to:
  /// **'Abierta hoy desde las {time}'**
  String cashRegisterCloseSubtitle(String time);

  /// Fallback error when the close-drawer report cannot be loaded.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el cierre de caja.'**
  String get cashRegisterCloseLoadFailed;

  /// Close-drawer report row: opening float.
  ///
  /// In es, this message translates to:
  /// **'Monto inicial'**
  String get cashRegisterOpeningAmount;

  /// Close-drawer report row: total sold with one payment method. {method} is the payment method name (paymentMethod* keys), lower-cased in code.
  ///
  /// In es, this message translates to:
  /// **'Ventas con {method}'**
  String cashRegisterSalesByMethod(String method);

  /// Close-drawer report: total of the day. Rendered bold, followed by cashRegisterSaleCount in a lighter style: "Total vendido · 12 ventas".
  ///
  /// In es, this message translates to:
  /// **'Total vendido'**
  String get cashRegisterTotalSold;

  /// Number of sales, rendered right after cashRegisterTotalSold in a lighter style (hence the leading separator).
  ///
  /// In es, this message translates to:
  /// **' · {count, plural, =1{1 venta} other{{count} ventas}}'**
  String cashRegisterSaleCount(int count);

  /// No description provided for @cashRegisterExpectedCash.
  ///
  /// In es, this message translates to:
  /// **'Efectivo esperado'**
  String get cashRegisterExpectedCash;

  /// Explains how the expected cash in the drawer is computed.
  ///
  /// In es, this message translates to:
  /// **'Monto inicial + ventas en efectivo'**
  String get cashRegisterExpectedCashFormula;

  /// Label of the input where the cashier types the cash counted in the drawer.
  ///
  /// In es, this message translates to:
  /// **'Efectivo contado'**
  String get cashRegisterCountedCashLabel;

  /// Banner title when the counted cash is below the expected cash.
  ///
  /// In es, this message translates to:
  /// **'Faltante'**
  String get cashRegisterShortage;

  /// Banner title when the counted cash is above the expected cash.
  ///
  /// In es, this message translates to:
  /// **'Sobrante'**
  String get cashRegisterSurplus;

  /// No description provided for @cashRegisterNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Observación'**
  String get cashRegisterNoteLabel;

  /// No description provided for @cashRegisterNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Explica la diferencia (opcional)'**
  String get cashRegisterNoteHint;

  /// No description provided for @cashRegisterConfirmClose.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cierre'**
  String get cashRegisterConfirmClose;

  /// No description provided for @catalogInventoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Inventario'**
  String get catalogInventoryTitle;

  /// No description provided for @catalogInventorySearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto'**
  String get catalogInventorySearchHint;

  /// Category filter chip that shows every product.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get catalogInventoryFilterAll;

  /// Inventory subtitle: how many products the list shows. May be followed by catalogInventoryLowStockSuffix.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto} other{{count} productos}}'**
  String catalogInventoryProductCount(int count);

  /// Appended right after catalogInventoryProductCount, in warning color, when some products are low on stock. Keep the leading separator.
  ///
  /// In es, this message translates to:
  /// **' · {count} con stock bajo'**
  String catalogInventoryLowStockSuffix(int count);

  /// No description provided for @catalogInventoryCreateProduct.
  ///
  /// In es, this message translates to:
  /// **'Crear producto'**
  String get catalogInventoryCreateProduct;

  /// No description provided for @catalogInventoryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Sin productos'**
  String get catalogInventoryEmptyTitle;

  /// No description provided for @catalogInventoryEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Crea tu primer producto para empezar a vender.'**
  String get catalogInventoryEmptyMessage;

  /// Second line of an inventory row: category and cost price.
  ///
  /// In es, this message translates to:
  /// **'{categoryName} · Costo {cost}'**
  String catalogProductTileSubtitle(String categoryName, String cost);

  /// Stock badge of a product with healthy stock; 'u.' abbreviates units.
  ///
  /// In es, this message translates to:
  /// **'{count} u.'**
  String catalogStockBadgeUnits(int count);

  /// Stock badge of a product that is running low.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Queda 1} other{Quedan {count}}}'**
  String catalogStockBadgeLow(int count);

  /// No description provided for @catalogStockBadgeOutOfStock.
  ///
  /// In es, this message translates to:
  /// **'Agotado'**
  String get catalogStockBadgeOutOfStock;

  /// No description provided for @catalogProductFormTitle.
  ///
  /// In es, this message translates to:
  /// **'Nuevo producto'**
  String get catalogProductFormTitle;

  /// No description provided for @catalogProductFormNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get catalogProductFormNameLabel;

  /// No description provided for @catalogProductFormNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Zapatillas urbanas café'**
  String get catalogProductFormNameHint;

  /// No description provided for @catalogProductFormCategoryLabel.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get catalogProductFormCategoryLabel;

  /// No description provided for @catalogProductFormQuantityLabel.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get catalogProductFormQuantityLabel;

  /// No description provided for @catalogProductFormQuantityCaption.
  ///
  /// In es, this message translates to:
  /// **'Unidades en stock'**
  String get catalogProductFormQuantityCaption;

  /// No description provided for @catalogProductFormSalePriceLabel.
  ///
  /// In es, this message translates to:
  /// **'Precio de venta'**
  String get catalogProductFormSalePriceLabel;

  /// No description provided for @catalogProductFormCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo'**
  String get catalogProductFormCostLabel;

  /// Profit per unit ('c/u' = cada uno).
  ///
  /// In es, this message translates to:
  /// **'Ganancia c/u'**
  String get catalogProductFormProfitTitle;

  /// Profit per unit and margin shown next to catalogProductFormProfitTitle.
  ///
  /// In es, this message translates to:
  /// **'{amount} · {margin}'**
  String catalogProductFormProfitValue(String amount, String margin);

  /// No description provided for @catalogProductFormSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar producto'**
  String get catalogProductFormSave;

  /// Label of the switch that removes the photo background in the product form.
  ///
  /// In es, this message translates to:
  /// **'Quitar fondo'**
  String get catalogPhotoFieldRemoveBackgroundLabel;

  /// No description provided for @catalogPhotoFieldRemoveBackgroundDescription.
  ///
  /// In es, this message translates to:
  /// **'El producto queda sobre fondo blanco'**
  String get catalogPhotoFieldRemoveBackgroundDescription;

  /// No description provided for @catalogPhotoFieldProcessing.
  ///
  /// In es, this message translates to:
  /// **'Procesando la foto…'**
  String get catalogPhotoFieldProcessing;

  /// No description provided for @catalogPhotoFieldEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto del producto'**
  String get catalogPhotoFieldEmptyTitle;

  /// No description provided for @catalogPhotoFieldEmptySubtitle.
  ///
  /// In es, this message translates to:
  /// **'Le quitamos el fondo por ti'**
  String get catalogPhotoFieldEmptySubtitle;

  /// No description provided for @catalogPhotoFieldBackgroundRemovedBadge.
  ///
  /// In es, this message translates to:
  /// **'Fondo quitado'**
  String get catalogPhotoFieldBackgroundRemovedBadge;

  /// Opens the background removal editor.
  ///
  /// In es, this message translates to:
  /// **'Ajustar'**
  String get catalogPhotoFieldAdjust;

  /// No description provided for @catalogPhotoFieldChangePhotoTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar foto'**
  String get catalogPhotoFieldChangePhotoTooltip;

  /// No description provided for @catalogPhotoSourceTitle.
  ///
  /// In es, this message translates to:
  /// **'Foto del producto'**
  String get catalogPhotoSourceTitle;

  /// No description provided for @catalogPhotoSourceSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Le quitamos el fondo automáticamente.'**
  String get catalogPhotoSourceSubtitle;

  /// No description provided for @catalogPhotoSourceCamera.
  ///
  /// In es, this message translates to:
  /// **'Tomar foto'**
  String get catalogPhotoSourceCamera;

  /// No description provided for @catalogPhotoSourceCameraDescription.
  ///
  /// In es, this message translates to:
  /// **'Usa la cámara del celular'**
  String get catalogPhotoSourceCameraDescription;

  /// No description provided for @catalogPhotoSourceGallery.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get catalogPhotoSourceGallery;

  /// No description provided for @catalogPhotoSourceGalleryDescription.
  ///
  /// In es, this message translates to:
  /// **'Una foto que ya tengas guardada'**
  String get catalogPhotoSourceGalleryDescription;

  /// No description provided for @catalogBackgroundRemovalNoPhoto.
  ///
  /// In es, this message translates to:
  /// **'Toma una foto del producto para editarla.'**
  String get catalogBackgroundRemovalNoPhoto;

  /// No description provided for @catalogBackgroundRemovalTitle.
  ///
  /// In es, this message translates to:
  /// **'Quitar fondo'**
  String get catalogBackgroundRemovalTitle;

  /// Shown under the editor title while the product has no name yet.
  ///
  /// In es, this message translates to:
  /// **'Foto del producto'**
  String get catalogBackgroundRemovalDefaultSubtitle;

  /// No description provided for @catalogBackgroundRemovalDone.
  ///
  /// In es, this message translates to:
  /// **'Fondo quitado'**
  String get catalogBackgroundRemovalDone;

  /// No description provided for @catalogBackgroundRemovalCompareHint.
  ///
  /// In es, this message translates to:
  /// **'Desliza para comparar'**
  String get catalogBackgroundRemovalCompareHint;

  /// No description provided for @catalogBackgroundRemovalRetake.
  ///
  /// In es, this message translates to:
  /// **'Repetir foto'**
  String get catalogBackgroundRemovalRetake;

  /// No description provided for @catalogBackgroundRemovalUsePhoto.
  ///
  /// In es, this message translates to:
  /// **'Usar foto'**
  String get catalogBackgroundRemovalUsePhoto;

  /// No description provided for @catalogBackgroundOptionWhite.
  ///
  /// In es, this message translates to:
  /// **'Blanco'**
  String get catalogBackgroundOptionWhite;

  /// No description provided for @catalogBackgroundOptionTransparent.
  ///
  /// In es, this message translates to:
  /// **'Transparente'**
  String get catalogBackgroundOptionTransparent;

  /// Background option that keeps the photo as taken.
  ///
  /// In es, this message translates to:
  /// **'Original'**
  String get catalogBackgroundOptionOriginal;

  /// Tag on the unprocessed side of the before/after photo comparison.
  ///
  /// In es, this message translates to:
  /// **'Original'**
  String get catalogBeforeAfterBeforeLabel;

  /// Tag on the processed side of the before/after photo comparison.
  ///
  /// In es, this message translates to:
  /// **'Sin fondo'**
  String get catalogBeforeAfterAfterLabel;

  /// Inventory row, third line of a product with variants: how many variants and the ways it varies.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 variante · {options}} other{{count} variantes · {options}}}'**
  String catalogProductTileVariantSummary(int count, String options);

  /// Header of the product detail screen, opened from the inventory.
  ///
  /// In es, this message translates to:
  /// **'Producto'**
  String get catalogDetailTitle;

  /// Bottom button and pencil tooltip of the product detail; opens the edit form.
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get catalogDetailEdit;

  /// Title of the product detail when the product could not be loaded; the failure message goes below.
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar el producto'**
  String get catalogDetailLoadErrorTitle;

  /// Accessibility label of a gallery thumbnail.
  ///
  /// In es, this message translates to:
  /// **'Foto {current} de {total}'**
  String catalogDetailPhotoLabel(int current, int total);

  /// Section with the sale price, cost, profit per unit and margin.
  ///
  /// In es, this message translates to:
  /// **'Precios'**
  String get catalogDetailPricesTitle;

  /// Section with the units in stock and, for products with variants, how many are sold out.
  ///
  /// In es, this message translates to:
  /// **'Stock'**
  String get catalogDetailStockTitle;

  /// Label next to the big units number of the stock section.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{unidad en stock} other{unidades en stock}}'**
  String catalogDetailStockUnits(int count);

  /// Stock section of a product with variants: how many variants have no units left.
  ///
  /// In es, this message translates to:
  /// **'Variantes agotadas'**
  String get catalogDetailStockSoldOutLabel;

  /// Section with the product description.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get catalogDetailDescriptionTitle;

  /// Section listing the variants (color, size...) with their stock.
  ///
  /// In es, this message translates to:
  /// **'Variantes'**
  String get catalogDetailVariantsTitle;

  /// Next to catalogDetailVariantsTitle: how many variants the product has.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 variante} other{{count} variantes}}'**
  String catalogDetailVariantCount(int count);

  /// Under a variant group (e.g. color Rojo): how many of its variants are sold out.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Todas con stock} =1{1 agotada} other{{count} agotadas}}'**
  String catalogDetailGroupSoldOut(int count);

  /// Bottom of the product detail: when the product was added to the inventory.
  ///
  /// In es, this message translates to:
  /// **'Agregado el {date}'**
  String catalogDetailCreatedAt(DateTime date);

  /// Tooltip of a variant photo; tapping it shows the photo larger.
  ///
  /// In es, this message translates to:
  /// **'Ver foto'**
  String get catalogDetailViewPhotoTooltip;

  /// Header of the product form when editing an existing product (catalogProductFormTitle is the create one).
  ///
  /// In es, this message translates to:
  /// **'Editar producto'**
  String get catalogProductFormEditTitle;

  /// Save button of the product form in edit mode (catalogProductFormSave is the create one).
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get catalogProductFormSaveChanges;

  /// Title shown when the product to edit could not be read; the failure message follows.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir el producto'**
  String get catalogProductFormLoadErrorTitle;

  /// No description provided for @catalogProductFormDataSection.
  ///
  /// In es, this message translates to:
  /// **'Datos del producto'**
  String get catalogProductFormDataSection;

  /// No description provided for @catalogProductFormPriceSection.
  ///
  /// In es, this message translates to:
  /// **'Precio'**
  String get catalogProductFormPriceSection;

  /// Title of the card with the product stock and its variants (sizes, colors...).
  ///
  /// In es, this message translates to:
  /// **'Stock y variantes'**
  String get catalogProductFormStockSection;

  /// Shown right after a field label that can be left empty.
  ///
  /// In es, this message translates to:
  /// **'(opcional)'**
  String get catalogProductFormOptional;

  /// No description provided for @catalogProductFormDescriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get catalogProductFormDescriptionLabel;

  /// No description provided for @catalogProductFormDescriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Material, cuidados o detalles que ayuden a vender'**
  String get catalogProductFormDescriptionHint;

  /// Title of the strip of extra product photos below the main one.
  ///
  /// In es, this message translates to:
  /// **'Más fotos'**
  String get catalogProductFormGalleryTitle;

  /// No description provided for @catalogProductFormGalleryCaption.
  ///
  /// In es, this message translates to:
  /// **'Otros colores o ángulos. Cada variante puede usar una de estas fotos.'**
  String get catalogProductFormGalleryCaption;

  /// Label of the tile that adds one more photo to the product gallery.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get catalogProductFormGalleryAdd;

  /// No description provided for @catalogProductFormGalleryRemoveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar foto'**
  String get catalogProductFormGalleryRemoveTooltip;

  /// Title of the camera/gallery sheet when adding an extra photo.
  ///
  /// In es, this message translates to:
  /// **'Agregar foto'**
  String get catalogProductFormGallerySourceTitle;

  /// Extra photos keep their background; only the main photo gets it removed.
  ///
  /// In es, this message translates to:
  /// **'Se guarda tal cual, sin quitar el fondo.'**
  String get catalogProductFormGallerySourceSubtitle;

  /// Action that turns a simple product into one with variants.
  ///
  /// In es, this message translates to:
  /// **'Agregar variantes (talla, color…)'**
  String get catalogProductFormAddVariants;

  /// No description provided for @catalogProductFormAddVariantsCaption.
  ///
  /// In es, this message translates to:
  /// **'Vende por talla o color, con stock para cada una.'**
  String get catalogProductFormAddVariantsCaption;

  /// Total stock of a product with variants, next to the stock card title.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 unidad} other{{count} unidades}}'**
  String catalogProductFormTotalStock(int count);

  /// Sheet to add a way the product varies (color, size...).
  ///
  /// In es, this message translates to:
  /// **'Tipo de variante'**
  String get catalogVariantTypeSheetTitle;

  /// No description provided for @catalogVariantTypeSheetSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Elige uno o escribe otro, como Material.'**
  String get catalogVariantTypeSheetSubtitle;

  /// Name of the color variant type. Also used to offer common colors as suggestions.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get catalogVariantTypeColor;

  /// No description provided for @catalogVariantTypeColorDescription.
  ///
  /// In es, this message translates to:
  /// **'Negro, blanco, rojo…'**
  String get catalogVariantTypeColorDescription;

  /// Name of the size variant type. Also used to offer common sizes as suggestions.
  ///
  /// In es, this message translates to:
  /// **'Talla'**
  String get catalogVariantTypeSize;

  /// No description provided for @catalogVariantTypeSizeDescription.
  ///
  /// In es, this message translates to:
  /// **'S, M, L o números como 38 y 40'**
  String get catalogVariantTypeSizeDescription;

  /// No description provided for @catalogVariantTypeCustomLabel.
  ///
  /// In es, this message translates to:
  /// **'Otro tipo'**
  String get catalogVariantTypeCustomLabel;

  /// No description provided for @catalogVariantTypeCustomHint.
  ///
  /// In es, this message translates to:
  /// **'Ej. Material'**
  String get catalogVariantTypeCustomHint;

  /// Button that adds the variant type typed by the seller.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get catalogVariantTypeAdd;

  /// Sheet to rename a variant type.
  ///
  /// In es, this message translates to:
  /// **'Cambiar nombre'**
  String get catalogVariantTypeRenameTitle;

  /// No description provided for @catalogVariantTypeNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del tipo'**
  String get catalogVariantTypeNameLabel;

  /// Comma-separated quick values offered for the size type. No spaces around commas.
  ///
  /// In es, this message translates to:
  /// **'S,M,L,XL'**
  String get catalogVariantSizeSuggestions;

  /// Comma-separated quick values offered for the color type. No spaces around commas.
  ///
  /// In es, this message translates to:
  /// **'Negro,Blanco,Rojo,Azul,Gris'**
  String get catalogVariantColorSuggestions;

  /// Hint of the input that adds a value to a variant type.
  ///
  /// In es, this message translates to:
  /// **'Nuevo valor de {option}'**
  String catalogVariantValueHint(String option);

  /// No description provided for @catalogVariantValueAddTooltip.
  ///
  /// In es, this message translates to:
  /// **'Agregar valor'**
  String get catalogVariantValueAddTooltip;

  /// No description provided for @catalogVariantValueRemoveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar {value}'**
  String catalogVariantValueRemoveTooltip(String value);

  /// No description provided for @catalogVariantOptionEmptyHint.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un valor para crear las variantes.'**
  String get catalogVariantOptionEmptyHint;

  /// No description provided for @catalogVariantOptionRenameTooltip.
  ///
  /// In es, this message translates to:
  /// **'Cambiar nombre'**
  String get catalogVariantOptionRenameTooltip;

  /// No description provided for @catalogVariantOptionRemoveTooltip.
  ///
  /// In es, this message translates to:
  /// **'Quitar tipo'**
  String get catalogVariantOptionRemoveTooltip;

  /// No description provided for @catalogVariantAddAnotherType.
  ///
  /// In es, this message translates to:
  /// **'Agregar otro tipo'**
  String get catalogVariantAddAnotherType;

  /// No description provided for @catalogVariantRemoveTypeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Quitar {option}?'**
  String catalogVariantRemoveTypeTitle(String option);

  /// No description provided for @catalogVariantRemoveTypeMessage.
  ///
  /// In es, this message translates to:
  /// **'Se borran sus valores y el stock cargado en esas variantes.'**
  String get catalogVariantRemoveTypeMessage;

  /// No description provided for @catalogVariantRemoveTypeConfirm.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get catalogVariantRemoveTypeConfirm;

  /// Heading of the list of variants, one per combination of values.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 variante} other{{count} variantes}}'**
  String catalogVariantListTitle(int count);

  /// No description provided for @catalogVariantListCaption.
  ///
  /// In es, this message translates to:
  /// **'Toca la foto para cambiarla o el nombre para sus códigos.'**
  String get catalogVariantListCaption;

  /// No description provided for @catalogVariantPhotoTooltip.
  ///
  /// In es, this message translates to:
  /// **'Foto de {variant}'**
  String catalogVariantPhotoTooltip(String variant);

  /// No description provided for @catalogVariantImageSheetTitle.
  ///
  /// In es, this message translates to:
  /// **'Foto de la variante'**
  String get catalogVariantImageSheetTitle;

  /// Caption of the main product photo among the photos a variant can use.
  ///
  /// In es, this message translates to:
  /// **'Principal'**
  String get catalogVariantImageMain;

  /// No description provided for @catalogVariantImageAdd.
  ///
  /// In es, this message translates to:
  /// **'Nueva foto'**
  String get catalogVariantImageAdd;

  /// Switch: the chosen photo also goes to every variant sharing this value (e.g. all the red ones).
  ///
  /// In es, this message translates to:
  /// **'Usar en todas las variantes {value}'**
  String catalogVariantImageApplyToGroup(String value);

  /// No description provided for @catalogVariantImageGalleryHint.
  ///
  /// In es, this message translates to:
  /// **'Sube más fotos para que cada color muestre la suya.'**
  String get catalogVariantImageGalleryHint;

  /// Title of the sheet that asks which variant (color, size...) of a product to add to the sale.
  ///
  /// In es, this message translates to:
  /// **'Elige la variante'**
  String get salesVariantSheetTitle;

  /// Variant picker, while the selection is incomplete. option is the name of the first option left, e.g. Talla.
  ///
  /// In es, this message translates to:
  /// **'Falta elegir {option}'**
  String salesVariantMissingOption(String option);

  /// Variant picker: the chosen variant has stock, but all of it is already in the cart.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{La única unidad ya está en la venta} other{Las {count} unidades ya están en la venta}}'**
  String salesVariantAllInCart(int count);

  /// Variant picker badge: units of the chosen variant already in the cart.
  ///
  /// In es, this message translates to:
  /// **'{count} en la venta'**
  String salesVariantInCart(int count);

  /// Variant picker, label of the quantity stepper.
  ///
  /// In es, this message translates to:
  /// **'Cantidad'**
  String get salesVariantQuantityLabel;

  /// Variant picker main button. total is the price of the chosen units, e.g. Bs 900,00.
  ///
  /// In es, this message translates to:
  /// **'Agregar · {total}'**
  String salesVariantAddButton(String total);

  /// A product together with its variant, used in messages and in the text receipt: Zapatillas urbanas (Azul · 40).
  ///
  /// In es, this message translates to:
  /// **'{productName} ({variantLabel})'**
  String salesVariantProductName(String productName, String variantLabel);

  /// Snackbar after adding units of a variant from the variant picker.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se agregó a la venta: {productName}} other{Se agregaron {count} a la venta: {productName}}}'**
  String salesVariantAddedMessage(int count, String productName);

  /// Badge on the sale catalog card of a product that is sold in variants.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 variante} other{{count} variantes}}'**
  String salesVariantCount(int count);

  /// Tooltip of the add button of a product with variants: it opens the variant picker.
  ///
  /// In es, this message translates to:
  /// **'Elegir variante de {productName}'**
  String salesVariantChooseTooltip(String productName);

  /// Screen reader label of a variant value that cannot be added with the current choices.
  ///
  /// In es, this message translates to:
  /// **'{value}, sin stock'**
  String salesVariantValueUnavailable(String value);

  /// No description provided for @accountMoreTitle.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get accountMoreTitle;

  /// No description provided for @accountOpenMenuTooltip.
  ///
  /// In es, this message translates to:
  /// **'Tu cuenta y tu negocio'**
  String get accountOpenMenuTooltip;

  /// No description provided for @accountSectionBusiness.
  ///
  /// In es, this message translates to:
  /// **'Negocio'**
  String get accountSectionBusiness;

  /// No description provided for @accountProviderGoogle.
  ///
  /// In es, this message translates to:
  /// **'Google'**
  String get accountProviderGoogle;

  /// No description provided for @accountProviderEmail.
  ///
  /// In es, this message translates to:
  /// **'correo'**
  String get accountProviderEmail;

  /// No description provided for @accountProviderPhone.
  ///
  /// In es, this message translates to:
  /// **'teléfono'**
  String get accountProviderPhone;

  /// No description provided for @accountSignedInWith.
  ///
  /// In es, this message translates to:
  /// **'Ingresaste con {method}'**
  String accountSignedInWith(String method);

  /// No description provided for @accountBusinessEdit.
  ///
  /// In es, this message translates to:
  /// **'Editar datos del negocio'**
  String get accountBusinessEdit;

  /// No description provided for @accountBusinessNoTaxId.
  ///
  /// In es, this message translates to:
  /// **'Sin NIT'**
  String get accountBusinessNoTaxId;

  /// No description provided for @accountSignOut.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get accountSignOut;

  /// No description provided for @accountSignOutTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Cerrar sesión?'**
  String get accountSignOutTitle;

  /// No description provided for @accountSignOutMessage.
  ///
  /// In es, this message translates to:
  /// **'Tendrás que ingresar de nuevo para vender.'**
  String get accountSignOutMessage;

  /// No description provided for @accountSignOutCashOpen.
  ///
  /// In es, this message translates to:
  /// **'La caja queda abierta. Podrás cerrarla cuando vuelvas a ingresar.'**
  String get accountSignOutCashOpen;

  /// No description provided for @accountVersion.
  ///
  /// In es, this message translates to:
  /// **'{app} · versión {version} ({build})'**
  String accountVersion(String app, String version, String build);

  /// No description provided for @accountBusinessTitle.
  ///
  /// In es, this message translates to:
  /// **'Datos del negocio'**
  String get accountBusinessTitle;

  /// No description provided for @accountBusinessSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Así aparece tu tienda en los comprobantes y en tu catálogo.'**
  String get accountBusinessSubtitle;

  /// No description provided for @accountBusinessLogoChange.
  ///
  /// In es, this message translates to:
  /// **'Cambiar logo'**
  String get accountBusinessLogoChange;

  /// No description provided for @accountBusinessTaxIdLabel.
  ///
  /// In es, this message translates to:
  /// **'NIT'**
  String get accountBusinessTaxIdLabel;

  /// No description provided for @accountBusinessOptional.
  ///
  /// In es, this message translates to:
  /// **'(opcional)'**
  String get accountBusinessOptional;

  /// No description provided for @accountBusinessTaxIdHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 1020304050'**
  String get accountBusinessTaxIdHint;

  /// No description provided for @accountBusinessTaxIdHelper.
  ///
  /// In es, this message translates to:
  /// **'Se imprime en tus comprobantes.'**
  String get accountBusinessTaxIdHelper;

  /// No description provided for @accountBusinessSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get accountBusinessSave;

  /// No description provided for @accountBusinessSaved.
  ///
  /// In es, this message translates to:
  /// **'Datos del negocio guardados'**
  String get accountBusinessSaved;

  /// No description provided for @accountSectionOperation.
  ///
  /// In es, this message translates to:
  /// **'Operación'**
  String get accountSectionOperation;

  /// No description provided for @accountOperationCategoriesHint.
  ///
  /// In es, this message translates to:
  /// **'Crea, ordena y archiva tus categorías'**
  String get accountOperationCategoriesHint;

  /// No description provided for @catalogCategoriesTitle.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get catalogCategoriesTitle;

  /// No description provided for @catalogCategoriesSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Arrastra para ordenarlas como las ves al vender.'**
  String get catalogCategoriesSubtitle;

  /// No description provided for @catalogCategoriesNew.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get catalogCategoriesNew;

  /// No description provided for @catalogCategoriesCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear categoría'**
  String get catalogCategoriesCreate;

  /// No description provided for @catalogCategoriesCreated.
  ///
  /// In es, this message translates to:
  /// **'Categoría creada'**
  String get catalogCategoriesCreated;

  /// No description provided for @catalogCategoriesRename.
  ///
  /// In es, this message translates to:
  /// **'Renombrar'**
  String get catalogCategoriesRename;

  /// No description provided for @catalogCategoriesRenameTitle.
  ///
  /// In es, this message translates to:
  /// **'Renombrar categoría'**
  String get catalogCategoriesRenameTitle;

  /// No description provided for @catalogCategoriesRenamed.
  ///
  /// In es, this message translates to:
  /// **'Categoría renombrada'**
  String get catalogCategoriesRenamed;

  /// No description provided for @catalogCategoriesArchive.
  ///
  /// In es, this message translates to:
  /// **'Archivar'**
  String get catalogCategoriesArchive;

  /// No description provided for @catalogCategoriesArchiveTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Archivar {name}?'**
  String catalogCategoriesArchiveTitle(String name);

  /// No description provided for @catalogCategoriesArchiveMessage.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Su producto sigue} other{Sus {count} productos siguen}} en tu inventario. La categoría ya no aparecerá al crear productos ni en los filtros.'**
  String catalogCategoriesArchiveMessage(int count);

  /// No description provided for @catalogCategoriesArchived.
  ///
  /// In es, this message translates to:
  /// **'Categoría archivada'**
  String get catalogCategoriesArchived;

  /// No description provided for @catalogCategoriesUndo.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get catalogCategoriesUndo;

  /// No description provided for @catalogCategoriesArchivedSection.
  ///
  /// In es, this message translates to:
  /// **'Archivadas'**
  String get catalogCategoriesArchivedSection;

  /// No description provided for @catalogCategoriesRestore.
  ///
  /// In es, this message translates to:
  /// **'Restaurar'**
  String get catalogCategoriesRestore;

  /// No description provided for @catalogCategoriesRestored.
  ///
  /// In es, this message translates to:
  /// **'Categoría restaurada'**
  String get catalogCategoriesRestored;

  /// No description provided for @catalogCategoriesProductCount.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin productos} =1{1 producto} other{{count} productos}}'**
  String catalogCategoriesProductCount(int count);

  /// No description provided for @catalogCategoriesEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'Todavía no tienes categorías'**
  String get catalogCategoriesEmptyTitle;

  /// No description provided for @catalogCategoriesEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Crea la primera para ordenar tu inventario.'**
  String get catalogCategoriesEmptyMessage;

  /// No description provided for @catalogCategoriesMenu.
  ///
  /// In es, this message translates to:
  /// **'Opciones de {name}'**
  String catalogCategoriesMenu(String name);

  /// No description provided for @catalogCategoriesDragHandle.
  ///
  /// In es, this message translates to:
  /// **'Arrastrar para ordenar'**
  String get catalogCategoriesDragHandle;

  /// No description provided for @catalogCategoriesManage.
  ///
  /// In es, this message translates to:
  /// **'Gestionar'**
  String get catalogCategoriesManage;

  /// No description provided for @catalogCategoryNameHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Ropa de niños'**
  String get catalogCategoryNameHint;

  /// No description provided for @catalogProductFormArchivedCategory.
  ///
  /// In es, this message translates to:
  /// **'{name} (archivada)'**
  String catalogProductFormArchivedCategory(String name);

  /// No description provided for @scannerSellTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear producto'**
  String get scannerSellTitle;

  /// No description provided for @scannerSellSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código de barras y se agrega a la venta.'**
  String get scannerSellSubtitle;

  /// No description provided for @scannerFindTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar por código'**
  String get scannerFindTitle;

  /// No description provided for @scannerFindSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código de barras para abrir el producto.'**
  String get scannerFindSubtitle;

  /// No description provided for @scannerAssignTitle.
  ///
  /// In es, this message translates to:
  /// **'Escanear código'**
  String get scannerAssignTitle;

  /// No description provided for @scannerAssignSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Apunta al código de barras de la etiqueta.'**
  String get scannerAssignSubtitle;

  /// No description provided for @scannerTorchTooltip.
  ///
  /// In es, this message translates to:
  /// **'Linterna'**
  String get scannerTorchTooltip;

  /// No description provided for @scannerDemoCamera.
  ///
  /// In es, this message translates to:
  /// **'La cámara no está disponible en este dispositivo. Escribe el código o usa uno de prueba.'**
  String get scannerDemoCamera;

  /// No description provided for @scannerTypeTitle.
  ///
  /// In es, this message translates to:
  /// **'¿No lo lee? Escríbelo'**
  String get scannerTypeTitle;

  /// No description provided for @scannerTypeHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 7770000008001'**
  String get scannerTypeHint;

  /// No description provided for @scannerTypeSubmit.
  ///
  /// In es, this message translates to:
  /// **'Usar código'**
  String get scannerTypeSubmit;

  /// No description provided for @scannerDemoCodesTitle.
  ///
  /// In es, this message translates to:
  /// **'Códigos de prueba'**
  String get scannerDemoCodesTitle;

  /// No description provided for @scannerDemoCodesCaption.
  ///
  /// In es, this message translates to:
  /// **'Toca uno para probar sin etiquetas impresas.'**
  String get scannerDemoCodesCaption;

  /// No description provided for @catalogProductFormCodesSection.
  ///
  /// In es, this message translates to:
  /// **'Códigos'**
  String get catalogProductFormCodesSection;

  /// No description provided for @catalogProductFormSkuLabel.
  ///
  /// In es, this message translates to:
  /// **'SKU'**
  String get catalogProductFormSkuLabel;

  /// No description provided for @catalogProductFormSkuHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: CAL-001'**
  String get catalogProductFormSkuHint;

  /// No description provided for @catalogProductFormGenerateSku.
  ///
  /// In es, this message translates to:
  /// **'Generar'**
  String get catalogProductFormGenerateSku;

  /// No description provided for @catalogProductFormBarcodeLabel.
  ///
  /// In es, this message translates to:
  /// **'Código de barras'**
  String get catalogProductFormBarcodeLabel;

  /// No description provided for @catalogProductFormBarcodeHint.
  ///
  /// In es, this message translates to:
  /// **'Escanéalo o escríbelo'**
  String get catalogProductFormBarcodeHint;

  /// No description provided for @catalogProductFormCodesCaption.
  ///
  /// In es, this message translates to:
  /// **'Con el código de barras, escanear la etiqueta agrega el producto a la venta.'**
  String get catalogProductFormCodesCaption;

  /// No description provided for @catalogProductFormCodesVariantsCaption.
  ///
  /// In es, this message translates to:
  /// **'Cada variante puede tener su propio SKU y código de barras: tócala en la lista de stock.'**
  String get catalogProductFormCodesVariantsCaption;

  /// No description provided for @catalogVariantCodesTitle.
  ///
  /// In es, this message translates to:
  /// **'Códigos · {variant}'**
  String catalogVariantCodesTitle(String variant);

  /// No description provided for @catalogVariantAddCodes.
  ///
  /// In es, this message translates to:
  /// **'Agregar SKU o código'**
  String get catalogVariantAddCodes;

  /// No description provided for @catalogScanUnknownTitle.
  ///
  /// In es, this message translates to:
  /// **'Código sin producto'**
  String get catalogScanUnknownTitle;

  /// No description provided for @catalogScanUnknownMessage.
  ///
  /// In es, this message translates to:
  /// **'Ningún producto tiene el código {code}. ¿Quieres crear uno con este código?'**
  String catalogScanUnknownMessage(String code);

  /// No description provided for @catalogScanUnknownCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear producto con este código'**
  String get catalogScanUnknownCreate;

  /// No description provided for @salesHistoryTitle.
  ///
  /// In es, this message translates to:
  /// **'Historial de ventas'**
  String get salesHistoryTitle;

  /// No description provided for @salesHistorySummary.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =0{Sin ventas} =1{1 venta · {total}} other{{count} ventas · {total}}}'**
  String salesHistorySummary(int count, String total);

  /// No description provided for @salesHistorySearchHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por número de venta'**
  String get salesHistorySearchHint;

  /// No description provided for @salesHistorySearchingAllDates.
  ///
  /// In es, this message translates to:
  /// **'Buscando en todas las fechas.'**
  String get salesHistorySearchingAllDates;

  /// No description provided for @salesHistoryPeriodToday.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get salesHistoryPeriodToday;

  /// No description provided for @salesHistoryPeriodYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get salesHistoryPeriodYesterday;

  /// No description provided for @salesHistoryPeriodLast7Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días'**
  String get salesHistoryPeriodLast7Days;

  /// No description provided for @salesHistoryPeriodCustom.
  ///
  /// In es, this message translates to:
  /// **'Elegir fechas'**
  String get salesHistoryPeriodCustom;

  /// No description provided for @salesHistoryRange.
  ///
  /// In es, this message translates to:
  /// **'{from} – {to}'**
  String salesHistoryRange(String from, String to);

  /// No description provided for @salesHistoryAllMethods.
  ///
  /// In es, this message translates to:
  /// **'Todos los pagos'**
  String get salesHistoryAllMethods;

  /// No description provided for @salesHistoryDayTotal.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 venta · {total}} other{{count} ventas · {total}}}'**
  String salesHistoryDayTotal(int count, String total);

  /// No description provided for @salesHistoryMoreProducts.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{{first} y 1 producto más} other{{first} y {count} productos más}}'**
  String salesHistoryMoreProducts(int count, String first);

  /// No description provided for @salesHistoryEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'No hay ventas en estas fechas'**
  String get salesHistoryEmptyTitle;

  /// No description provided for @salesHistoryEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro período o método de pago.'**
  String get salesHistoryEmptyMessage;

  /// No description provided for @salesHistoryNumberNotFoundTitle.
  ///
  /// In es, this message translates to:
  /// **'No encontramos esa venta'**
  String get salesHistoryNumberNotFoundTitle;

  /// No description provided for @salesHistoryNumberNotFoundMessage.
  ///
  /// In es, this message translates to:
  /// **'Ninguna venta tiene el número {number}.'**
  String salesHistoryNumberNotFoundMessage(String number);

  /// No description provided for @saleDetailTitle.
  ///
  /// In es, this message translates to:
  /// **'Venta {number}'**
  String saleDetailTitle(String number);

  /// No description provided for @saleDetailTitleLoading.
  ///
  /// In es, this message translates to:
  /// **'Venta'**
  String get saleDetailTitleLoading;

  /// No description provided for @saleDetailLoadError.
  ///
  /// In es, this message translates to:
  /// **'No pudimos abrir esta venta'**
  String get saleDetailLoadError;

  /// No description provided for @saleDetailProducts.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 producto} other{{count} productos}}'**
  String saleDetailProducts(int count);

  /// No description provided for @saleDetailUnitPrice.
  ///
  /// In es, this message translates to:
  /// **'{quantity} × {price}'**
  String saleDetailUnitPrice(int quantity, String price);

  /// No description provided for @saleDetailSubtotal.
  ///
  /// In es, this message translates to:
  /// **'Subtotal'**
  String get saleDetailSubtotal;

  /// No description provided for @saleDetailDiscount.
  ///
  /// In es, this message translates to:
  /// **'Descuento'**
  String get saleDetailDiscount;

  /// No description provided for @saleDetailTotal.
  ///
  /// In es, this message translates to:
  /// **'Total'**
  String get saleDetailTotal;

  /// No description provided for @saleDetailPayment.
  ///
  /// In es, this message translates to:
  /// **'Pago'**
  String get saleDetailPayment;

  /// No description provided for @saleDetailMethod.
  ///
  /// In es, this message translates to:
  /// **'Método'**
  String get saleDetailMethod;

  /// No description provided for @saleDetailReceived.
  ///
  /// In es, this message translates to:
  /// **'Recibido'**
  String get saleDetailReceived;

  /// No description provided for @saleDetailChange.
  ///
  /// In es, this message translates to:
  /// **'Cambio'**
  String get saleDetailChange;

  /// No description provided for @saleDetailCashier.
  ///
  /// In es, this message translates to:
  /// **'Atendió'**
  String get saleDetailCashier;

  /// No description provided for @saleDetailViewReceipt.
  ///
  /// In es, this message translates to:
  /// **'Ver comprobante'**
  String get saleDetailViewReceipt;

  /// No description provided for @accountOperationSalesHistoryHint.
  ///
  /// In es, this message translates to:
  /// **'Busca una venta y vuelve a imprimir o compartir su comprobante'**
  String get accountOperationSalesHistoryHint;

  /// No description provided for @dashboardCashCardHistory.
  ///
  /// In es, this message translates to:
  /// **'Ver historial'**
  String get dashboardCashCardHistory;

  /// No description provided for @cashRegisterViewSales.
  ///
  /// In es, this message translates to:
  /// **'Ver las ventas del día'**
  String get cashRegisterViewSales;

  /// No description provided for @failureInvalidStockQuantity.
  ///
  /// In es, this message translates to:
  /// **'La cantidad debe ser mayor a 0.'**
  String get failureInvalidStockQuantity;

  /// No description provided for @failureAdjustmentReasonRequired.
  ///
  /// In es, this message translates to:
  /// **'Elige el motivo del ajuste.'**
  String get failureAdjustmentReasonRequired;

  /// No description provided for @failureNoStockChange.
  ///
  /// In es, this message translates to:
  /// **'El conteo es igual al stock actual: no hay nada que ajustar.'**
  String get failureNoStockChange;

  /// No description provided for @failureEmptyGoodsReceipt.
  ///
  /// In es, this message translates to:
  /// **'Agrega al menos un producto al ingreso.'**
  String get failureEmptyGoodsReceipt;

  /// No description provided for @catalogProductFormStockLockedTitle.
  ///
  /// In es, this message translates to:
  /// **'El stock no se edita aquí'**
  String get catalogProductFormStockLockedTitle;

  /// No description provided for @catalogProductFormStockLockedCaption.
  ///
  /// In es, this message translates to:
  /// **'Cámbialo con «Ingreso» o «Ajustar» en el detalle del producto, así queda registrado.'**
  String get catalogProductFormStockLockedCaption;

  /// No description provided for @accountOperationMovementsHint.
  ///
  /// In es, this message translates to:
  /// **'Ingresos, ajustes y ventas de cada producto'**
  String get accountOperationMovementsHint;

  /// No description provided for @inventoryMovementsTitle.
  ///
  /// In es, this message translates to:
  /// **'Movimientos de stock'**
  String get inventoryMovementsTitle;

  /// No description provided for @inventorySeeAll.
  ///
  /// In es, this message translates to:
  /// **'Ver todos'**
  String get inventorySeeAll;

  /// No description provided for @inventoryNoMovements.
  ///
  /// In es, this message translates to:
  /// **'Sin movimientos todavía'**
  String get inventoryNoMovements;

  /// No description provided for @inventoryNoMovementsMessage.
  ///
  /// In es, this message translates to:
  /// **'Prueba con otro tipo o período.'**
  String get inventoryNoMovementsMessage;

  /// No description provided for @inventoryAddStock.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get inventoryAddStock;

  /// No description provided for @inventoryAdjust.
  ///
  /// In es, this message translates to:
  /// **'Ajustar'**
  String get inventoryAdjust;

  /// No description provided for @inventoryTypeInitial.
  ///
  /// In es, this message translates to:
  /// **'Inventario inicial'**
  String get inventoryTypeInitial;

  /// No description provided for @inventoryTypePurchase.
  ///
  /// In es, this message translates to:
  /// **'Ingreso'**
  String get inventoryTypePurchase;

  /// No description provided for @inventoryTypeAdjustment.
  ///
  /// In es, this message translates to:
  /// **'Ajuste'**
  String get inventoryTypeAdjustment;

  /// No description provided for @inventoryTypeSale.
  ///
  /// In es, this message translates to:
  /// **'Venta'**
  String get inventoryTypeSale;

  /// No description provided for @inventoryTypeCancellation.
  ///
  /// In es, this message translates to:
  /// **'Venta anulada'**
  String get inventoryTypeCancellation;

  /// No description provided for @inventoryTypeReturn.
  ///
  /// In es, this message translates to:
  /// **'Devolución'**
  String get inventoryTypeReturn;

  /// No description provided for @inventoryReasonCount.
  ///
  /// In es, this message translates to:
  /// **'Conteo'**
  String get inventoryReasonCount;

  /// No description provided for @inventoryReasonDamage.
  ///
  /// In es, this message translates to:
  /// **'Dañado'**
  String get inventoryReasonDamage;

  /// No description provided for @inventoryReasonLoss.
  ///
  /// In es, this message translates to:
  /// **'Pérdida'**
  String get inventoryReasonLoss;

  /// No description provided for @inventoryReasonOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get inventoryReasonOther;

  /// No description provided for @inventoryMovementWhen.
  ///
  /// In es, this message translates to:
  /// **'{date} · {user}'**
  String inventoryMovementWhen(String date, String user);

  /// No description provided for @inventoryStockAfter.
  ///
  /// In es, this message translates to:
  /// **'Stock {count}'**
  String inventoryStockAfter(int count);

  /// No description provided for @inventoryFilterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get inventoryFilterAll;

  /// No description provided for @inventoryFilterPurchases.
  ///
  /// In es, this message translates to:
  /// **'Ingresos'**
  String get inventoryFilterPurchases;

  /// No description provided for @inventoryFilterAdjustments.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get inventoryFilterAdjustments;

  /// No description provided for @inventoryFilterSales.
  ///
  /// In es, this message translates to:
  /// **'Ventas'**
  String get inventoryFilterSales;

  /// No description provided for @inventoryPeriodLast30Days.
  ///
  /// In es, this message translates to:
  /// **'Últimos 30 días'**
  String get inventoryPeriodLast30Days;

  /// No description provided for @inventoryPeriodAll.
  ///
  /// In es, this message translates to:
  /// **'Todo'**
  String get inventoryPeriodAll;

  /// No description provided for @inventoryAdjustTitle.
  ///
  /// In es, this message translates to:
  /// **'Ajustar stock'**
  String get inventoryAdjustTitle;

  /// No description provided for @inventoryAdjustSave.
  ///
  /// In es, this message translates to:
  /// **'Guardar ajuste'**
  String get inventoryAdjustSave;

  /// No description provided for @inventoryAdjustSaved.
  ///
  /// In es, this message translates to:
  /// **'Stock ajustado'**
  String get inventoryAdjustSaved;

  /// No description provided for @inventoryVariantLabel.
  ///
  /// In es, this message translates to:
  /// **'Variante'**
  String get inventoryVariantLabel;

  /// No description provided for @inventoryVariantWithStock.
  ///
  /// In es, this message translates to:
  /// **'{variant} · {count} u.'**
  String inventoryVariantWithStock(String variant, int count);

  /// No description provided for @inventoryModeCount.
  ///
  /// In es, this message translates to:
  /// **'Contar'**
  String get inventoryModeCount;

  /// No description provided for @inventoryModeAdd.
  ///
  /// In es, this message translates to:
  /// **'Agregar'**
  String get inventoryModeAdd;

  /// No description provided for @inventoryModeRemove.
  ///
  /// In es, this message translates to:
  /// **'Quitar'**
  String get inventoryModeRemove;

  /// No description provided for @inventoryQuantityCounted.
  ///
  /// In es, this message translates to:
  /// **'Unidades contadas'**
  String get inventoryQuantityCounted;

  /// No description provided for @inventoryQuantityToAdd.
  ///
  /// In es, this message translates to:
  /// **'Unidades a agregar'**
  String get inventoryQuantityToAdd;

  /// No description provided for @inventoryQuantityToRemove.
  ///
  /// In es, this message translates to:
  /// **'Unidades a quitar'**
  String get inventoryQuantityToRemove;

  /// No description provided for @inventoryQuantityHint.
  ///
  /// In es, this message translates to:
  /// **'0'**
  String get inventoryQuantityHint;

  /// No description provided for @inventoryCurrentStock.
  ///
  /// In es, this message translates to:
  /// **'Stock actual'**
  String get inventoryCurrentStock;

  /// No description provided for @inventoryNewStock.
  ///
  /// In es, this message translates to:
  /// **'Nuevo stock'**
  String get inventoryNewStock;

  /// No description provided for @inventoryNotEnoughStock.
  ///
  /// In es, this message translates to:
  /// **'No alcanza'**
  String get inventoryNotEnoughStock;

  /// No description provided for @inventoryReasonTitle.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get inventoryReasonTitle;

  /// No description provided for @inventoryNoteLabel.
  ///
  /// In es, this message translates to:
  /// **'Nota'**
  String get inventoryNoteLabel;

  /// No description provided for @inventoryAdjustNoteHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: se encontró en el depósito'**
  String get inventoryAdjustNoteHint;

  /// No description provided for @inventoryReceiveTitle.
  ///
  /// In es, this message translates to:
  /// **'Ingreso de mercadería'**
  String get inventoryReceiveTitle;

  /// No description provided for @inventoryReceiveSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Registra lo que llegó a tu tienda'**
  String get inventoryReceiveSubtitle;

  /// No description provided for @inventoryReceiveEmptyTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué llegó hoy?'**
  String get inventoryReceiveEmptyTitle;

  /// No description provided for @inventoryReceiveEmptyMessage.
  ///
  /// In es, this message translates to:
  /// **'Agrega los productos que recibiste, o escanéalos.'**
  String get inventoryReceiveEmptyMessage;

  /// No description provided for @inventoryReceiveAddProduct.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get inventoryReceiveAddProduct;

  /// No description provided for @inventoryReceiveSave.
  ///
  /// In es, this message translates to:
  /// **'Registrar ingreso'**
  String get inventoryReceiveSave;

  /// No description provided for @inventoryReceiveSaveUnits.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Registrar ingreso · 1 unidad} other{Registrar ingreso · {count} unidades}}'**
  String inventoryReceiveSaveUnits(int count);

  /// No description provided for @inventoryReceiveSaved.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Se agregó 1 unidad al stock} other{Se agregaron {count} unidades al stock}}'**
  String inventoryReceiveSaved(int count);

  /// No description provided for @inventorySupplierLabel.
  ///
  /// In es, this message translates to:
  /// **'Proveedor o nota'**
  String get inventorySupplierLabel;

  /// No description provided for @inventorySupplierHint.
  ///
  /// In es, this message translates to:
  /// **'Ej.: Importadora Andina'**
  String get inventorySupplierHint;

  /// No description provided for @inventoryStockNow.
  ///
  /// In es, this message translates to:
  /// **'Stock actual: {count}'**
  String inventoryStockNow(int count);

  /// No description provided for @inventoryRemoveLine.
  ///
  /// In es, this message translates to:
  /// **'Quitar del ingreso'**
  String get inventoryRemoveLine;

  /// No description provided for @inventoryUnitCostLabel.
  ///
  /// In es, this message translates to:
  /// **'Costo c/u'**
  String get inventoryUnitCostLabel;

  /// No description provided for @inventoryPickProductTitle.
  ///
  /// In es, this message translates to:
  /// **'Agregar producto'**
  String get inventoryPickProductTitle;

  /// No description provided for @inventoryPickProductHint.
  ///
  /// In es, this message translates to:
  /// **'Buscar por nombre o código'**
  String get inventoryPickProductHint;

  /// No description provided for @inventoryPickVariantSubtitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué variante llegó?'**
  String get inventoryPickVariantSubtitle;

  /// No description provided for @failureSaleAlreadyCancelled.
  ///
  /// In es, this message translates to:
  /// **'Esta venta ya fue anulada.'**
  String get failureSaleAlreadyCancelled;

  /// No description provided for @failureSaleHasReturns.
  ///
  /// In es, this message translates to:
  /// **'Esta venta ya tiene devoluciones: registra otra devolución en lugar de anularla.'**
  String get failureSaleHasReturns;

  /// No description provided for @failureSaleCancelWindowClosed.
  ///
  /// In es, this message translates to:
  /// **'Solo puedes anular ventas de la caja abierta. Para ventas anteriores registra una devolución.'**
  String get failureSaleCancelWindowClosed;

  /// No description provided for @failureReturnWindowClosed.
  ///
  /// In es, this message translates to:
  /// **'Pasaron más de 30 días desde la venta: ya no se puede devolver.'**
  String get failureReturnWindowClosed;

  /// No description provided for @failureReturnQuantityExceeded.
  ///
  /// In es, this message translates to:
  /// **'No puedes devolver más unidades de las que quedan en la venta.'**
  String get failureReturnQuantityExceeded;

  /// No description provided for @failureInvalidRefundMethod.
  ///
  /// In es, this message translates to:
  /// **'El reembolso se hace con el mismo método de la venta o en efectivo.'**
  String get failureInvalidRefundMethod;

  /// No description provided for @failureEmptyReturn.
  ///
  /// In es, this message translates to:
  /// **'Elige al menos una unidad para devolver.'**
  String get failureEmptyReturn;

  /// No description provided for @failureReasonRequired.
  ///
  /// In es, this message translates to:
  /// **'Escribe el motivo.'**
  String get failureReasonRequired;

  /// No description provided for @receiptMarkCancelled.
  ///
  /// In es, this message translates to:
  /// **'ANULADA'**
  String get receiptMarkCancelled;

  /// No description provided for @receiptMarkPartiallyReturned.
  ///
  /// In es, this message translates to:
  /// **'CON DEVOLUCIÓN PARCIAL'**
  String get receiptMarkPartiallyReturned;

  /// No description provided for @receiptMarkReturned.
  ///
  /// In es, this message translates to:
  /// **'DEVUELTA'**
  String get receiptMarkReturned;

  /// No description provided for @receiptMarkRefund.
  ///
  /// In es, this message translates to:
  /// **'DEVOLUCIÓN'**
  String get receiptMarkRefund;

  /// No description provided for @receiptRefundOf.
  ///
  /// In es, this message translates to:
  /// **'De la venta {number}'**
  String receiptRefundOf(String number);

  /// No description provided for @salesRefundReceiptTitle.
  ///
  /// In es, this message translates to:
  /// **'Comprobante de devolución'**
  String get salesRefundReceiptTitle;

  /// No description provided for @saleStatusCancelled.
  ///
  /// In es, this message translates to:
  /// **'Anulada'**
  String get saleStatusCancelled;

  /// No description provided for @saleStatusPartiallyReturned.
  ///
  /// In es, this message translates to:
  /// **'Devolución parcial'**
  String get saleStatusPartiallyReturned;

  /// No description provided for @saleStatusReturned.
  ///
  /// In es, this message translates to:
  /// **'Devuelta'**
  String get saleStatusReturned;

  /// No description provided for @saleDetailCancel.
  ///
  /// In es, this message translates to:
  /// **'Anular'**
  String get saleDetailCancel;

  /// No description provided for @saleDetailReturn.
  ///
  /// In es, this message translates to:
  /// **'Devolver'**
  String get saleDetailReturn;

  /// No description provided for @saleDetailCancelled.
  ///
  /// In es, this message translates to:
  /// **'Venta anulada: sus productos volvieron al stock'**
  String get saleDetailCancelled;

  /// No description provided for @saleDetailCancelledTitle.
  ///
  /// In es, this message translates to:
  /// **'Venta anulada'**
  String get saleDetailCancelledTitle;

  /// No description provided for @saleDetailCancelTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Anular la venta {number}?'**
  String saleDetailCancelTitle(String number);

  /// No description provided for @saleDetailCancelMessage.
  ///
  /// In es, this message translates to:
  /// **'Sus {total} salen de las ventas y de la caja, y sus productos vuelven al stock.'**
  String saleDetailCancelMessage(String total);

  /// No description provided for @saleDetailReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Motivo, ej.: se cobró dos veces'**
  String get saleDetailReasonHint;

  /// No description provided for @saleDetailRefunded.
  ///
  /// In es, this message translates to:
  /// **'Devuelto'**
  String get saleDetailRefunded;

  /// No description provided for @saleDetailReturnsTitle.
  ///
  /// In es, this message translates to:
  /// **'Devoluciones'**
  String get saleDetailReturnsTitle;

  /// No description provided for @saleDetailReturnSummary.
  ///
  /// In es, this message translates to:
  /// **'{number} · {units, plural, =1{1 unidad} other{{units} unidades}}'**
  String saleDetailReturnSummary(String number, int units);

  /// No description provided for @saleDetailReturnedUnits.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{1 devuelta} other{{count} devueltas}}'**
  String saleDetailReturnedUnits(int count);

  /// No description provided for @returnTitle.
  ///
  /// In es, this message translates to:
  /// **'Devolución'**
  String get returnTitle;

  /// No description provided for @returnWhatTitle.
  ///
  /// In es, this message translates to:
  /// **'¿Qué devuelve el cliente?'**
  String get returnWhatTitle;

  /// No description provided for @returnDiscountNote.
  ///
  /// In es, this message translates to:
  /// **'El descuento de {discount} se reparte entre los productos.'**
  String returnDiscountNote(String discount);

  /// No description provided for @returnReturnable.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Puede devolver 1} other{Puede devolver {count}}}'**
  String returnReturnable(int count);

  /// No description provided for @returnLineRefund.
  ///
  /// In es, this message translates to:
  /// **'Se devuelve {amount}'**
  String returnLineRefund(String amount);

  /// No description provided for @returnRestock.
  ///
  /// In es, this message translates to:
  /// **'Vuelve al stock'**
  String get returnRestock;

  /// No description provided for @returnNoRestock.
  ///
  /// In es, this message translates to:
  /// **'No se podrá vender (por ejemplo, está dañado).'**
  String get returnNoRestock;

  /// No description provided for @returnRefundTitle.
  ///
  /// In es, this message translates to:
  /// **'Reembolso'**
  String get returnRefundTitle;

  /// No description provided for @returnReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Otro motivo'**
  String get returnReasonHint;

  /// No description provided for @returnSave.
  ///
  /// In es, this message translates to:
  /// **'Registrar devolución'**
  String get returnSave;

  /// No description provided for @returnSaveAmount.
  ///
  /// In es, this message translates to:
  /// **'Devolver {amount}'**
  String returnSaveAmount(String amount);

  /// No description provided for @returnSaved.
  ///
  /// In es, this message translates to:
  /// **'Devolución {number} registrada: {amount}'**
  String returnSaved(String number, String amount);

  /// No description provided for @cashRegisterRefunds.
  ///
  /// In es, this message translates to:
  /// **'{count, plural, =1{Devoluciones (1)} other{Devoluciones ({count})}}'**
  String cashRegisterRefunds(int count);

  /// No description provided for @receiptRefundTotalLabel.
  ///
  /// In es, this message translates to:
  /// **'TOTAL DEVUELTO'**
  String get receiptRefundTotalLabel;

  /// No description provided for @receiptRefundClosing.
  ///
  /// In es, this message translates to:
  /// **'¡Gracias por tu visita!'**
  String get receiptRefundClosing;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
