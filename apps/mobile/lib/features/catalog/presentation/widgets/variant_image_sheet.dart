import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_image.dart';
import '../../domain/entities/product_image.dart';

/// What the seller chose in [VariantImageSheet].
final class VariantImageChoice {
  /// One of the product's photos; `null` [imageId] is the main photo.
  const VariantImageChoice.image(this.imageId, {required this.applyToGroup})
    : addNew = false;

  /// Take or pick a new photo and use it.
  const VariantImageChoice.addNew({required this.applyToGroup})
    : imageId = null,
      addNew = true;

  final String? imageId;
  final bool addNew;

  /// Whether every variant with the same grouped value (all the `Rojo`
  /// ones) gets the photo too.
  final bool applyToGroup;
}

/// Lets the seller pick which of the product's photos a variant shows, or
/// add a new one.
class VariantImageSheet extends StatefulWidget {
  const VariantImageSheet({
    required this.mainImagePath,
    required this.extraImages,
    required this.selectedImageId,
    this.groupValue,
    super.key,
  });

  /// `null` while the product has no main photo.
  final String? mainImagePath;
  final List<ProductImage> extraImages;

  /// Current photo of the variant; `null` is the main photo.
  final String? selectedImageId;

  /// Grouped value of the variant (`Rojo`); offers applying the photo to
  /// its whole group when set.
  final String? groupValue;

  /// Returns the choice, or `null` when dismissed.
  static Future<VariantImageChoice?> show(
    BuildContext context, {
    required String variantLabel,
    required String? mainImagePath,
    required String mainImageId,
    required List<ProductImage> extraImages,
    required String? selectedImageId,
    String? groupValue,
  }) {
    return AppBottomSheet.show<VariantImageChoice>(
      context: context,
      title: context.l10n.catalogVariantImageSheetTitle,
      subtitle: variantLabel,
      builder: (_) => VariantImageSheet(
        mainImagePath: mainImagePath,
        extraImages: extraImages,
        // The main photo can be referenced by its id too.
        selectedImageId: selectedImageId == mainImageId
            ? null
            : selectedImageId,
        groupValue: groupValue,
      ),
    );
  }

  @override
  State<VariantImageSheet> createState() => _VariantImageSheetState();
}

class _VariantImageSheetState extends State<VariantImageSheet> {
  // A photo per color is the usual case, so it starts on.
  bool _applyToGroup = true;

  bool get _groupApplies => widget.groupValue != null && _applyToGroup;

  void _choose(String? imageId) =>
      Navigator.of(context)
          .pop(VariantImageChoice.image(imageId, applyToGroup: _groupApplies));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String? groupValue = widget.groupValue;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (groupValue != null) ...<Widget>[
          Container(
            padding: const EdgeInsets.only(left: AppSpacing.lg, right: 6),
            constraints: const BoxConstraints(minHeight: 56),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    l10n.catalogVariantImageApplyToGroup(groupValue),
                    style: AppTextStyles.bodySmallStrong,
                  ),
                ),
                Switch(
                  value: _applyToGroup,
                  onChanged: (bool value) =>
                      setState(() => _applyToGroup = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        if (widget.extraImages.isEmpty) ...<Widget>[
          Text(
            l10n.catalogVariantImageGalleryHint,
            style: AppTextStyles.captionSmall,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.5,
          ),
          child: SingleChildScrollView(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                const int columns = 3;
                final double size =
                    (constraints.maxWidth - AppSpacing.sm * (columns - 1)) /
                    columns;
                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: <Widget>[
                    _PhotoChoice(
                      path: widget.mainImagePath,
                      size: size,
                      caption: l10n.catalogVariantImageMain,
                      isSelected: widget.selectedImageId == null,
                      onTap: () => _choose(null),
                    ),
                    for (final ProductImage image in widget.extraImages)
                      _PhotoChoice(
                        path: image.path,
                        size: size,
                        isSelected: widget.selectedImageId == image.id,
                        onTap: () => _choose(image.id),
                      ),
                    _AddPhotoChoice(
                      size: size,
                      onTap: () => Navigator.of(context).pop(
                        VariantImageChoice.addNew(applyToGroup: _groupApplies),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PhotoChoice extends StatelessWidget {
  const _PhotoChoice({
    required this.path,
    required this.size,
    required this.isSelected,
    required this.onTap,
    this.caption,
  });

  final String? path;
  final double size;
  final bool isSelected;
  final VoidCallback onTap;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final String? path = this.path;
    final String? caption = this.caption;
    final BorderRadius radius = BorderRadius.circular(AppRadius.lg);

    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: radius,
            border: Border.all(
              color: isSelected ? AppColors.ink : AppColors.divider,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                if (path == null)
                  const Icon(
                    Icons.image_outlined,
                    color: AppColors.textSecondary,
                  )
                else
                  AppImage(path),
                if (caption != null)
                  Positioned(
                    left: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        caption,
                        style: AppTextStyles.micro.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (isSelected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      height: 22,
                      width: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPhotoChoice extends StatelessWidget {
  const _AddPhotoChoice({required this.size, required this.onTap});

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadius.lg);

    return Material(
      color: AppColors.surface,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.add_a_photo_outlined, size: 22),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.l10n.catalogVariantImageAdd,
                style: AppTextStyles.captionSmallStrong.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
