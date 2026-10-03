import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'barcode_camera.dart';

/// Stand-in for the camera where there is none (tests, desktop). The
/// scanner screen keeps working through typed and demo codes.
final class DemoBarcodeCamera implements BarcodeCamera {
  const DemoBarcodeCamera();

  @override
  bool get isLive => false;

  @override
  Widget preview({required ValueChanged<String> onDetected}) =>
      const _DemoPreview();
}

class _DemoPreview extends StatelessWidget {
  const _DemoPreview();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.white,
                size: 40,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.scannerDemoCamera,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
