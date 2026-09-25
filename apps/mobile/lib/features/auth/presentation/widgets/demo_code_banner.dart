import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tinted_banner.dart';

/// Shown while there is no SMS backend: tells the seller which code to use
/// and fills it in with one tap, so every flow can be walked through.
class DemoCodeBanner extends StatelessWidget {
  const DemoCodeBanner({required this.code, required this.onUse, super.key});

  final String code;
  final ValueChanged<String> onUse;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return TintedBanner(
      icon: Icons.sms_outlined,
      title: l10n.authDemoCodeTitle(code),
      subtitle: l10n.authDemoCodeMessage,
      background: AppColors.infoSurface,
      foreground: AppColors.infoText,
      trailingText: l10n.authDemoCodeUse,
      trailingStyle: AppTextStyles.bodySmallStrong.copyWith(
        color: AppColors.infoText,
      ),
      onTap: () => onUse(code),
    );
  }
}
