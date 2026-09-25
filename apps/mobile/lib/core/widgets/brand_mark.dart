import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Cumavi price-tag logo plus the "Cumavi POS" wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({this.size = 52, this.showWordmark = true, super.key});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          AppAssets.logoTag,
          height: size,
          width: size,
          fit: BoxFit.contain,
        ),
        if (showWordmark) ...<Widget>[
          const SizedBox(width: 8),
          Text.rich(
            TextSpan(
              text: 'Cumavi ',
              style: AppTextStyles.subtitle,
              children: <InlineSpan>[
                TextSpan(
                  text: 'POS',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Rounded square with the business initials, used as its avatar while no
/// logo has been uploaded.
class BusinessAvatar extends StatelessWidget {
  const BusinessAvatar({
    required this.initials,
    this.size = 52,
    this.fontSize = 20,
    this.borderRadius = 16,
    super.key,
  });

  final String initials;
  final double size;
  final double fontSize;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        initials,
        style: AppTextStyles.subtitle.copyWith(
          color: AppColors.white,
          fontSize: fontSize,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
