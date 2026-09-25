import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/segmented_selector.dart';
import '../cubit/session_cubit.dart';
import '../cubit/sign_in_cubit.dart';
import '../cubit/sign_in_state.dart';
import '../widgets/demo_code_banner.dart';
import '../widgets/google_auth_button.dart';
import '../widgets/phone_number_field.dart';
import '../widgets/verification_code_field.dart';

/// Sign-in screen: Google, email + password or phone.
class SignInScreen extends StatefulWidget {
  const SignInScreen({
    required this.onSignedIn,
    required this.onCreateAccount,
    super.key,
  });

  final VoidCallback onSignedIn;
  final VoidCallback onCreateAccount;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit(SignInState state) {
    final SignInCubit cubit = context.read<SignInCubit>();
    return switch (state.method) {
      SignInMethod.email => cubit.signInWithEmail(),
      SignInMethod.phone when state.codeSent => cubit.signInWithPhone(),
      SignInMethod.phone => cubit.requestPhoneCode(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<SignInCubit, SignInState>(
          listener: (BuildContext context, SignInState state) {
            if (state.status == SignInStatus.success) {
              // The session must be loaded before the shell renders.
              context.read<SessionCubit>().refresh().then((_) {
                widget.onSignedIn();
              });
            }
            if (state.status == SignInStatus.failure && state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.failure!.localizedMessage(context.l10n)),
                ),
              );
            }
          },
          builder: (BuildContext context, SignInState state) {
            final SignInCubit cubit = context.read<SignInCubit>();
            final AppLocalizations l10n = context.l10n;

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xxxl,
                AppSpacing.xl,
                AppSpacing.xl,
              ),
              children: <Widget>[
                const BrandMark(),
                const SizedBox(height: AppSpacing.xxxl + AppSpacing.md),
                Text(l10n.authSignInTitle, style: AppTextStyles.display),
                const SizedBox(height: 6),
                Text(
                  l10n.authSignInSubtitle,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                GoogleAuthButton(
                  label: l10n.authSignInWithGoogle,
                  onPressed: state.isSubmitting ? null : cubit.signInWithGoogle,
                ),
                const SizedBox(height: AppSpacing.xl),
                AuthDivider(label: l10n.authSignInDivider),
                const SizedBox(height: AppSpacing.lg),
                SegmentedSelector<SignInMethod>(
                  options: <SegmentOption<SignInMethod>>[
                    SegmentOption<SignInMethod>(
                      value: SignInMethod.email,
                      label: l10n.authMethodEmail,
                      icon: Icons.mail_outline_rounded,
                    ),
                    SegmentOption<SignInMethod>(
                      value: SignInMethod.phone,
                      label: l10n.authMethodPhone,
                      icon: Icons.smartphone_rounded,
                    ),
                  ],
                  selectedValue: state.method,
                  onSelected: cubit.methodChanged,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (state.method == SignInMethod.email)
                  _EmailForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    obscurePassword: _obscurePassword,
                    onToggleObscure: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  )
                else if (state.codeSent)
                  _PhoneCodeForm(state: state)
                else
                  LabeledField(
                    label: l10n.authPhoneNumberLabel,
                    helperText: l10n.authSignInPhoneHelper,
                    child: PhoneNumberField(
                      controller: _phoneController,
                      focused: true,
                      onChanged: cubit.phoneNumberChanged,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryButton(
                  label: state.method == SignInMethod.phone && !state.codeSent
                      ? l10n.authSendCode
                      : l10n.authSignIn,
                  isLoading: state.isSubmitting,
                  onPressed: state.canSubmit ? () => _submit(state) : null,
                ),
                const SizedBox(height: AppSpacing.xxl),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: '${l10n.authSignInNoAccountPrompt}  ',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      children: <InlineSpan>[
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: widget.onCreateAccount,
                            child: Text(
                              l10n.authCreateAccount,
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

/// Demo stand-in for password recovery: there is no email service yet, so
/// it only confirms where the link would go.
void _showPasswordReset(BuildContext context) {
  final AppLocalizations l10n = context.l10n;
  final String email = context.read<SignInCubit>().state.email.trim();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        email.contains('@')
            ? l10n.authSignInPasswordResetSent(email)
            : l10n.authSignInPasswordResetNeedsEmail,
      ),
    ),
  );
}

/// Phone sign-in, step 2: the SMS code.
class _PhoneCodeForm extends StatelessWidget {
  const _PhoneCodeForm({required this.state});

  final SignInState state;

  @override
  Widget build(BuildContext context) {
    final SignInCubit cubit = context.read<SignInCubit>();
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text.rich(
          TextSpan(
            text: l10n.authPhoneVerificationSentTo,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            children: <InlineSpan>[
              TextSpan(
                text: '+591 ${state.phoneNumber}',
                style: AppTextStyles.bodyStrong,
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            TextButton(
              onPressed: state.isSubmitting ? null : cubit.changePhoneNumber,
              child: Text(l10n.authPhoneVerificationChangeNumber),
            ),
            const Spacer(),
            TextButton(
              onPressed: state.isSubmitting ? null : cubit.requestPhoneCode,
              child: Text(l10n.authPhoneVerificationResend),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        VerificationCodeField(value: state.code, onChanged: cubit.codeChanged),
        if (state.demoCode case final String demoCode) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          DemoCodeBanner(code: demoCode, onUse: cubit.codeChanged),
        ],
      ],
    );
  }
}

class _EmailForm extends StatelessWidget {
  const _EmailForm({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onToggleObscure,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final SignInCubit cubit = context.read<SignInCubit>();
    final AppLocalizations l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        LabeledField(
          label: l10n.authEmailLabel,
          child: TextField(
            controller: emailController,
            onChanged: cubit.emailChanged,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(hintText: l10n.authEmailHint),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        LabeledField(
          label: l10n.authPasswordLabel,
          child: TextField(
            controller: passwordController,
            onChanged: cubit.passwordChanged,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              hintText: l10n.authSignInPasswordHint,
              suffixIcon: IconButton(
                onPressed: onToggleObscure,
                tooltip: obscurePassword
                    ? l10n.authSignInShowPassword
                    : l10n.authSignInHidePassword,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => _showPasswordReset(context),
            child: Text(l10n.authSignInForgotPassword),
          ),
        ),
      ],
    );
  }
}
