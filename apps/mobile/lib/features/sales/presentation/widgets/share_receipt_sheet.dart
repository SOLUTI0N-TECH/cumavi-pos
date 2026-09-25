import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/segmented_selector.dart';
import '../../domain/entities/receipt.dart';
import '../../domain/entities/receipt_options.dart';
import '../../domain/entities/receipt_share_target.dart';
import '../cubit/share_receipt_cubit.dart';
import '../cubit/share_receipt_state.dart';

/// Share sheet: format, direct WhatsApp send and the usual destinations.
class ShareReceiptSheet extends StatefulWidget {
  const ShareReceiptSheet({required this.receipt, super.key});

  final Receipt receipt;

  /// Opens the sheet with the [ShareReceiptCubit] of the calling screen.
  static Future<void> show(BuildContext context, {required Receipt receipt}) {
    final ShareReceiptCubit cubit = context.read<ShareReceiptCubit>();
    return AppBottomSheet.show<void>(
      context: context,
      title: context.l10n.salesShareSheetTitle,
      builder: (_) => BlocProvider<ShareReceiptCubit>.value(
        value: cubit,
        child: ShareReceiptSheet(receipt: receipt),
      ),
    );
  }

  @override
  State<ShareReceiptSheet> createState() => _ShareReceiptSheetState();
}

class _ShareReceiptSheetState extends State<ShareReceiptSheet> {
  late final TextEditingController _phoneController = TextEditingController(
    text: context.read<ShareReceiptCubit>().state.phoneNumber,
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String _confirmationFor(ReceiptShareTarget? target, AppLocalizations l10n) =>
      switch (target) {
        WhatsAppShareTarget() => l10n.salesShareSheetWhatsAppOpening,
        EmailShareTarget() => l10n.salesShareSheetEmailOpening,
        DeviceStorageShareTarget() => l10n.salesShareSheetSaved,
        SystemShareTarget() || null => l10n.salesShareSheetReady,
      };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return BlocConsumer<ShareReceiptCubit, ShareReceiptState>(
      listener: (BuildContext context, ShareReceiptState state) {
        final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
        if (state.status == ShareReceiptStatus.shared) {
          Navigator.of(context).pop();
          messenger.showSnackBar(
            SnackBar(content: Text(_confirmationFor(state.lastTarget, l10n))),
          );
        }
        if (state.status == ShareReceiptStatus.failure &&
            state.failure != null) {
          messenger.showSnackBar(
            SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
          );
        }
      },
      builder: (BuildContext context, ShareReceiptState state) {
        final ShareReceiptCubit cubit = context.read<ShareReceiptCubit>();
        final Receipt receipt = widget.receipt;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ReceiptPreviewRow(receipt: receipt),
            const SizedBox(height: AppSpacing.lg + 2),
            Text(
              l10n.salesShareSheetFormatLabel,
              style: AppTextStyles.bodySmallStrong.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SegmentedSelector<ReceiptFileFormat>(
              options: <SegmentOption<ReceiptFileFormat>>[
                SegmentOption<ReceiptFileFormat>(
                  value: ReceiptFileFormat.image,
                  label: l10n.salesShareSheetImageFormat,
                  icon: Icons.image_outlined,
                ),
                const SegmentOption<ReceiptFileFormat>(
                  value: ReceiptFileFormat.pdf,
                  label: 'PDF',
                  icon: Icons.description_outlined,
                ),
              ],
              selectedValue: state.format,
              onSelected: cubit.formatSelected,
            ),
            const SizedBox(height: AppSpacing.lg + 2),
            Text(
              l10n.salesShareSheetWhatsAppLabel,
              style: AppTextStyles.bodySmallStrong.copyWith(
                color: AppColors.inkSoft,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: <Widget>[
                Container(
                  height: 56,
                  width: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: AppRadius.input,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('+591', style: AppTextStyles.bodySmallStrong),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    onChanged: cubit.phoneNumberChanged,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: l10n.salesShareSheetPhoneHint,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: state.isSharing
                      ? null
                      : () => cubit.sendToWhatsApp(receipt),
                  tooltip: l10n.salesShareSheetWhatsAppTooltip,
                  icon: const Icon(Icons.send_rounded, size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.successText,
                    foregroundColor: AppColors.white,
                    minimumSize: const Size(56, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              l10n.salesShareSheetWhatsAppHint,
              style: AppTextStyles.captionSmall,
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: <Widget>[
                _ShareTarget(
                  icon: Icons.download_rounded,
                  label: l10n.salesShareSheetSaveTarget,
                  onTap: state.isSharing
                      ? null
                      : () => cubit.share(
                          receipt,
                          const DeviceStorageShareTarget(),
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ShareTarget(
                  icon: Icons.mail_outline_rounded,
                  label: l10n.salesShareSheetEmailTarget,
                  onTap: state.isSharing
                      ? null
                      : () => cubit.share(receipt, const EmailShareTarget()),
                ),
                const SizedBox(width: AppSpacing.sm),
                _ShareTarget(
                  icon: Icons.ios_share_rounded,
                  label: l10n.salesShareSheetOtherAppsTarget,
                  onTap: state.isSharing
                      ? null
                      : () => cubit.share(receipt, const SystemShareTarget()),
                ),
              ],
            ),
            if (state.isSharing) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              const LinearProgressIndicator(),
            ],
          ],
        );
      },
    );
  }
}

class _ReceiptPreviewRow extends StatelessWidget {
  const _ReceiptPreviewRow({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: <Widget>[
          Container(
            height: 74,
            width: 58,
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: <Widget>[
                Container(
                  height: 16,
                  width: 16,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 5),
                for (int index = 0; index < 3; index++) ...<Widget>[
                  Container(
                    height: 3,
                    width: index == 2 ? 26 : double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.borderSoft,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textPlaceholder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  l10n.receiptNumberTitle(receipt.number),
                  style: AppTextStyles.bodyStrong,
                ),
                Text(
                  l10n.salesShareSheetReceiptSummary(
                    MoneyFormatter.format(receipt.sale.total),
                    receipt.sale.paymentMethod.localizedName(l10n),
                    l10n.itemCount(receipt.sale.itemCount),
                  ),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareTarget extends StatelessWidget {
  const _ShareTarget({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.lg + 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          child: SizedBox(
            height: 88,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  style: AppTextStyles.captionSmallStrong.copyWith(
                    color: AppColors.textPrimary,
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
