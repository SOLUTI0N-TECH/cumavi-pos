import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../core/widgets/filter_chip_bar.dart';
import '../../../../core/widgets/screen_header.dart';
import '../cubit/stock_movements_cubit.dart';
import '../widgets/stock_movement_tile.dart';

/// "Movimientos de stock": every entry and exit of the store, or of one
/// product, filtered by kind and period.
class StockMovementsScreen extends StatefulWidget {
  const StockMovementsScreen({
    required this.onBack,
    this.productName,
    super.key,
  });

  final VoidCallback onBack;

  /// Set when showing a single product's history.
  final String? productName;

  @override
  State<StockMovementsScreen> createState() => _StockMovementsScreenState();
}

class _StockMovementsScreenState extends State<StockMovementsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StockMovementsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final StockMovementsCubit cubit = context.read<StockMovementsCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<StockMovementsCubit, StockMovementsState>(
          builder: (BuildContext context, StockMovementsState state) {
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
                    title: l10n.inventoryMovementsTitle,
                    subtitle: widget.productName,
                    onBack: widget.onBack,
                  ),
                ),
                FilterChipBar<MovementFilter>(
                  selectedValue: state.filter,
                  onSelected: cubit.filterSelected,
                  options: <FilterChipOption<MovementFilter>>[
                    for (final MovementFilter filter in MovementFilter.values)
                      FilterChipOption<MovementFilter>(
                        value: filter,
                        label: switch (filter) {
                          MovementFilter.all => l10n.inventoryFilterAll,
                          MovementFilter.purchases =>
                            l10n.inventoryFilterPurchases,
                          MovementFilter.adjustments =>
                            l10n.inventoryFilterAdjustments,
                          MovementFilter.sales => l10n.inventoryFilterSales,
                          MovementFilter.initial => l10n.inventoryTypeInitial,
                        },
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                FilterChipBar<MovementPeriod>(
                  selectedValue: state.period,
                  onSelected: cubit.periodSelected,
                  options: <FilterChipOption<MovementPeriod>>[
                    FilterChipOption<MovementPeriod>(
                      value: MovementPeriod.last7Days,
                      label: l10n.salesHistoryPeriodLast7Days,
                    ),
                    FilterChipOption<MovementPeriod>(
                      value: MovementPeriod.last30Days,
                      label: l10n.inventoryPeriodLast30Days,
                    ),
                    FilterChipOption<MovementPeriod>(
                      value: MovementPeriod.all,
                      label: l10n.inventoryPeriodAll,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(child: _body(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _body(BuildContext context, StockMovementsState state) {
    final AppLocalizations l10n = context.l10n;
    if (state.status == StockMovementsStatus.loading &&
        state.movements.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.movements.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: EmptyStateView(
          icon: Icons.swap_vert_rounded,
          title: l10n.inventoryNoMovements,
          message: l10n.inventoryNoMovementsMessage,
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        0,
        AppSpacing.pageHorizontal,
        AppSpacing.xxl,
      ),
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: <Widget>[
                for (int i = 0; i < state.movements.length; i++) ...<Widget>[
                  if (i > 0) const Divider(height: 1),
                  StockMovementTile(
                    movement: state.movements[i],
                    showProduct: widget.productName == null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
