import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_line.dart';
import '../../domain/entities/sales_day.dart';
import '../cubit/sales_history_cubit.dart';
import '../view_data/payment_method_view_data.dart';

/// "Historial de ventas": past sales grouped by day, filtered by period and
/// payment method, or found by their number.
class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({
    required this.onBack,
    required this.onOpenSale,
    this.clock,
    super.key,
  });

  final VoidCallback onBack;
  final ValueChanged<Sale> onOpenSale;

  /// "Hoy" and "Ayer" headers; tests pin it.
  final DateTime Function()? clock;

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final TextEditingController _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SalesHistoryCubit>().load();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _pickRange(SalesHistoryState state) async {
    final SalesHistoryCubit cubit = context.read<SalesHistoryCubit>();
    final DateTime now = (widget.clock ?? DateTime.now)();
    final DateTimeRange<DateTime>? range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1, now.month, now.day),
      lastDate: now,
      initialDateRange: switch ((state.customFrom, state.customTo)) {
        (final DateTime from, final DateTime to) => DateTimeRange<DateTime>(
          start: from,
          end: to,
        ),
        _ => null,
      },
    );
    if (range != null) await cubit.rangeSelected(range.start, range.end);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final SalesHistoryCubit cubit = context.read<SalesHistoryCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<SalesHistoryCubit, SalesHistoryState>(
          builder: (BuildContext context, SalesHistoryState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.pageHorizontal,
                    AppSpacing.lg,
                  ),
                  child: PushedScreenHeader(
                    title: l10n.salesHistoryTitle,
                    subtitle: l10n.salesHistorySummary(
                      state.sales.length,
                      MoneyFormatter.format(state.total),
                    ),
                    onBack: widget.onBack,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pageHorizontal,
                  ),
                  child: AppSearchField(
                    hintText: l10n.salesHistorySearchHint,
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    onChanged: cubit.numberChanged,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (state.isSearchingNumber)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.pageHorizontal,
                    ),
                    child: Text(
                      l10n.salesHistorySearchingAllDates,
                      style: AppTextStyles.captionSmall,
                    ),
                  )
                else ...<Widget>[
                  FilterChipBar<SalesPeriod>(
                    selectedValue: state.period,
                    onSelected: (SalesPeriod period) =>
                        period == SalesPeriod.custom
                        ? _pickRange(state)
                        : cubit.periodSelected(period),
                    options: <FilterChipOption<SalesPeriod>>[
                      FilterChipOption<SalesPeriod>(
                        value: SalesPeriod.today,
                        label: l10n.salesHistoryPeriodToday,
                      ),
                      FilterChipOption<SalesPeriod>(
                        value: SalesPeriod.yesterday,
                        label: l10n.salesHistoryPeriodYesterday,
                      ),
                      FilterChipOption<SalesPeriod>(
                        value: SalesPeriod.last7Days,
                        label: l10n.salesHistoryPeriodLast7Days,
                      ),
                      FilterChipOption<SalesPeriod>(
                        value: SalesPeriod.custom,
                        label: switch ((state.customFrom, state.customTo)) {
                          (final DateTime from, final DateTime to)
                              when state.period == SalesPeriod.custom =>
                            l10n.salesHistoryRange(
                              DateFormatter.dayMonth(from),
                              DateFormatter.dayMonth(to),
                            ),
                          _ => l10n.salesHistoryPeriodCustom,
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilterChipBar<PaymentMethod?>(
                    selectedValue: state.paymentMethod,
                    onSelected: cubit.paymentMethodSelected,
                    options: <FilterChipOption<PaymentMethod?>>[
                      FilterChipOption<PaymentMethod?>(
                        value: null,
                        label: l10n.salesHistoryAllMethods,
                      ),
                      for (final PaymentMethod method in PaymentMethod.values)
                        FilterChipOption<PaymentMethod?>(
                          value: method,
                          label: method.localizedName(l10n),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: _HistoryBody(
                    state: state,
                    clock: widget.clock ?? DateTime.now,
                    onOpenSale: widget.onOpenSale,
                    onRetry: cubit.load,
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

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.state,
    required this.clock,
    required this.onOpenSale,
    required this.onRetry,
  });

  final SalesHistoryState state;
  final DateTime Function() clock;
  final ValueChanged<Sale> onOpenSale;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    if (state.status == SalesHistoryStatus.loading && state.sales.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == SalesHistoryStatus.failure) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.cloud_off_rounded,
          title: l10n.failureUnexpected,
          message: state.failure?.localizedMessage(l10n) ?? '',
          action: OutlinedButton(
            onPressed: onRetry,
            child: Text(l10n.commonRetry),
          ),
        ),
      );
    }
    if (state.sales.isEmpty) {
      final int? number = state.searchedNumber;
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.receipt_long_outlined,
          title: number == null
              ? l10n.salesHistoryEmptyTitle
              : l10n.salesHistoryNumberNotFoundTitle,
          message: number == null
              ? l10n.salesHistoryEmptyMessage
              : l10n.salesHistoryNumberNotFoundMessage(
                  '#${number.toString().padLeft(4, '0')}',
                ),
        ),
      );
    }

    final DateTime now = clock();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = DateTime(now.year, now.month, now.day - 1);
    String dayLabel(DateTime day) => day == today
        ? l10n.salesHistoryPeriodToday
        : day == yesterday
        ? l10n.salesHistoryPeriodYesterday
        : DateFormatter.longDate(day);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        for (final SalesDay day in state.days) ...<Widget>[
          _DayHeader(label: dayLabel(day.date), day: day),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < day.sales.length; i++) ...<Widget>[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: AppSpacing.lg,
                      endIndent: AppSpacing.lg,
                    ),
                  _SaleRow(
                    sale: day.sales[i],
                    onTap: () => onOpenSale(day.sales[i]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.label, required this.day});

  final String label;
  final SalesDay day;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: AppTextStyles.bodyStrong)),
          Text(
            context.l10n.salesHistoryDayTotal(
              day.sales.length,
              MoneyFormatter.format(day.total),
            ),
            style: AppTextStyles.captionSmallStrong.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  const _SaleRow({required this.sale, required this.onTap});

  final Sale sale;
  final VoidCallback onTap;

  /// `Polera básica (Negra · M) y 1 producto más`
  static String summaryOf(AppLocalizations l10n, Sale sale) {
    final SaleLine first = sale.lines.first;
    final String name = first.variantLabel == null
        ? first.productName
        : l10n.salesVariantProductName(first.productName, first.variantLabel!);
    final int others = sale.lines.length - 1;
    return others == 0 ? name : l10n.salesHistoryMoreProducts(others, name);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final PaymentMethod method = sale.paymentMethod;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Row(
          children: <Widget>[
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: method.tintSurface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(method.icon, size: 20, color: method.tintColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${sale.formattedNumber} · ${DateFormatter.time(sale.createdAt)}',
                    style: AppTextStyles.bodyStrong,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summaryOf(l10n, sale),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.captionSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  MoneyFormatter.format(sale.total),
                  style: AppTextStyles.bodyStrong.copyWith(
                    decoration: sale.isCancelled
                        ? TextDecoration.lineThrough
                        : null,
                    color: sale.isCancelled ? AppColors.textSecondary : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  switch (sale.status) {
                    SaleStatus.cancelled => l10n.saleStatusCancelled,
                    SaleStatus.partiallyReturned =>
                      l10n.saleStatusPartiallyReturned,
                    SaleStatus.returned => l10n.saleStatusReturned,
                    SaleStatus.completed => method.localizedName(l10n),
                  },
                  style: switch (sale.status) {
                    SaleStatus.completed => AppTextStyles.captionSmall,
                    SaleStatus.cancelled =>
                      AppTextStyles.captionSmallStrong.copyWith(
                        color: AppColors.errorText,
                      ),
                    _ => AppTextStyles.captionSmallStrong.copyWith(
                      color: AppColors.infoText,
                    ),
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
