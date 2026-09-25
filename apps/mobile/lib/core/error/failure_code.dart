/// What went wrong, independent of any language. The presentation layer
/// turns each code into a translated message (see `FailureMessages`), so the
/// exhaustive switch there fails to compile until a new code is translated.
///
/// Grouped by feature; once the backend exists its error codes map here.
enum FailureCode {
  unexpected,

  // Auth
  fullNameRequired,
  invalidMobileNumber,
  invalidEmail,
  passwordTooShort,
  verificationCodeIncomplete,
  verificationCodeInvalid,
  businessNameTooShort,
  salesCategoryRequired,
  paymentMethodRequired,
  businessProfileRequired,

  // Cash register
  negativeOpeningAmount,
  negativeCountedCash,
  cashSessionAlreadyOpen,
  cashSessionNotOpen,

  // Catalog
  productNotFound,
  productNameTooShort,
  categoryRequired,
  categoryNotFound,
  invalidSalePrice,
  negativeCostPrice,
  costAbovePrice,
  negativeStock,
  incompleteVariantOptions,
  insufficientStock,
  cameraPermissionDenied,
  cameraUnavailable,
  backgroundRemovalFailed,

  // Sales
  saleNotFound,
  emptyCart,
  insufficientPayment,
  cashSessionRequired,

  // Receipts
  invalidCopies,
  printersUnavailable,
  bluetoothPermissionDenied,
  bluetoothDisabled,
  printerUnreachable,
  printerNotResponding,
  printerTimeout,
  printFailed,
  shareFailed,
  whatsAppUnavailable,
  emailAppUnavailable,
  photoLibraryPermissionDenied,
}
