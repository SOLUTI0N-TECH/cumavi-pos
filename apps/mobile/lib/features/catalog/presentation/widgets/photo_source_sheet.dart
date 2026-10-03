import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../domain/services/photo_capturer.dart';

/// Lets the seller choose between the camera and the gallery.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key});

  /// Returns the chosen source, or `null` when dismissed. The title and
  /// subtitle default to the product photo's.
  static Future<PhotoSource?> show(
    BuildContext context, {
    String? title,
    String? subtitle,
  }) {
    final AppLocalizations l10n = context.l10n;

    return AppBottomSheet.show<PhotoSource>(
      context: context,
      title: title ?? l10n.catalogPhotoSourceTitle,
      subtitle: subtitle ?? l10n.catalogPhotoSourceSubtitle,
      builder: (_) => const PhotoSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SelectableTile(
          label: l10n.catalogPhotoSourceCamera,
          supportingText: l10n.catalogPhotoSourceCameraDescription,
          icon: Icons.photo_camera_outlined,
          iconColor: AppColors.infoText,
          iconBackground: AppColors.infoSurface,
          isSelected: false,
          onTap: () => Navigator.of(context).pop(PhotoSource.camera),
        ),
        const SizedBox(height: AppSpacing.sm),
        SelectableTile(
          label: l10n.catalogPhotoSourceGallery,
          supportingText: l10n.catalogPhotoSourceGalleryDescription,
          icon: Icons.photo_library_outlined,
          iconColor: AppColors.violetText,
          iconBackground: AppColors.violetSurface,
          isSelected: false,
          onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
        ),
      ],
    );
  }
}
