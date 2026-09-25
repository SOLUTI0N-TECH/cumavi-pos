import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../widgets/demo_code_banner.dart';
import '../widgets/verification_code_field.dart';

/// Registration step 2: confirm the SMS code.
class PhoneVerificationScreen extends StatelessWidget {
  const PhoneVerificationScreen({
    required this.onBack,
    required this.onVerified,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onVerified;

  /// Asks for a new code and confirms it with [message].
  Future<void> _resendCode(BuildContext context, String message) async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final RegistrationCubit cubit = context.read<RegistrationCubit>();
    await cubit.resendCode();
    if (cubit.state.status == RegistrationStatus.codeSent) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<RegistrationCubit, RegistrationState>(
          listener: (BuildContext context, RegistrationState state) {
            if (state.status == RegistrationStatus.accountReady) {
              onVerified();
            }
            if (state.status == RegistrationStatus.failure &&
                state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure!.localizedMessage(context.l10n)),
                ),
              );
            }
          },
          builder: (BuildContext context, RegistrationState state) {
            final RegistrationCubit cubit = context.read<RegistrationCubit>();
            final AppLocalizations l10n = context.l10n;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              children: <Widget>[
                StepProgressHeader(
                  currentStep: 2,
                  totalSteps: 4,
                  stepLabel: l10n.authPhoneVerificationStepLabel,
                  onBack: onBack,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.authPhoneVerificationTitle,
                  style: AppTextStyles.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    text: l10n.authPhoneVerificationSentTo,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    children: <InlineSpan>[
                      TextSpan(
                        text: '+591 ${state.phoneNumber}',
                        style: AppTextStyles.bodyStrong,
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onBack,
                    child: Text(l10n.authPhoneVerificationChangeNumber),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                VerificationCodeField(
                  value: state.code,
                  onChanged: cubit.codeChanged,
                ),
                if (state.demoCode case final String demoCode) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  DemoCodeBanner(code: demoCode, onUse: cubit.codeChanged),
                ],
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: <Widget>[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.authPhoneVerificationResendHint,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () => _resendCode(
                              context,
                              l10n.authPhoneVerificationCodeResent,
                            ),
                      child: Text(l10n.authPhoneVerificationResend),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.authPhoneVerificationSubmit,
                  isLoading: state.isSubmitting,
                  onPressed: state.canVerifyCode ? cubit.verifyCode : null,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: state.isSubmitting
                      ? null
                      : () => _resendCode(
                          context,
                          l10n.authPhoneVerificationCodeSentViaWhatsApp,
                        ),
                  icon: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: AppColors.successText,
                  ),
                  label: Text(l10n.authPhoneVerificationViaWhatsApp),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg + 2),
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
