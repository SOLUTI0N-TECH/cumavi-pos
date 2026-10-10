import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/order.dart';
import '../cubit/import_order_cubit.dart';

/// "Importar pedido": until the API delivers web orders to the POS, the
/// web's WhatsApp message carries a link with the order. Opening it on the
/// phone, or pasting the message here, puts the order in the inbox.
class ImportOrderScreen extends StatefulWidget {
  const ImportOrderScreen({
    required this.onClose,
    required this.onImported,
    this.initialLink,
    super.key,
  });

  final VoidCallback onClose;
  final ValueChanged<Order> onImported;

  /// The link the phone opened the app with; imported right away.
  final String? initialLink;

  @override
  State<ImportOrderScreen> createState() => _ImportOrderScreenState();
}

class _ImportOrderScreenState extends State<ImportOrderScreen> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initialLink ?? '',
  );

  @override
  void initState() {
    super.initState();
    final String? link = widget.initialLink;
    if (link != null && link.isNotEmpty) {
      context.read<ImportOrderCubit>().import(link);
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String? text = data?.text;
    if (text == null || !mounted) return;
    setState(() => _text.text = text);
  }

  void _onState(BuildContext context, ImportOrderState state) {
    final AppLocalizations l10n = context.l10n;
    switch (state.status) {
      case ImportOrderStatus.imported:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.orderImportedToast(state.order!.formattedNumber),
            ),
          ),
        );
        widget.onImported(state.order!);
      case ImportOrderStatus.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
        );
      case ImportOrderStatus.idle || ImportOrderStatus.importing:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<ImportOrderCubit, ImportOrderState>(
          listener: _onState,
          builder: (BuildContext context, ImportOrderState state) {
            final bool importing = state.status == ImportOrderStatus.importing;
            return Column(
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
                    title: l10n.orderImportTitle,
                    subtitle: l10n.orderImportSubtitle,
                    onBack: widget.onClose,
                    isCloseAction: true,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.pageHorizontal),
                    children: <Widget>[
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              l10n.orderImportFieldLabel,
                              style: AppTextStyles.bodyLargeStrong,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _text,
                              minLines: 3,
                              maxLines: 6,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: l10n.orderImportFieldHint,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: importing ? null : _paste,
                                icon: const Icon(
                                  Icons.content_paste_rounded,
                                  size: 18,
                                ),
                                label: Text(l10n.orderImportPaste),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.infoSurface,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              l10n.orderImportHowTitle,
                              style: AppTextStyles.bodySmallStrong.copyWith(
                                color: AppColors.infoText,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.orderImportHowMessage,
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.infoText,
                              ),
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
                    child: PrimaryButton(
                      label: l10n.orderImportAction,
                      icon: Icons.download_rounded,
                      isLoading: importing,
                      onPressed: _text.text.trim().isEmpty
                          ? null
                          : () => context.read<ImportOrderCubit>().import(
                              _text.text,
                            ),
                    ),
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
