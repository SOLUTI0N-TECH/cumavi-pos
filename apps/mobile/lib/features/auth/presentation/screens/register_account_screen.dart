import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/segmented_selector.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../widgets/google_auth_button.dart';
import '../widgets/phone_number_field.dart';

/// Registration step 1: create the account with Google, phone or email.
class RegisterAccountScreen extends StatefulWidget {
  const RegisterAccountScreen({
    required this.onBack,
    required this.onCodeSent,
    required this.onAccountReady,
    required this.onSignIn,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onCodeSent;

  /// Google and email accounts skip the SMS step.
  final VoidCallback onAccountReady;
  final VoidCallback onSignIn;

  @override
  State<RegisterAccountScreen> createState() => _RegisterAccountScreenState();
}

class _RegisterAccountScreenState extends State<RegisterAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<RegistrationCubit, RegistrationState>(
          listener: (BuildContext context, RegistrationState state) {
            switch (state.status) {
              case RegistrationStatus.codeSent:
                widget.onCodeSent();
              case RegistrationStatus.accountReady:
                widget.onAccountReady();
              case RegistrationStatus.failure:
                if (state.failure != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.failure!.localizedMessage(context.l10n),
                      ),
                    ),
                  );
                }
              case RegistrationStatus.editing:
              case RegistrationStatus.submitting:
              case RegistrationStatus.businessSaved:
              case RegistrationStatus.completed:
                break;
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
                  currentStep: 1,
                  totalSteps: 4,
                  stepLabel: l10n.authRegisterStepLabel,
                  onBack: widget.onBack,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  l10n.authRegisterTitle,
                  style: AppTextStyles.display.copyWith(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.authRegisterSubtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GoogleAuthButton(
                  label: l10n.authRegisterWithGoogle,
                  onPressed: state.isSubmitting ? null : cubit.signUpWithGoogle,
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthDivider(label: l10n.authRegisterDivider),
                const SizedBox(height: AppSpacing.lg),
                SegmentedSelector<RegistrationMethod>(
                  options: <SegmentOption<RegistrationMethod>>[
                    SegmentOption<RegistrationMethod>(
                      value: RegistrationMethod.email,
                      label: l10n.authMethodEmail,
                      icon: Icons.mail_outline_rounded,
                    ),
                    SegmentOption<RegistrationMethod>(
                      value: RegistrationMethod.phone,
                      label: l10n.authMethodPhone,
                      icon: Icons.smartphone_rounded,
                    ),
                  ],
                  selectedValue: state.method,
                  onSelected: cubit.methodChanged,
                ),
                const SizedBox(height: AppSpacing.xl),
                LabeledField(
                  label: l10n.authRegisterFullNameLabel,
                  child: TextField(
                    controller: _nameController,
                    onChanged: cubit.fullNameChanged,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: l10n.authRegisterFullNameHint,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (state.method == RegistrationMethod.phone)
                  LabeledField(
                    label: l10n.authPhoneNumberLabel,
                    helperText: l10n.authRegisterPhoneHelper,
                    child: PhoneNumberField(
                      controller: _phoneController,
                      focused: true,
                      onChanged: cubit.phoneNumberChanged,
                    ),
                  )
                else ...<Widget>[
                  LabeledField(
                    label: l10n.authEmailLabel,
                    child: TextField(
                      controller: _emailController,
                      onChanged: cubit.emailChanged,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      decoration: InputDecoration(hintText: l10n.authEmailHint),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LabeledField(
                    label: l10n.authPasswordLabel,
                    helperText: l10n.authRegisterPasswordHelper,
                    child: TextField(
                      controller: _passwordController,
                      onChanged: cubit.passwordChanged,
                      obscureText: true,
                      decoration: const InputDecoration(hintText: '••••••••'),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _TermsCheckbox(
                  value: state.acceptedTerms,
                  onChanged: cubit.termsToggled,
                ),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: state.method == RegistrationMethod.phone
                      ? l10n.authSendCode
                      : l10n.authCreateAccount,
                  isLoading: state.isSubmitting,
                  onPressed: state.canSubmitAccount
                      ? cubit.submitAccount
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: '${l10n.authRegisterHaveAccountPrompt}  ',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: <InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: widget.onSignIn,
                            child: Text(
                              l10n.authSignIn,
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
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

class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return InkWell(
      onTap: () => onChanged(!value),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Checkbox(
            value: value,
            onChanged: (bool? checked) => onChanged(checked ?? false),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text.rich(
                TextSpan(
                  text: l10n.authRegisterTermsPrefix,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.inkSoft,
                  ),
                  children: <InlineSpan>[
                    TextSpan(
                      text: l10n.authRegisterTermsLink,
                      style: AppTextStyles.bodySmallStrong.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    TextSpan(text: l10n.authRegisterTermsConnector),
                    TextSpan(
                      text: l10n.authRegisterPrivacyPolicyLink,
                      style: AppTextStyles.bodySmallStrong.copyWith(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
