import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';

/// Draggable before/after comparison: the original photo on the left, the
/// processed one on the right, split by a handle the user can slide.
class BeforeAfterPhoto extends StatefulWidget {
  const BeforeAfterPhoto({
    required this.beforePath,
    required this.afterPath,
    this.beforeLabel,
    this.afterLabel,
    super.key,
  });

  final String beforePath;
  final String afterPath;

  /// Tag of the original side; "Original" when `null`.
  final String? beforeLabel;

  /// Tag of the processed side; "Sin fondo" when `null`.
  final String? afterLabel;

  @override
  State<BeforeAfterPhoto> createState() => _BeforeAfterPhotoState();
}

class _BeforeAfterPhotoState extends State<BeforeAfterPhoto> {
  /// Horizontal position of the divider, from 0 (all original) to 1.
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;

        void updateSplit(double dx) {
          setState(() => _split = (dx / width).clamp(0.05, 0.95));
        }

        return GestureDetector(
          onPanDown: (DragDownDetails details) =>
              updateSplit(details.localPosition.dx),
          onPanUpdate: (DragUpdateDetails details) =>
              updateSplit(details.localPosition.dx),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xxl + 2),
            child: ColoredBox(
              color: AppColors.white,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  AppImage(widget.beforePath),
                  ClipRect(
                    clipper: _RightSideClipper(fraction: _split),
                    child: AppImage(widget.afterPath),
                  ),
                  Positioned(
                    left: width * _split - 2,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 4, color: AppColors.white),
                  ),
                  Positioned(
                    left: width * _split - 22,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Container(
                        height: 44,
                        width: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Color(0x47000000),
                              blurRadius: 14,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.swap_horiz_rounded, size: 22),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _PhotoLabel(
                      label:
                          widget.beforeLabel ??
                          l10n.catalogBeforeAfterBeforeLabel,
                      background: const Color(0xB8141213),
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _PhotoLabel(
                      label:
                          widget.afterLabel ??
                          l10n.catalogBeforeAfterAfterLabel,
                      background: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Keeps only the portion to the right of [fraction].
class _RightSideClipper extends CustomClipper<Rect> {
  const _RightSideClipper({required this.fraction});

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * fraction, 0, size.width, size.height);

  @override
  bool shouldReclip(_RightSideClipper oldClipper) =>
      oldClipper.fraction != fraction;
}

class _PhotoLabel extends StatelessWidget {
  const _PhotoLabel({required this.label, required this.background});

  final String label;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.captionSmallStrong.copyWith(
          color: AppColors.white,
        ),
      ),
    );
  }
}
