import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../domain/services/store_poster_service.dart';

/// "Póster QR": a preview of the "Escanea y pide" poster, to share as a PDF
/// or print and stick on the counter or the door.
class StorePosterScreen extends StatefulWidget {
  const StorePosterScreen({
    required this.poster,
    required this.service,
    required this.onBack,
    super.key,
  });

  final StorePoster poster;
  final StorePosterService service;
  final VoidCallback onBack;

  @override
  State<StorePosterScreen> createState() => _StorePosterScreenState();
}

class _StorePosterScreenState extends State<StorePosterScreen> {
  bool _busy = false;

  Future<void> _run(Future<Result<void>> Function() action) async {
    setState(() => _busy = true);
    final Failure? failure = (await action()).failureOrNull;
    if (!mounted) return;
    setState(() => _busy = false);
    if (failure != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final StorePoster poster = widget.poster;
    final String qr = Barcode.qrCode().toSvg(
      poster.url,
      width: 220,
      height: 220,
      color: 0x292526,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
                AppSpacing.pageHorizontal,
                0,
              ),
              child: PushedScreenHeader(
                title: l10n.onlineStorePosterAction,
                subtitle: l10n.onlineStorePosterScreenSubtitle,
                onBack: widget.onBack,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xxl,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Color(0x14292526),
                          blurRadius: 30,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          poster.businessName,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display.copyWith(fontSize: 26),
                        ),
                        if (poster.tagline.isNotEmpty)
                          Text(
                            poster.tagline,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          l10n.onlineStorePosterTitle,
                          style: AppTextStyles.display.copyWith(fontSize: 30),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SvgPicture.string(qr, width: 200, height: 200),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          l10n.onlineStorePosterSubtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          poster.url.replaceFirst(RegExp('^https?://'), ''),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.captionSmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.divider)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: SecondaryButton(
                        label: l10n.salesReceiptActionPrint,
                        icon: Icons.print_outlined,
                        onPressed: _busy
                            ? null
                            : () => _run(() => widget.service.print(poster)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: PrimaryButton(
                        label: l10n.salesReceiptActionShare,
                        icon: Icons.share_outlined,
                        isLoading: _busy,
                        onPressed: () =>
                            _run(() => widget.service.share(poster)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
