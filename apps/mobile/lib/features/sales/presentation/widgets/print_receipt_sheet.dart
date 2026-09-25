import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/quantity_stepper.dart';
import '../../../../core/widgets/segmented_selector.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_options.dart';
import '../cubit/print_receipt_cubit.dart';
import '../cubit/print_receipt_state.dart';

/// Print sheet: paired Bluetooth printer, paper width and copies.
class PrintReceiptSheet extends StatelessWidget {
  const PrintReceiptSheet({required this.receipt, super.key});

  final Receipt receipt;

  /// Opens the sheet with the [PrintReceiptCubit] of the calling screen.
  static Future<void> show(BuildContext context, {required Receipt receipt}) {
    final AppLocalizations l10n = context.l10n;
    final PrintReceiptCubit cubit = context.read<PrintReceiptCubit>()
      ..loadPrinters();
    return AppBottomSheet.show<void>(
      context: context,
      title: l10n.salesPrintSheetTitle,
      subtitle: l10n.salesPrintSheetSubtitle(
        receipt.number,
        MoneyFormatter.format(receipt.sale.total),
      ),
      builder: (_) => BlocProvider<PrintReceiptCubit>.value(
        value: cubit,
        child: PrintReceiptSheet(receipt: receipt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return BlocConsumer<PrintReceiptCubit, PrintReceiptState>(
      listener: (BuildContext context, PrintReceiptState state) {
        if (state.status == PrintReceiptStatus.printed) {
          // Grab the messenger before the sheet's context goes away.
          final ScaffoldMessengerState messenger = ScaffoldMessenger.of(
            context,
          );
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.salesPrintSheetPrintedMessage)),
          );
        }
      },
      builder: (BuildContext context, PrintReceiptState state) {
        final PrintReceiptCubit cubit = context.read<PrintReceiptCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              l10n.salesPrintSheetPrinterLabel,
              style: AppTextStyles.bodySmallStrong.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            _PrinterList(state: state),
            if (state.status == PrintReceiptStatus.failure &&
                state.failure != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              _ErrorNote(message: state.failure!.localizedMessage(l10n)),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.salesPrintSheetPaperLabel,
                        style: AppTextStyles.bodySmallStrong.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SegmentedSelector<ReceiptPaperWidth>(
                        options: const <SegmentOption<ReceiptPaperWidth>>[
                          SegmentOption<ReceiptPaperWidth>(
                            value: ReceiptPaperWidth.mm58,
                            label: '58 mm',
                          ),
                          SegmentOption<ReceiptPaperWidth>(
                            value: ReceiptPaperWidth.mm80,
                            label: '80 mm',
                          ),
                        ],
                        selectedValue: state.paperWidth,
                        selectedColor: AppColors.ink,
                        selectedTextColor: AppColors.white,
                        onSelected: cubit.paperWidthSelected,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.salesPrintSheetCopiesLabel,
                      style: AppTextStyles.bodySmallStrong.copyWith(
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    QuantityStepper(
                      quantity: state.copies,
                      onIncrement: cubit.incrementCopies,
                      onDecrement: cubit.decrementCopies,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: l10n.salesPrintSheetPrintButton,
              icon: Icons.print_outlined,
              isLoading: state.status == PrintReceiptStatus.printing,
              onPressed: state.canPrint ? () => cubit.print(receipt) : null,
            ),
          ],
        );
      },
    );
  }
}

class _PrinterList extends StatelessWidget {
  const _PrinterList({required this.state});

  final PrintReceiptState state;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final PrintReceiptCubit cubit = context.read<PrintReceiptCubit>();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: <Widget>[
          if (state.status == PrintReceiptStatus.loading)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.printers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                l10n.salesPrintSheetNoPrinters,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            for (final PrinterDevice printer in state.printers)
              SelectableTile(
                label: printer.name.isEmpty
                    ? l10n.commonDefaultPrinterName
                    : printer.name,
                icon: Icons.bluetooth_rounded,
                iconColor: AppColors.infoText,
                iconBackground: AppColors.infoSurface,
                supportingText: printer.address,
                isSelected: state.selectedAddress == printer.address,
                onTap: () => cubit.printerSelected(printer.address),
              ),
          TextButton.icon(
            onPressed: state.isBusy ? null : cubit.loadPrinters,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.salesPrintSheetSearchPrinters),
            style: TextButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          ),
        ],
      ),
    );
  }
}

class _ErrorNote extends StatelessWidget {
  const _ErrorNote({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorSurface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: AppColors.errorText,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.errorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
