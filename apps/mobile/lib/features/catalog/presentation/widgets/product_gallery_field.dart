import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/product_image.dart';
import '../../domain/services/photo_capturer.dart';
import 'photo_source_sheet.dart';

/// "Más fotos" strip of the product form: the photos after the main one
/// (other colors, other angles), which the variants can then use.
class ProductGalleryField extends StatelessWidget {
  const ProductGalleryField({
    required this.images,
    required this.onAdd,
    required this.onRemove,
    super.key,
  });

  static const double _tileSize = 76;

  /// Extra photos, without the main one.
  final List<ProductImage> images;
  final VoidCallback onAdd;

  /// Called with the id of the photo to remove.
  final ValueChanged<String> onRemove;

  /// Camera or gallery for an extra photo which, unlike the main one, keeps
  /// its background. `null` when dismissed.
  static Future<PhotoSource?> pickSource(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return AppBottomSheet.show<PhotoSource>(
      context: context,
      title: l10n.catalogProductFormGallerySourceTitle,
      subtitle: l10n.catalogProductFormGallerySourceSubtitle,
      builder: (_) => const PhotoSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            l10n.catalogProductFormGalleryTitle,
            style: AppTextStyles.bodyLargeStrong,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            l10n.catalogProductFormGalleryCaption,
            style: AppTextStyles.captionSmall,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: _tileSize,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                if (index == images.length) {
                  return _AddPhotoTile(size: _tileSize, onTap: onAdd);
                }
                final ProductImage image = images[index];
                return _GalleryThumbnail(
                  image: image,
                  size: _tileSize,
                  onRemove: () => onRemove(image.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  const _GalleryThumbnail({
    required this.image,
    required this.size,
    required this.onRemove,
  });

  final ProductImage image;
  final double size;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
                border: Border.all(color: AppColors.dividerSoft),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md + 2),
                child: AppImage(image.path),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: Tooltip(
              message: context.l10n.catalogProductFormGalleryRemoveTooltip,
              child: InkResponse(
                onTap: onRemove,
                radius: 18,
                // A larger hit area than the badge, which is kept small so
                // it does not hide the photo.
                child: SizedBox.square(
                  dimension: 30,
                  child: Center(
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(AppRadius.md + 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md + 2),
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md + 2),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.add_photo_alternate_outlined, size: 22),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.catalogProductFormGalleryAdd,
                style: AppTextStyles.micro.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
