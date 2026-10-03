import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/usecases/product_code_rules.dart';
import 'barcode_camera.dart';

/// A code the seller can tap to try the scanner without printed labels.
typedef DemoScanCode = ({String label, String code});

/// Reads a barcode with the camera, or takes one typed by hand (also what a
/// Bluetooth scanner "types"), and hands it back through [onCode] once.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    required this.purpose,
    required this.camera,
    required this.onCode,
    required this.onClose,
    this.demoCodes = const <DemoScanCode>[],
    super.key,
  });

  final ScanPurpose purpose;
  final BarcodeCamera camera;
  final ValueChanged<String> onCode;
  final VoidCallback onClose;

  /// Shown while the catalog is mocked, so every flow can be tried.
  final List<DemoScanCode> demoCodes;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The camera keeps reading while it points at a label: only the first
  /// code counts.
  void _finish(String code) {
    final String? normalized = ProductCodeRules.normalizeOrNull(code);
    if (_done || normalized == null) return;
    _done = true;
    HapticFeedback.mediumImpact();
    widget.onCode(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final (String title, String subtitle) = switch (widget.purpose) {
      ScanPurpose.sell => (l10n.scannerSellTitle, l10n.scannerSellSubtitle),
      ScanPurpose.find => (l10n.scannerFindTitle, l10n.scannerFindSubtitle),
      ScanPurpose.assign => (
        l10n.scannerAssignTitle,
        l10n.scannerAssignSubtitle,
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            AppSpacing.xl,
            AppSpacing.pageHorizontal,
            AppSpacing.xxl,
          ),
          children: <Widget>[
            PushedScreenHeader(
              title: title,
              subtitle: subtitle,
              onBack: widget.onClose,
              isCloseAction: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    widget.camera.preview(onDetected: _finish),
                    const IgnorePointer(child: _ScanFrame()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    l10n.scannerTypeTitle,
                    style: AppTextStyles.bodyLargeStrong,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          maxLength: ProductCodeRules.maxLength,
                          textCapitalization: TextCapitalization.characters,
                          textInputAction: TextInputAction.search,
                          onSubmitted: _finish,
                          decoration: InputDecoration(
                            hintText: l10n.scannerTypeHint,
                            counterText: '',
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _controller,
                        builder:
                            (
                              BuildContext context,
                              TextEditingValue value,
                              Widget? child,
                            ) => IconButton.filled(
                              tooltip: l10n.scannerTypeSubmit,
                              onPressed: value.text.trim().isEmpty
                                  ? null
                                  : () => _finish(value.text),
                              icon: const Icon(Icons.arrow_forward_rounded),
                            ),
                      ),
                    ],
                  ),
                  if (widget.demoCodes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.scannerDemoCodesTitle,
                      style: AppTextStyles.bodySmallStrong,
                    ),
                    Text(
                      l10n.scannerDemoCodesCaption,
                      style: AppTextStyles.captionSmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: <Widget>[
                        for (final DemoScanCode demo in widget.demoCodes)
                          ActionChip(
                            avatar: const Icon(
                              Icons.qr_code_2_rounded,
                              size: 18,
                            ),
                            label: Text(demo.label),
                            tooltip: demo.code,
                            onPressed: () => _finish(demo.code),
                            backgroundColor: AppColors.surface,
                            side: const BorderSide(color: AppColors.borderSoft),
                            shape: const StadiumBorder(),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Corner marks over the preview, where the label should go.
class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: CustomPaint(painter: _CornersPainter()),
    );
  }
}

class _CornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double arm = 28;
    final Paint paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final double right = size.width;
    final double bottom = size.height;

    canvas
      ..drawPath(
        Path()
          ..moveTo(0, arm)
          ..lineTo(0, 0)
          ..lineTo(arm, 0),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(right - arm, 0)
          ..lineTo(right, 0)
          ..lineTo(right, arm),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(0, bottom - arm)
          ..lineTo(0, bottom)
          ..lineTo(arm, bottom),
        paint,
      )
      ..drawPath(
        Path()
          ..moveTo(right - arm, bottom)
          ..lineTo(right, bottom)
          ..lineTo(right, bottom - arm),
        paint,
      );
  }

  @override
  bool shouldRepaint(_CornersPainter oldDelegate) => false;
}
