import '../../l10n/generated/app_localizations.dart';
import '../domain/payment_method.dart';

/// Name of a [PaymentMethod] on screen and on printed receipts.
extension PaymentMethodL10n on PaymentMethod {
  String localizedName(AppLocalizations l10n) => switch (this) {
    PaymentMethod.cash => l10n.paymentMethodCash,
    PaymentMethod.qr => l10n.paymentMethodQr,
    PaymentMethod.card => l10n.paymentMethodCard,
    PaymentMethod.bankTransfer => l10n.paymentMethodBankTransfer,
  };
}
