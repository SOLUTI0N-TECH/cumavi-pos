import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/product_variant.dart';
import '../scanner/barcode_camera.dart';
import 'product_code_fields.dart';

/// SKU and barcode typed or scanned for one variant.
typedef VariantCodes = ({String sku, String barcode});

/// Edits the codes of one variant (`Rojo · 38`).
class VariantCodesSheet extends StatefulWidget {
  const VariantCodesSheet({required this.variant, this.onScan, super.key});

  final ProductVariant variant;
  final ScanCode? onScan;

  /// The codes to save, or `null` when the seller closes the sheet.
  static Future<VariantCodes?> show(
    BuildContext context, {
    required ProductVariant variant,
    ScanCode? onScan,
  }) {
    return AppBottomSheet.show<VariantCodes>(
      context: context,
      title: context.l10n.catalogVariantCodesTitle(variant.label),
      builder: (_) => VariantCodesSheet(variant: variant, onScan: onScan),
    );
  }

  @override
  State<VariantCodesSheet> createState() => _VariantCodesSheetState();
}

class _VariantCodesSheetState extends State<VariantCodesSheet> {
  late final TextEditingController _sku = TextEditingController(
    text: widget.variant.sku ?? '',
  );
  late final TextEditingController _barcode = TextEditingController(
    text: widget.variant.barcode ?? '',
  );

  @override
  void dispose() {
    _sku.dispose();
    _barcode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ListenableBuilder(
        listenable: Listenable.merge(<Listenable>[_sku, _barcode]),
        builder: (BuildContext context, _) {
          final bool valid =
              SkuField.isValid(_sku.text) &&
              BarcodeField.isValid(_barcode.text);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              LabeledField(
                label: l10n.catalogProductFormSkuLabel,
                optionalText: l10n.catalogProductFormOptional,
                child: SkuField(controller: _sku),
              ),
              const SizedBox(height: AppSpacing.lg),
              LabeledField(
                label: l10n.catalogProductFormBarcodeLabel,
                optionalText: l10n.catalogProductFormOptional,
                child: BarcodeField(
                  controller: _barcode,
                  onScan: widget.onScan,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: l10n.commonSave,
                icon: Icons.check_rounded,
                onPressed: valid
                    ? () => Navigator.of(context).pop<VariantCodes>((
                        sku: _sku.text,
                        barcode: _barcode.text,
                      ))
                    : null,
              ),
            ],
          );
        },
      ),
    );
  }
}
