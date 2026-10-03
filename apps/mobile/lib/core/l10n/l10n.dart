import 'package:flutter/widgets.dart';

import '../../l10n/generated/app_localizations.dart';

export '../../l10n/generated/app_localizations.dart';
export 'failure_messages.dart';
export 'payment_method_l10n.dart';
export 'receipt_mark_l10n.dart';

/// Language the app runs in. Texts live in `lib/l10n/app_<locale>.arb`;
/// adding a language is adding a file there.
abstract final class AppLocale {
  static const Locale bolivianSpanish = Locale('es', 'BO');
}

extension BuildContextL10n on BuildContext {
  /// Translated texts: `context.l10n.salesTitle`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}
