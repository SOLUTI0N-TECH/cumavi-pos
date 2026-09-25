import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/services/photo_capturer.dart';
import '../cubit/product_form_cubit.dart';
import '../cubit/product_form_state.dart';
import '../widgets/before_after_photo.dart';

/// Photo editor: compares the original with the cutout and picks the
/// background the catalog will use.
class BackgroundRemovalScreen extends StatelessWidget {
  const BackgroundRemovalScreen({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: BlocBuilder<ProductFormCubit, ProductFormState>(
          builder: (BuildContext context, ProductFormState state) {
            final ProductPhoto? photo = state.photo;
            if (photo == null) {
              return Center(
                child: Text(
                  l10n.catalogBackgroundRemovalNoPhoto,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              );
            }

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    0,
                  ),
                  child: Row(
                    children: <Widget>[
                      CircleActionButton(
                        icon: Icons.arrow_back_rounded,
                        tooltip: l10n.commonBack,
                        background: AppColors.white.withValues(alpha: 0.10),
                        foreground: AppColors.white,
                        onPressed: onDone,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.catalogBackgroundRemovalTitle,
                              style: AppTextStyles.subtitle.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            Text(
                              state.name.isEmpty
                                  ? l10n.catalogBackgroundRemovalDefaultSubtitle
                                  : state.name,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.68),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                      AppSpacing.pageHorizontal,
                      AppSpacing.lg,
                    ),
                    child: BeforeAfterPhoto(
                      beforePath: photo.originalPath,
                      afterPath:
                          photo.whiteBackgroundPath ??
                          photo.cutoutPath ??
                          photo.originalPath,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 24,
                        width: 24,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: Text(
                          l10n.catalogBackgroundRemovalDone,
                          style: AppTextStyles.bodyStrong.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      Text(
                        l10n.catalogBackgroundRemovalCompareHint,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.white.withValues(alpha: 0.68),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: _BackgroundOptions(photo: photo),
                ),
                const SizedBox(height: AppSpacing.xl),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    0,
                    AppSpacing.pageHorizontal,
                    AppSpacing.xxl,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            context.read<ProductFormCubit>().capturePhoto(
                              PhotoSource.camera,
                            );
                          },
                          icon: const Icon(
                            Icons.photo_camera_outlined,
                            size: 20,
                          ),
                          label: Text(l10n.catalogBackgroundRemovalRetake),
                          style: TextButton.styleFrom(
                            backgroundColor: AppColors.white.withValues(
                              alpha: 0.10,
                            ),
                            foregroundColor: AppColors.white,
                            minimumSize: const Size.fromHeight(58),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.xl),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 2),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: onDone,
                          icon: const Icon(Icons.check_rounded, size: 20),
                          label: Text(l10n.catalogBackgroundRemovalUsePhoto),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.ink,
                            minimumSize: const Size.fromHeight(58),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BackgroundOptions extends StatelessWidget {
  const _BackgroundOptions({required this.photo});

  final ProductPhoto photo;

  @override
  Widget build(BuildContext context) {
    final ProductFormCubit cubit = context.read<ProductFormCubit>();
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        _BackgroundOption(
          label: l10n.catalogBackgroundOptionWhite,
          imagePath: photo.whiteBackgroundPath ?? photo.originalPath,
          isSelected: photo.background == PhotoBackground.white,
          onTap: () => cubit.backgroundSelected(PhotoBackground.white),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        _BackgroundOption(
          label: l10n.catalogBackgroundOptionTransparent,
          imagePath: photo.cutoutPath ?? photo.originalPath,
          isSelected: photo.background == PhotoBackground.transparent,
          showCheckerboard: true,
          onTap: () => cubit.backgroundSelected(PhotoBackground.transparent),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        _BackgroundOption(
          label: l10n.catalogBackgroundOptionOriginal,
          imagePath: photo.originalPath,
          isSelected: photo.background == PhotoBackground.original,
          onTap: () => cubit.backgroundSelected(PhotoBackground.original),
        ),
      ],
    );
  }
}

class _BackgroundOption extends StatelessWidget {
  const _BackgroundOption({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    this.showCheckerboard = false,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showCheckerboard;

  @override
  Widget build(BuildContext context) {
    const Color surface = Color(0xFF3A3536);

    return Expanded(
      child: Semantics(
        selected: isSelected,
        button: true,
        child: Material(
          color: surface,
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg + 2),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg + 2),
                border: Border.all(
                  color: isSelected ? AppColors.white : surface,
                  width: 2,
                ),
              ),
              child: Column(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: SizedBox(
                      height: 58,
                      width: double.infinity,
                      child: showCheckerboard
                          ? CustomPaint(
                              painter: const _CheckerboardPainter(),
                              child: AppImage(imagePath),
                            )
                          : ColoredBox(
                              color: AppColors.white,
                              child: AppImage(imagePath),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Grey/white squares that signal transparency.
class _CheckerboardPainter extends CustomPainter {
  const _CheckerboardPainter();

  static const double squareSize = 12;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint light = Paint()..color = AppColors.white;
    final Paint dark = Paint()..color = const Color(0xFFD6D6D6);

    canvas.drawRect(Offset.zero & size, light);
    for (double y = 0; y < size.height; y += squareSize) {
      for (double x = 0; x < size.width; x += squareSize) {
        final bool isDark =
            ((x / squareSize).floor() + (y / squareSize).floor()).isOdd;
        if (!isDark) continue;
        canvas.drawRect(Rect.fromLTWH(x, y, squareSize, squareSize), dark);
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) => false;
}
