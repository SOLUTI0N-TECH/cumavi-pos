import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/orders_badge_cubit.dart';

/// Inicio's entry to the orders inbox, with the new orders as a badge.
class OnlineOrdersCard extends StatelessWidget {
  const OnlineOrdersCard({required this.onOpen, super.key});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final BorderRadius radius = BorderRadius.circular(AppRadius.xl);

    return BlocBuilder<OrdersBadgeCubit, OrdersBadgeState>(
      builder: (BuildContext context, OrdersBadgeState state) {
        final bool hasNew = state.newCount > 0;
        final String subtitle = state.hasOpenOrders
            ? <String>[
                if (hasNew) l10n.ordersCardNew(state.newCount),
                if (state.inProgressCount > 0)
                  l10n.ordersCardInProgress(state.inProgressCount),
              ].join(' · ')
            : l10n.ordersCardEmpty;

        return Material(
          color: AppColors.surface,
          borderRadius: radius,
          child: InkWell(
            onTap: onOpen,
            borderRadius: radius,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: <Widget>[
                  Badge(
                    isLabelVisible: hasNew,
                    label: Text('${state.newCount}'),
                    backgroundColor: AppColors.error,
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: hasNew
                            ? AppColors.infoSurface
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: hasNew ? AppColors.infoText : AppColors.inkSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(l10n.ordersTitle, style: AppTextStyles.bodyStrong),
                        Text(
                          subtitle,
                          style: AppTextStyles.captionSmall.copyWith(
                            color: hasNew
                                ? AppColors.infoText
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
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
        );
      },
    );
  }
}
