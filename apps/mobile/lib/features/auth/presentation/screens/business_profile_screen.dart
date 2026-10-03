import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../../../core/widgets/step_progress_header.dart';
import '../../../account/presentation/widgets/business_logo.dart';
import '../../../catalog/domain/services/photo_capturer.dart';
import '../../../catalog/presentation/widgets/photo_source_sheet.dart';
import '../../domain/entities/business_profile.dart';
import '../cubit/registration_cubit.dart';
import '../cubit/registration_state.dart';
import '../view_data/business_view_data.dart';

/// Registration step 3: business name, type, department and logo.
class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({
    required this.onBack,
    required this.onSaved,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSaved;

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo(RegistrationCubit cubit) async {
    final PhotoSource? source = await PhotoSourceSheet.show(
      context,
      title: context.l10n.authBusinessProfileLogoTitle,
      subtitle: context.l10n.authBusinessProfileLogoSourceSubtitle,
    );
    if (source == null || !mounted) return;
    final Failure? failure = await cubit.pickLogo(source);
    if (failure != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.localizedMessage(context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: BlocConsumer<RegistrationCubit, RegistrationState>(
          listener: (BuildContext context, RegistrationState state) {
            if (state.status == RegistrationStatus.businessSaved) {
              widget.onSaved();
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

            return Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.xl,
                    AppSpacing.xl,
                    0,
                  ),
                  child: StepProgressHeader(
                    currentStep: 3,
                    totalSteps: 4,
                    stepLabel: l10n.authBusinessProfileStepLabel,
                    onBack: widget.onBack,
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xxl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                    ),
                    children: <Widget>[
                      Text(
                        l10n.authBusinessProfileTitle,
                        style: AppTextStyles.display.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        l10n.authBusinessProfileSubtitle,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _LogoPicker(
                        logoPath: state.logoPath,
                        onPick: () => _pickLogo(cubit),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      LabeledField(
                        label: l10n.authBusinessProfileNameLabel,
                        child: TextField(
                          controller: _nameController,
                          onChanged: cubit.businessNameChanged,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            hintText: l10n.authBusinessProfileNameHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        l10n.authBusinessProfileTypeLabel,
                        style: AppTextStyles.label,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GridView.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: BusinessType.values
                            .map(
                              (BusinessType type) => SelectableGridTile(
                                label: type.label(l10n),
                                icon: type.icon,
                                isSelected: state.businessType == type,
                                onTap: () => cubit.businessTypeSelected(type),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      LabeledField(
                        label: l10n.authBusinessProfileDepartmentLabel,
                        child: DropdownButtonFormField<BoliviaDepartment>(
                          initialValue: state.department,
                          isExpanded: true,
                          icon: const Icon(Icons.expand_more_rounded),
                          style: AppTextStyles.bodyLarge,
                          items: BoliviaDepartment.values
                              .map(
                                (BoliviaDepartment department) =>
                                    DropdownMenuItem<BoliviaDepartment>(
                                      value: department,
                                      child: Text(department.displayName),
                                    ),
                              )
                              .toList(),
                          onChanged: (BoliviaDepartment? value) {
                            if (value != null) cubit.departmentSelected(value);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    0,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                  ),
                  child: PrimaryButton(
                    label: l10n.commonContinue,
                    isLoading: state.isSubmitting,
                    onPressed: state.canSubmitBusiness
                        ? cubit.submitBusiness
                        : null,
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

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({required this.logoPath, required this.onPick});

  final String? logoPath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool hasLogo = BusinessLogo.isImage(logoPath);
    final BorderRadius radius = BorderRadius.circular(AppRadius.xxl - 2);

    return Row(
      children: <Widget>[
        InkWell(
          onTap: onPick,
          borderRadius: radius,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Container(
                height: 76,
                width: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: radius,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                // The chosen photo, or a camera until there is one.
                child: hasLogo
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.xxl - 4),
                        child: AppImage(logoPath!, width: 72, height: 72),
                      )
                    : const Icon(
                        Icons.photo_camera_outlined,
                        size: 26,
                        color: AppColors.inkSoft,
                      ),
              ),
              Positioned(
                right: -6,
                bottom: -6,
                child: Container(
                  height: 26,
                  width: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 3),
                  ),
                  child: Icon(
                    hasLogo ? Icons.edit_rounded : Icons.add_rounded,
                    size: 12,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                l10n.authBusinessProfileLogoTitle,
                style: AppTextStyles.bodyStrong,
              ),
              Text(
                hasLogo
                    ? l10n.authBusinessProfileLogoReady
                    : l10n.authBusinessProfileLogoOptional,
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
