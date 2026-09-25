import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Small tinted label: cash drawer state, stock level, payment method.
class StatusPill extends StatelessWidget {
  const StatusPill({
    required this.label,
    this.icon,
    this.background = AppColors.divider,
    this.foreground = AppColors.inkSoft,
    this.dotColor,
    this.trailingIcon,
    this.onTap,
    this.height = 34,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  /// Small leading dot, used by the "Caja abierta" indicator.
  final Color? dotColor;
  final IconData? trailingIcon;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: onTap == null ? 12 : 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (dotColor != null) ...<Widget>[
            Container(
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (trailingIcon != null) ...<Widget>[
            const SizedBox(width: 6),
            Icon(trailingIcon, size: 16, color: foreground),
          ],
        ],
      ),
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: content,
    );
  }
}
