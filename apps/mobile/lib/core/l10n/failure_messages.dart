import '../../l10n/generated/app_localizations.dart';
import '../error/failure.dart';

/// Words a [Failure] for the user. The switch is exhaustive, so a new
/// [FailureCode] does not compile until it has a translation.
extension FailureMessages on Failure {
  String localizedMessage(AppLocalizations l10n) {
    final String? detail = this.detail;

    return switch (code) {
      FailureCode.unexpected => l10n.failureUnexpected,
      FailureCode.fullNameRequired => l10n.failureFullNameRequired,
      FailureCode.invalidMobileNumber => l10n.failureInvalidMobileNumber,
      FailureCode.invalidEmail => l10n.failureInvalidEmail,
      FailureCode.passwordTooShort => l10n.failurePasswordTooShort,
      FailureCode.verificationCodeIncomplete =>
        l10n.failureVerificationCodeIncomplete,
      FailureCode.verificationCodeInvalid =>
        l10n.failureVerificationCodeInvalid,
      FailureCode.businessNameTooShort => l10n.failureBusinessNameTooShort,
      FailureCode.salesCategoryRequired => l10n.failureSalesCategoryRequired,
      FailureCode.paymentMethodRequired => l10n.failurePaymentMethodRequired,
      FailureCode.businessProfileRequired =>
        l10n.failureBusinessProfileRequired,
      FailureCode.invalidTaxId => l10n.failureInvalidTaxId,
      FailureCode.negativeOpeningAmount => l10n.failureNegativeOpeningAmount,
      FailureCode.negativeCountedCash => l10n.failureNegativeCountedCash,
      FailureCode.cashSessionAlreadyOpen => l10n.failureCashSessionAlreadyOpen,
      FailureCode.cashSessionNotOpen => l10n.failureCashSessionNotOpen,
      FailureCode.productNotFound => l10n.failureProductNotFound,
      FailureCode.productNameTooShort => l10n.failureProductNameTooShort,
      FailureCode.categoryRequired => l10n.failureCategoryRequired,
      FailureCode.categoryNotFound => l10n.failureCategoryNotFound,
      FailureCode.categoryNameInvalid => l10n.failureCategoryNameInvalid,
      FailureCode.categoryNameTaken => l10n.failureCategoryNameTaken,
      FailureCode.invalidSalePrice => l10n.failureInvalidSalePrice,
      FailureCode.negativeCostPrice => l10n.failureNegativeCostPrice,
      FailureCode.costAbovePrice => l10n.failureCostAbovePrice,
      FailureCode.negativeStock => l10n.failureNegativeStock,
      FailureCode.incompleteVariantOptions =>
        l10n.failureIncompleteVariantOptions,
      FailureCode.invalidSku => l10n.failureInvalidSku,
      FailureCode.invalidBarcode => l10n.failureInvalidBarcode,
      FailureCode.productCodeRepeated => l10n.failureProductCodeRepeated(
        detail ?? '',
      ),
      FailureCode.productCodeTaken =>
        detail == null
            ? l10n.failureProductCodeTakenGeneric
            : l10n.failureProductCodeTaken(detail),
      FailureCode.productCodeNotFound => l10n.failureProductCodeNotFound(
        detail ?? '',
      ),
      FailureCode.insufficientStock =>
        detail == null
            ? l10n.failureInsufficientStockGeneric
            : l10n.failureInsufficientStock(detail),
      FailureCode.invalidStockQuantity => l10n.failureInvalidStockQuantity,
      FailureCode.adjustmentReasonRequired =>
        l10n.failureAdjustmentReasonRequired,
      FailureCode.noStockChange => l10n.failureNoStockChange,
      FailureCode.emptyGoodsReceipt => l10n.failureEmptyGoodsReceipt,
      FailureCode.cameraPermissionDenied => l10n.failureCameraPermissionDenied,
      FailureCode.cameraUnavailable => l10n.failureCameraUnavailable,
      FailureCode.backgroundRemovalFailed =>
        l10n.failureBackgroundRemovalFailed,
      FailureCode.saleNotFound => l10n.failureSaleNotFound,
      FailureCode.saleAlreadyCancelled => l10n.failureSaleAlreadyCancelled,
      FailureCode.saleHasReturns => l10n.failureSaleHasReturns,
      FailureCode.saleCancelWindowClosed => l10n.failureSaleCancelWindowClosed,
      FailureCode.returnWindowClosed => l10n.failureReturnWindowClosed,
      FailureCode.returnQuantityExceeded => l10n.failureReturnQuantityExceeded,
      FailureCode.invalidRefundMethod => l10n.failureInvalidRefundMethod,
      FailureCode.emptyReturn => l10n.failureEmptyReturn,
      FailureCode.reasonRequired => l10n.failureReasonRequired,
      FailureCode.emptyCart => l10n.failureEmptyCart,
      FailureCode.insufficientPayment => l10n.failureInsufficientPayment,
      FailureCode.cashSessionRequired => l10n.failureCashSessionRequired,
      FailureCode.invalidCopies => l10n.failureInvalidCopies(detail ?? ''),
      FailureCode.printersUnavailable => l10n.failurePrintersUnavailable,
      FailureCode.bluetoothPermissionDenied =>
        l10n.failureBluetoothPermissionDenied,
      FailureCode.bluetoothDisabled => l10n.failureBluetoothDisabled,
      FailureCode.printerUnreachable => l10n.failurePrinterUnreachable(
        detail == null || detail.isEmpty
            ? l10n.commonDefaultPrinterName
            : detail,
      ),
      FailureCode.printerNotResponding => l10n.failurePrinterNotResponding,
      FailureCode.printerTimeout => l10n.failurePrinterTimeout,
      FailureCode.printFailed => l10n.failurePrintFailed,
      FailureCode.shareFailed => l10n.failureShareFailed,
      FailureCode.whatsAppUnavailable => l10n.failureWhatsAppUnavailable,
      FailureCode.emailAppUnavailable => l10n.failureEmailAppUnavailable,
      FailureCode.photoLibraryPermissionDenied =>
        l10n.failurePhotoLibraryPermissionDenied,
    };
  }
}
