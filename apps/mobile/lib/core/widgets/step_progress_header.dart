import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'screen_header.dart';

/// Registration header: back button, "Paso X de Y · label" and a progress
/// bar with one segment per step.
class StepProgressHeader extends StatelessWidget {
  const StepProgressHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabel,
    required this.onBack,
    super.key,
  });

  final int currentStep;
  final int totalSteps;
  final String stepLabel;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Row(
      children: <Widget>[
        CircleActionButton(
          icon: Icons.arrow_back_rounded,
          tooltip: l10n.commonBack,
          background: AppColors.background,
          onPressed: onBack,
        ),
        const SizedBox(width: AppSpacing.md + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text.rich(
                TextSpan(
                  text: l10n.commonStepProgress(currentStep, totalSteps),
                  style: AppTextStyles.label,
                  children: <InlineSpan>[
                    TextSpan(
                      text: l10n.commonStepProgressLabel(stepLabel),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List<Widget>.generate(totalSteps, (int index) {
                  final bool isDone = index < currentStep;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == totalSteps - 1 ? 0 : 6,
                      ),
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDone ? AppColors.ink : AppColors.divider,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
