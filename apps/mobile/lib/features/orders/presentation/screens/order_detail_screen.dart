import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/key_value_row.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../../auth/presentation/cubit/session_cubit.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/order_rules.dart';
import '../../domain/usecases/order_usecases.dart';
import '../cubit/order_detail_cubit.dart';
import '../view_data/order_view_data.dart';
import '../widgets/order_action_sheets.dart';

/// One online order: the customer, what they asked for, its history, and
/// the next step (confirm, mark ready, charge) or cancelling it.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    required this.onBack,
    required this.onCheckout,
    required this.onOpenSale,
    this.clock,
    super.key,
  });

  final VoidCallback onBack;

  /// Opens the checkout with the order's cart.
  final ValueChanged<OrderCheckout> onCheckout;

  /// The sale that charged the order.
  final ValueChanged<String> onOpenSale;
  final DateTime Function()? clock;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  OrderDetailCubit get _cubit => context.read<OrderDetailCubit>();

  @override
  void initState() {
    super.initState();
    _cubit.load();
  }

  String get _storeName =>
      context.read<SessionCubit>().state.business?.name ??
      context.l10n.commonDefaultBusinessName;

  void _toast(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  /// After a step, offers to tell the customer.
  void _done(Failure? failure, String message) {
    if (!mounted) return;
    final AppLocalizations l10n = context.l10n;
    if (failure != null) {
      _toast(failure.localizedMessage(l10n));
      return;
    }
    _toast(
      message,
      action: SnackBarAction(
        label: l10n.orderNotifyAction,
        onPressed: _messageCustomer,
      ),
    );
  }

  Future<void> _messageCustomer() async {
    final Order? order = _cubit.state.order;
    if (order == null) return;
    final Failure? failure = await _cubit.messageCustomer(
      OrderTexts.whatsAppMessage(context.l10n, order, storeName: _storeName),
    );
    if (failure != null && mounted) {
      _toast(failure.localizedMessage(context.l10n));
    }
  }

  Future<void> _callCustomer() async {
    final Failure? failure = await _cubit.callCustomer();
    if (failure != null && mounted) {
      _toast(failure.localizedMessage(context.l10n));
    }
  }

  Future<void> _confirm(Order order) async {
    final AppLocalizations l10n = context.l10n;
    double? fee;
    if (order.isDelivery) {
      fee = await DeliveryFeeSheet.show(context, initialFee: order.deliveryFee);
      if (fee == null) return;
    }
    _done(await _cubit.confirm(deliveryFee: fee), l10n.orderConfirmedToast);
  }

  Future<void> _markReady() async {
    final String message = context.l10n.orderReadyToast;
    _done(await _cubit.markReady(), message);
  }

  Future<void> _cancel(Order order) async {
    final AppLocalizations l10n = context.l10n;
    final String? reason = await CancelOrderDialog.show(context, order: order);
    if (reason == null) return;
    _done(await _cubit.cancel(reason), l10n.orderCancelledToast);
  }

  Future<void> _edit(Order order) async {
    final AppLocalizations l10n = context.l10n;
    final edit = await EditOrderSheet.show(context, order: order);
    if (edit == null) return;
    final Failure? failure = await _cubit.edit(edit);
    if (!mounted) return;
    _toast(failure?.localizedMessage(l10n) ?? l10n.orderEditedToast);
  }

  Future<void> _checkout() async {
    final Result<OrderCheckout> result = await _cubit.prepareCheckout();
    if (!mounted) return;
    switch (result) {
      case Success<OrderCheckout>(:final OrderCheckout value):
        widget.onCheckout(value);
      case Failed<OrderCheckout>(:final failure):
        _toast(failure.localizedMessage(context.l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      // As the bottom bar, snack bars float above the actions.
      bottomNavigationBar: BlocBuilder<OrderDetailCubit, OrderDetailState>(
        builder: (BuildContext context, OrderDetailState state) {
          final Order? order = state.order;
          if (order == null) return const SizedBox.shrink();
          return SafeArea(
            top: false,
            child: _Actions(
              order: order,
              busy: state.busy,
              onConfirm: () => _confirm(order),
              onReady: _markReady,
              onCheckout: _checkout,
              onEdit: () => _edit(order),
              onCancel: () => _cancel(order),
              onOpenSale: order.saleId == null
                  ? null
                  : () => widget.onOpenSale(order.saleId!),
            ),
          );
        },
      ),
      body: SafeArea(
        child: BlocBuilder<OrderDetailCubit, OrderDetailState>(
          builder: (BuildContext context, OrderDetailState state) {
            final Order? order = state.order;
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
                    title: order == null
                        ? l10n.orderDetailTitleLoading
                        : l10n.orderDetailTitle(order.formattedNumber),
                    subtitle: order == null
                        ? null
                        : OrderTexts.placedAt(
                            l10n,
                            order.createdAt,
                            (widget.clock ?? DateTime.now)(),
                          ),
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(
                  child: switch (state.status) {
                    OrderDetailStatus.loading when order == null =>
                      const Center(child: CircularProgressIndicator()),
                    OrderDetailStatus.failure when order == null => Padding(
                      padding: const EdgeInsets.all(AppSpacing.xxl),
                      child: EmptyStateView(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.orderDetailLoadError,
                        message:
                            state.failure?.localizedMessage(l10n) ??
                            l10n.failureUnexpected,
                        action: OutlinedButton(
                          onPressed: _cubit.load,
                          child: Text(l10n.commonRetry),
                        ),
                      ),
                    ),
                    _ => _OrderDetails(
                      order: order!,
                      onMessage: _messageCustomer,
                      onCall: _callCustomer,
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  const _OrderDetails({
    required this.order,
    required this.onMessage,
    required this.onCall,
  });

  final Order order;
  final VoidCallback onMessage;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final OrderCustomer customer = order.customer;

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
            Row(
              children: <Widget>[
                StatusPill(
                  label: order.status.label(l10n),
                  background: order.status.background,
                  foreground: order.status.foreground,
                  height: 28,
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  order.fulfillment.icon,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    order.fulfillment.label(l10n),
                    style: AppTextStyles.bodySmallStrong,
                  ),
                ),
              ],
            ),
            if (order.source == OrderSource.whatsappImport) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(l10n.orderImportedNote, style: AppTextStyles.captionSmall),
            ],
            if (order.cancelReason case final String reason) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.orderCancelReason(reason),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.errorText,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.orderCustomerTitle,
          children: <Widget>[
            Text(customer.name, style: AppTextStyles.bodyStrong),
            Text(
              '+${BolivianPhoneNumber.countryCode} ${customer.phone}',
              style: AppTextStyles.bodySmall,
            ),
            if (order.isDelivery && customer.address.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              _IconLine(icon: Icons.place_outlined, text: customer.address),
            ],
            if (customer.note.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              _IconLine(
                icon: Icons.sticky_note_2_outlined,
                text: customer.note,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.call_outlined, size: 18),
                    label: Text(l10n.orderCall),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.chat_outlined, size: 18),
                    label: Text(l10n.orderWhatsApp),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.saleDetailProducts(order.units),
          children: <Widget>[
            for (int i = 0; i < order.lines.length; i++) ...<Widget>[
              if (i > 0) const Divider(height: AppSpacing.xl),
              _LineRow(line: order.lines[i]),
            ],
            const Divider(height: AppSpacing.xxl),
            KeyValueRow(
              label: l10n.saleDetailSubtotal,
              value: MoneyFormatter.format(order.subtotal),
            ),
            if (order.isDelivery) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              KeyValueRow(
                label: l10n.receiptDeliveryLabel,
                value: order.deliveryFee > 0
                    ? MoneyFormatter.format(order.deliveryFee)
                    : l10n.orderDeliveryFeePending,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            KeyValueRow(
              label: l10n.saleDetailTotal,
              value: MoneyFormatter.format(order.total),
              emphasize: true,
            ),
            const SizedBox(height: AppSpacing.sm),
            KeyValueRow(
              label: l10n.orderPaymentMethod,
              value: order.paymentMethod.localizedName(l10n),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Card(
          title: l10n.orderHistoryTitle,
          children: <Widget>[
            for (final OrderStatusChange change in order.history.reversed)
              _HistoryRow(change: change),
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

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.bodySmall)),
      ],
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final OrderLine line;

  @override
  Widget build(BuildContext context) {
    final String? variant = line.variantLabel;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(line.productName, style: AppTextStyles.bodyStrong),
              if (variant != null)
                Text(variant, style: AppTextStyles.captionSmall),
              Text(
                context.l10n.saleDetailUnitPrice(
                  line.quantity,
                  MoneyFormatter.format(line.unitPrice),
                ),
                style: AppTextStyles.captionSmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          MoneyFormatter.format(line.lineTotal),
          style: AppTextStyles.bodyStrong,
        ),
      ],
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.change});

  final OrderStatusChange change;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool isEdit = change.isEdit;
    final String title = switch (change.to) {
      _ when isEdit => l10n.orderHistoryEdited,
      OrderStatus.newOrder => l10n.orderHistoryPlaced,
      final OrderStatus status => status.label(l10n),
    };
    final String when = DateFormatter.shortDateTime(change.at);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(top: 6),
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: isEdit ? AppColors.textSecondary : change.to.foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: AppTextStyles.bodySmallStrong),
                Text(
                  change.byName == null
                      ? when
                      : l10n.inventoryMovementWhen(when, change.byName!),
                  style: AppTextStyles.captionSmall,
                ),
                if (!isEdit && change.note != null)
                  Text(change.note!, style: AppTextStyles.captionSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The buttons the order's state allows.
class _Actions extends StatelessWidget {
  const _Actions({
    required this.order,
    required this.busy,
    required this.onConfirm,
    required this.onReady,
    required this.onCheckout,
    required this.onEdit,
    required this.onCancel,
    required this.onOpenSale,
  });

  final Order order;
  final bool busy;
  final VoidCallback onConfirm;
  final VoidCallback onReady;
  final VoidCallback onCheckout;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback? onOpenSale;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool canEdit = OrderRules.canEdit(order);
    final bool canCancel = OrderRules.canCancel(order);
    final (String, IconData, VoidCallback)? primary = switch (order.status) {
      OrderStatus.newOrder => (
        l10n.orderActionConfirm,
        Icons.check_rounded,
        onConfirm,
      ),
      OrderStatus.confirmed => (
        l10n.orderActionReady,
        Icons.inventory_2_outlined,
        onReady,
      ),
      OrderStatus.ready => (
        l10n.orderActionCheckout,
        Icons.point_of_sale_rounded,
        onCheckout,
      ),
      OrderStatus.delivered when onOpenSale != null => (
        l10n.orderActionViewSale,
        Icons.receipt_long_rounded,
        onOpenSale!,
      ),
      _ => null,
    };
    if (primary == null && !canCancel) return const SizedBox.shrink();

    return DecoratedBox(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (canEdit || canCancel) ...<Widget>[
              Row(
                children: <Widget>[
                  if (canEdit)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(l10n.orderActionEdit),
                      ),
                    ),
                  if (canEdit && canCancel)
                    const SizedBox(width: AppSpacing.sm),
                  if (canCancel)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: busy ? null : onCancel,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorText,
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: Text(l10n.orderActionCancel),
                      ),
                    ),
                ],
              ),
              if (primary != null) const SizedBox(height: AppSpacing.sm),
            ],
            if (primary != null)
              PrimaryButton(
                label: primary.$1,
                icon: primary.$2,
                isLoading: busy,
                onPressed: primary.$3,
              ),
          ],
        ),
      ),
    );
  }
}
