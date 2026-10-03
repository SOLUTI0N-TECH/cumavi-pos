import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'barcode_camera.dart';

/// Device camera reading EAN/UPC, Code 128/39 and QR codes with ML Kit
/// (Android) or Vision (iOS). The plugin asks for the camera permission.
final class MobileScannerCamera implements BarcodeCamera {
  const MobileScannerCamera();

  @override
  bool get isLive => true;

  @override
  Widget preview({required ValueChanged<String> onDetected}) =>
      _MobileScannerPreview(onDetected: onDetected);
}

class _MobileScannerPreview extends StatefulWidget {
  const _MobileScannerPreview({required this.onDetected});

  final ValueChanged<String> onDetected;

  @override
  State<_MobileScannerPreview> createState() => _MobileScannerPreviewState();
}

class _MobileScannerPreviewState extends State<_MobileScannerPreview> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const <BarcodeFormat>[
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.qrCode,
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final String? code = capture.barcodes
        .map((Barcode barcode) => barcode.rawValue)
        .whereType<String>()
        .where((String value) => value.trim().isNotEmpty)
        .firstOrNull;
    if (code != null) widget.onDetected(code);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
          errorBuilder: (BuildContext context, MobileScannerException error) =>
              _CameraError(error: error),
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (BuildContext context, MobileScannerState state, _) {
              if (state.torchState == TorchState.unavailable) {
                return const SizedBox.shrink();
              }
              final bool on = state.torchState == TorchState.on;
              return IconButton.filled(
                tooltip: context.l10n.scannerTorchTooltip,
                onPressed: _controller.toggleTorch,
                style: IconButton.styleFrom(
                  backgroundColor: on
                      ? AppColors.white
                      : AppColors.ink.withValues(alpha: 0.6),
                  foregroundColor: on ? AppColors.ink : AppColors.white,
                ),
                icon: Icon(
                  on ? Icons.flashlight_on_rounded : Icons.flashlight_off,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool denied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return ColoredBox(
      color: AppColors.ink,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.no_photography_outlined,
                color: AppColors.white,
                size: 36,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                denied
                    ? l10n.failureCameraPermissionDenied
                    : l10n.failureCameraUnavailable,
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
