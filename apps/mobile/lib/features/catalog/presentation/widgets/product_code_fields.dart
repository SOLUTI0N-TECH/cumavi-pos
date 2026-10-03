import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/usecases/product_code_rules.dart';
import '../scanner/barcode_camera.dart';

/// SKU text field: capitals, the format error inline, and an optional
/// [suffix] such as a "Generar" button.
class SkuField extends StatelessWidget {
  const SkuField({
    required this.controller,
    this.onChanged,
    this.suffix,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final Widget? suffix;

  static bool isValid(String sku) => ProductCodeRules.isValidSku(sku);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: ProductCodeRules.maxLength,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: l10n.catalogProductFormSkuHint,
            counterText: '',
            errorText: isValid(value.text) ? null : l10n.failureInvalidSku,
            errorMaxLines: 2,
            suffixIcon: suffix,
          ),
        );
      },
    );
  }
}

/// Barcode text field with a button to scan it instead of typing.
class BarcodeField extends StatelessWidget {
  const BarcodeField({
    required this.controller,
    this.onChanged,
    this.onScan,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  /// Without it there is no scan button.
  final ScanCode? onScan;

  static bool isValid(String barcode) =>
      ProductCodeRules.isValidBarcode(barcode);

  Future<void> _scan(ScanCode scan) async {
    final String? code = await scan();
    if (code == null) return;
    controller.text = code;
    onChanged?.call(code);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (BuildContext context, TextEditingValue value, _) {
        return TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: ProductCodeRules.maxLength,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: l10n.catalogProductFormBarcodeHint,
            counterText: '',
            errorText: isValid(value.text) ? null : l10n.failureInvalidBarcode,
            errorMaxLines: 2,
            suffixIcon: switch (onScan) {
              final ScanCode scan => IconButton(
                tooltip: l10n.commonScanBarcodeTooltip,
                onPressed: () => _scan(scan),
                icon: const Icon(Icons.qr_code_scanner_rounded),
              ),
              null => null,
            },
          ),
        );
      },
    );
  }
}
