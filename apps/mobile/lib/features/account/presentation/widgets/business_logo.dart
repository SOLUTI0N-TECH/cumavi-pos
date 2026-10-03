import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';

/// The business logo, or its initials while it has none. Registration
/// stores a placeholder path for the demo logo, so only real images count.
class BusinessLogo extends StatelessWidget {
  const BusinessLogo({
    required this.initials,
    this.logoPath,
    this.size = 56,
    super.key,
  });

  final String initials;
  final String? logoPath;
  final double size;

  static bool isImage(String? path) =>
      path != null &&
      (path.startsWith('assets/') ||
          path.startsWith('http') ||
          File(path).existsSync());

  @override
  Widget build(BuildContext context) {
    final String? path = logoPath;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: SizedBox.square(
        dimension: size,
        child: isImage(path)
            ? AppImage(path!, width: size, height: size)
            : ColoredBox(
                color: AppColors.ink,
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.bodyLargeStrong.copyWith(
                      color: AppColors.white,
                      fontSize: size * 0.34,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
