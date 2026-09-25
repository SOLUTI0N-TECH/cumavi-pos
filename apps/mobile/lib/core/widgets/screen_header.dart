import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Header of a root tab screen: big title, optional subtitle and a trailing
/// action or status pill.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    required this.title,
    this.subtitle,
    this.subtitleWidget,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;

  /// Use instead of [subtitle] when the line mixes colors or styles.
  final Widget? subtitleWidget;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.headline),
              if (subtitleWidget != null)
                subtitleWidget!
              else if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppSpacing.md),
          trailing!,
        ],
      ],
    );
  }
}

/// Header of a pushed screen: circular back (or close) button plus title and
/// subtitle.
class PushedScreenHeader extends StatelessWidget {
  const PushedScreenHeader({
    required this.title,
    required this.onBack,
    this.subtitle,
    this.isCloseAction = false,
    this.trailing,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;

  /// Shows an "x" instead of an arrow, used by full-screen forms.
  final bool isCloseAction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleActionButton(
          icon: isCloseAction ? Icons.close_rounded : Icons.arrow_back_rounded,
          tooltip: isCloseAction
              ? context.l10n.commonCloseTooltip
              : context.l10n.commonBack,
          onPressed: onBack,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.subtitle),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// 48x48 rounded-square icon button used in headers.
class CircleActionButton extends StatelessWidget {
  const CircleActionButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.background = AppColors.surface,
    this.foreground = AppColors.textPrimary,
    this.size = 48,
    super.key,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        minimumSize: Size(size, size),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
    );
  }
}
