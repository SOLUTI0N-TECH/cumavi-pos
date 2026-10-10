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
  invalidTaxId,

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
  categoryNameInvalid,
  categoryNameTaken,
  invalidSalePrice,
  negativeCostPrice,
  costAbovePrice,
  negativeStock,
  incompleteVariantOptions,
  invalidSku,
  invalidBarcode,
  productCodeRepeated,
  productCodeTaken,
  productCodeNotFound,
  insufficientStock,
  invalidStockQuantity,
  adjustmentReasonRequired,
  noStockChange,
  emptyGoodsReceipt,
  cameraPermissionDenied,
  cameraUnavailable,
  backgroundRemovalFailed,

  // Sales
  saleNotFound,
  saleAlreadyCancelled,
  saleHasReturns,
  saleCancelWindowClosed,
  returnWindowClosed,
  returnQuantityExceeded,
  invalidRefundMethod,
  emptyReturn,
  reasonRequired,
  emptyCart,
  insufficientPayment,
  cashSessionRequired,

  // Online orders and store
  orderNotFound,
  invalidOrderTransition,
  orderNotEditable,
  orderEmpty,
  invalidDeliveryFee,
  invalidOrderLink,
  orderFromAnotherStore,
  storeDisabled,
  invalidOpeningHours,
  onlineFulfillmentRequired,
  onlinePaymentMethodRequired,
  phoneAppUnavailable,
  linkUnavailable,

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
