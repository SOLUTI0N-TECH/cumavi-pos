import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Tinted informational row: change to give back, cash difference, unit
/// profit, low-stock warning.
class TintedBanner extends StatelessWidget {
  const TintedBanner({
    required this.title,
    required this.background,
    required this.foreground,
    this.icon,
    this.iconBackground,
    this.subtitle,
    this.trailingText,
    this.trailingStyle,
    this.onTap,
    this.showChevron = false,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final Color? iconBackground;
  final String? trailingText;
  final TextStyle? trailingStyle;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 20 : 12,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              height: 44,
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackground ?? AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
              ),
              child: Icon(icon, size: 22, color: foreground),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.bodyStrong.copyWith(color: foreground),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: foreground,
                    ),
                  ),
              ],
            ),
          ),
          if (trailingText != null)
            Text(
              trailingText!,
              style:
                  trailingStyle ??
                  AppTextStyles.amountMd.copyWith(
                    fontSize: 22,
                    color: foreground,
                  ),
            ),
          if (showChevron) ...<Widget>[
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right_rounded, color: foreground),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: content,
      ),
    );
  }
}
