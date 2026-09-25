import 'package:flutter/material.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/theme/app_colors.dart';

/// Presentation data of a [PaymentMethod]: icon and tint. Its name lives in
/// the translations (`PaymentMethodL10n.localizedName`).
///
/// Keeping it out of the domain lets the entity stay free of Flutter types.
extension PaymentMethodViewData on PaymentMethod {
  IconData get icon => switch (this) {
    PaymentMethod.cash => Icons.payments_outlined,
    PaymentMethod.qr => Icons.qr_code_2_rounded,
    PaymentMethod.card => Icons.credit_card_rounded,
    PaymentMethod.bankTransfer => Icons.account_balance_rounded,
  };

  /// Icon color on top of [tintSurface].
  Color get tintColor => switch (this) {
    PaymentMethod.cash => AppColors.successText,
    PaymentMethod.qr => AppColors.infoText,
    PaymentMethod.card => AppColors.goldText,
    PaymentMethod.bankTransfer => AppColors.violetText,
  };

  Color get tintSurface => switch (this) {
    PaymentMethod.cash => AppColors.successSurface,
    PaymentMethod.qr => AppColors.infoSurface,
    PaymentMethod.card => AppColors.goldSurface,
    PaymentMethod.bankTransfer => AppColors.violetSurface,
  };

  /// Solid color used by the dashboard breakdown bar.
  Color get chartColor => switch (this) {
    PaymentMethod.cash => AppColors.ink,
    PaymentMethod.qr => AppColors.info,
    PaymentMethod.card => AppColors.gold,
    PaymentMethod.bankTransfer => AppColors.violet,
  };
}
