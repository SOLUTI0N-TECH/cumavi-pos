import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/entities/product_photo.dart';

/// Photo block of the product form: preview, edit shortcuts and the
/// "Quitar fondo" switch.
class ProductPhotoField extends StatelessWidget {
  const ProductPhotoField({
    required this.photo,
    required this.removeBackground,
    required this.isProcessing,
    required this.onCapture,
    required this.onAdjust,
    required this.onToggleBackground,
    super.key,
  });

  final ProductPhoto? photo;
  final bool removeBackground;
  final bool isProcessing;
  final VoidCallback onCapture;
  final VoidCallback onAdjust;
  final ValueChanged<bool> onToggleBackground;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(
            height: 220,
            child: photo == null
                ? _EmptyPhoto(onCapture: onCapture)
                : _PhotoPreview(
                    photo: photo!,
                    isProcessing: isProcessing,
                    removeBackground: removeBackground,
                    onCapture: onCapture,
                    onAdjust: onAdjust,
                  ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            // Grows when the description wraps on narrow phones.
            constraints: const BoxConstraints(minHeight: 60),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 6),
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.infoSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_outlined,
                    size: 20,
                    color: AppColors.infoText,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.catalogPhotoFieldRemoveBackgroundLabel,
                        style: AppTextStyles.bodyStrong,
                      ),
                      Text(
                        isProcessing
                            ? l10n.catalogPhotoFieldProcessing
                            : l10n.catalogPhotoFieldRemoveBackgroundDescription,
                        style: AppTextStyles.captionSmall,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: removeBackground,
                  onChanged: photo == null || isProcessing
                      ? null
                      : onToggleBackground,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPhoto extends StatelessWidget {
  const _EmptyPhoto({required this.onCapture});

  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return InkWell(
      onTap: onCapture,
      borderRadius: BorderRadius.circular(AppRadius.lg + 2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          border: Border.all(color: AppColors.border, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.photo_camera_outlined, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.catalogPhotoFieldEmptyTitle,
              style: AppTextStyles.bodySmallStrong,
            ),
            Text(
              l10n.catalogPhotoFieldEmptySubtitle,
              style: AppTextStyles.captionSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({
    required this.photo,
    required this.isProcessing,
    required this.removeBackground,
    required this.onCapture,
    required this.onAdjust,
  });

  final ProductPhoto photo;
  final bool isProcessing;
  final bool removeBackground;
  final VoidCallback onCapture;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        border: Border.all(color: AppColors.dividerSoft),
      ),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg + 2),
              child: AppImage(photo.displayPath, fit: BoxFit.contain),
            ),
          ),
          if (isProcessing)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                child: ColoredBox(
                  color: AppColors.white.withValues(alpha: 0.72),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            )
          else if (removeBackground && photo.hasCutout)
            Positioned(
              top: 10,
              left: 10,
              child: StatusPill(
                label: l10n.catalogPhotoFieldBackgroundRemovedBadge,
                icon: Icons.auto_awesome_outlined,
                background: AppColors.infoSurface,
                foreground: AppColors.infoText,
                height: 28,
              ),
            ),
          Positioned(
            right: 10,
            bottom: 10,
            child: Row(
              children: <Widget>[
                if (photo.hasCutout)
                  TextButton.icon(
                    onPressed: isProcessing ? null : onAdjust,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: Text(l10n.catalogPhotoFieldAdjust),
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.surface,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      minimumSize: const Size(0, 40),
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: AppColors.divider),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: isProcessing ? null : onCapture,
                  tooltip: l10n.catalogPhotoFieldChangePhotoTooltip,
                  icon: const Icon(Icons.photo_camera_outlined, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.ink,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(40, 40),
                    shape: const CircleBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
