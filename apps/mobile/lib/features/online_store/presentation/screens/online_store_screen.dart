import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../domain/entities/store_settings.dart';
import '../../domain/usecases/store_settings_usecases.dart';
import '../cubit/online_store_cubit.dart';
import '../widgets/opening_hours_sheet.dart';

/// "Tienda en línea": the store's link and QR poster, what the web shows
/// and how it takes orders.
class OnlineStoreScreen extends StatefulWidget {
  const OnlineStoreScreen({
    required this.onBack,
    required this.onOpenPoster,
    this.clock,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenPoster;

  /// "Abierta ahora"; tests pin it.
  final DateTime Function()? clock;

  @override
  State<OnlineStoreScreen> createState() => _OnlineStoreScreenState();
}

class _OnlineStoreScreenState extends State<OnlineStoreScreen> {
  final TextEditingController _tagline = TextEditingController();
  final TextEditingController _whatsapp = TextEditingController();
  final TextEditingController _deliveryNote = TextEditingController();
  bool _filled = false;

  OnlineStoreCubit get _cubit => context.read<OnlineStoreCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  @override
  void dispose() {
    _tagline.dispose();
    _whatsapp.dispose();
    _deliveryNote.dispose();
    super.dispose();
  }

  void _fill(StoreSettings settings) {
    _tagline.text = settings.tagline;
    _whatsapp.text = settings.whatsapp;
    _deliveryNote.text = settings.deliveryNote;
    _filled = true;
  }

  void _toast(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _copyLink() async {
    final String? url = _cubit.storeUrl;
    if (url == null) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) _toast(context.l10n.onlineStoreLinkCopied);
  }

  Future<void> _shareLink(String businessName) async {
    final String? url = _cubit.storeUrl;
    if (url == null) return;
    final Failure? failure = await _cubit.shareStore(
      context.l10n.onlineStoreShareMessage(businessName, url),
    );
    if (failure != null && mounted) {
      _toast(failure.localizedMessage(context.l10n));
    }
  }

  Future<void> _openLink() async {
    final Failure? failure = await _cubit.openStore();
    if (failure != null && mounted) {
      _toast(failure.localizedMessage(context.l10n));
    }
  }

  Future<void> _editDay(StoreSettings settings, int weekday) async {
    final List<OpeningHoursRange>? ranges = await OpeningHoursSheet.show(
      context,
      weekday: weekday,
      ranges: settings.rangesFor(weekday),
    );
    if (ranges != null) _cubit.dayHoursChanged(weekday, ranges);
  }

  Future<void> _save() async {
    final AppLocalizations l10n = context.l10n;
    final Failure? failure = await _cubit.save();
    if (!mounted) return;
    _toast(failure?.localizedMessage(l10n) ?? l10n.onlineStoreSaved);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      // As the bottom bar, snack bars float above the save button.
      bottomNavigationBar: BlocBuilder<OnlineStoreCubit, OnlineStoreState>(
        builder: (BuildContext context, OnlineStoreState state) {
          if (state.draft == null) return const SizedBox.shrink();
          return DecoratedBox(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.md,
                  AppSpacing.pageHorizontal,
                  AppSpacing.lg,
                ),
                child: PrimaryButton(
                  label: l10n.commonSave,
                  icon: Icons.check_rounded,
                  isLoading: state.status == OnlineStoreStatus.saving,
                  onPressed: state.hasChanges ? _save : null,
                ),
              ),
            ),
          );
        },
      ),
      body: SafeArea(
        child: BlocConsumer<OnlineStoreCubit, OnlineStoreState>(
          listenWhen: (OnlineStoreState previous, OnlineStoreState current) =>
              !_filled && current.draft != null,
          listener: (BuildContext context, OnlineStoreState state) =>
              _fill(state.draft!),
          builder: (BuildContext context, OnlineStoreState state) {
            final StoreSettings? settings = state.draft;
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
                    title: l10n.onlineStoreTitle,
                    subtitle: l10n.onlineStoreSubtitle,
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    OnlineStoreStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    OnlineStoreStatus.failure => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: EmptyStateView(
                        icon: Icons.storefront_outlined,
                        title: l10n.failureUnexpected,
                        message: state.failure?.localizedMessage(l10n) ?? '',
                        action: OutlinedButton(
                          onPressed: _cubit.load,
                          child: Text(l10n.commonRetry),
                        ),
                      ),
                    ),
                    _ => _form(context, state, settings!),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _form(
    BuildContext context,
    OnlineStoreState state,
    StoreSettings settings,
  ) {
    final AppLocalizations l10n = context.l10n;
    final String businessName =
        context.read<SessionCubit>().state.business?.name ??
        l10n.commonDefaultBusinessName;
    final bool openNow = settings.isOpenAt((widget.clock ?? DateTime.now)());

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.lg,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        _Card(
          children: <Widget>[
            _SwitchRow(
              title: l10n.onlineStoreEnabled,
              caption: settings.isEnabled
                  ? l10n.onlineStoreEnabledOn
                  : l10n.onlineStoreEnabledOff,
              value: settings.isEnabled,
              onChanged: _cubit.enabledChanged,
            ),
            const Divider(height: AppSpacing.xl),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusPill(
                label: openNow
                    ? l10n.onlineStoreOpenNow
                    : l10n.onlineStoreClosedNow,
                dotColor: openNow ? AppColors.success : AppColors.textSecondary,
                background: openNow
                    ? AppColors.successSurface
                    : AppColors.surfaceMuted,
                foreground: openNow
                    ? AppColors.successText
                    : AppColors.textSecondary,
                height: 26,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _cubit.storeUrl?.replaceFirst('https://', '') ?? '',
              style: AppTextStyles.bodySmallStrong,
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: <Widget>[
                _LinkAction(
                  icon: Icons.copy_rounded,
                  label: l10n.onlineStoreCopyLink,
                  onPressed: _copyLink,
                ),
                _LinkAction(
                  icon: Icons.share_outlined,
                  label: l10n.onlineStoreShareLink,
                  onPressed: () => _shareLink(businessName),
                ),
                _LinkAction(
                  icon: Icons.open_in_new_rounded,
                  label: l10n.onlineStoreOpenLink,
                  onPressed: _openLink,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: widget.onOpenPoster,
              icon: const Icon(Icons.qr_code_2_rounded),
              label: Text(l10n.onlineStorePosterAction),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.onlineStorePublicTitle,
          children: <Widget>[
            LabeledField(
              label: l10n.onlineStoreTaglineLabel,
              optionalText: l10n.catalogProductFormOptional,
              child: TextField(
                controller: _tagline,
                onChanged: _cubit.taglineChanged,
                maxLength: StoreSettingsRules.maxTaglineLength,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.onlineStoreTaglineHint,
                  counterText: '',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            LabeledField(
              label: l10n.onlineStoreWhatsAppLabel,
              child: TextField(
                controller: _whatsapp,
                onChanged: _cubit.whatsappChanged,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixText: '+${BolivianPhoneNumber.countryCode} ',
                  hintText: '76543210',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.onlineStoreFulfillmentTitle,
          children: <Widget>[
            _SwitchRow(
              title: l10n.orderFulfillmentPickup,
              caption: l10n.onlineStorePickupCaption,
              value: settings.pickupEnabled,
              onChanged: _cubit.pickupChanged,
            ),
            const Divider(height: AppSpacing.xl),
            _SwitchRow(
              title: l10n.orderFulfillmentDelivery,
              caption: l10n.onlineStoreDeliveryCaption,
              value: settings.deliveryEnabled,
              onChanged: _cubit.deliveryChanged,
            ),
            if (settings.deliveryEnabled) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              LabeledField(
                label: l10n.onlineStoreDeliveryNoteLabel,
                optionalText: l10n.catalogProductFormOptional,
                child: TextField(
                  controller: _deliveryNote,
                  onChanged: _cubit.deliveryNoteChanged,
                  maxLength: StoreSettingsRules.maxDeliveryNoteLength,
                  minLines: 2,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: l10n.onlineStoreDeliveryNoteHint,
                    counterText: '',
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.onlineStoreHoursTitle,
          children: <Widget>[
            for (int day = 1; day <= 7; day++)
              InkWell(
                onTap: () => _editDay(settings, day),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 96,
                        child: Text(
                          OpeningHoursTexts.weekday(day),
                          style: AppTextStyles.bodySmallStrong,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          OpeningHoursTexts.ranges(settings.rangesFor(day)) ??
                              l10n.onlineStoreClosedDay,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: settings.rangesFor(day).isEmpty
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            const Divider(height: AppSpacing.xl),
            _SwitchRow(
              title: l10n.onlineStoreOutsideHours,
              caption: l10n.onlineStoreOutsideHoursCaption,
              value: settings.acceptOutsideHours,
              onChanged: _cubit.acceptOutsideHoursChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.onlineStoreCatalogTitle,
          children: <Widget>[
            Text(
              l10n.onlineStoreProductsOnline(
                state.onlineProducts,
                state.totalProducts,
              ),
              style: AppTextStyles.bodySmallStrong,
            ),
            Text(
              l10n.onlineStoreProductsOnlineCaption,
              style: AppTextStyles.captionSmall,
            ),
            const Divider(height: AppSpacing.xl),
            _SwitchRow(
              title: l10n.onlineStoreShowOutOfStock,
              caption: l10n.onlineStoreShowOutOfStockCaption,
              value: settings.showOutOfStock,
              onChanged: _cubit.showOutOfStockChanged,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.onlineStorePaymentsTitle,
          children: <Widget>[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                for (final PaymentMethod method in PaymentMethod.values)
                  FilterChip(
                    label: Text(method.localizedName(l10n)),
                    selected: settings.onlinePaymentMethods.contains(method),
                    onSelected: (_) => _cubit.paymentMethodToggled(method),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.children, this.title});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Text(title!, style: AppTextStyles.bodyLargeStrong),
            const SizedBox(height: AppSpacing.md),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.caption,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String caption;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: AppTextStyles.bodySmallStrong),
              Text(caption, style: AppTextStyles.captionSmall),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _LinkAction extends StatelessWidget {
  const _LinkAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 20),
            const SizedBox(height: AppSpacing.xs),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
