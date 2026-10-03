import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../../../core/widgets/selectable_tile.dart';
import '../../../auth/domain/entities/business_profile.dart';
import '../../../auth/presentation/view_data/business_view_data.dart';
import '../../../catalog/domain/services/photo_capturer.dart';
import '../../../catalog/presentation/widgets/photo_source_sheet.dart';
import '../cubit/business_settings_cubit.dart';
import '../cubit/business_settings_state.dart';
import '../widgets/business_logo.dart';

/// Edits the business: logo, name, type, department and NIT.
class BusinessSettingsScreen extends StatefulWidget {
  const BusinessSettingsScreen({
    required this.onBack,
    required this.onSaved,
    super.key,
  });

  final VoidCallback onBack;

  /// Called after saving, so the app can refresh the session and go back.
  final VoidCallback onSaved;

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  late final BusinessSettingsState _initial = context
      .read<BusinessSettingsCubit>()
      .state;
  late final TextEditingController _nameController = TextEditingController(
    text: _initial.name,
  );
  late final TextEditingController _taxIdController = TextEditingController(
    text: _initial.taxId,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final BusinessSettingsCubit cubit = context.read<BusinessSettingsCubit>();
    final PhotoSource? source = await PhotoSourceSheet.show(
      context,
      title: context.l10n.authBusinessProfileLogoTitle,
      subtitle: context.l10n.authBusinessProfileLogoSourceSubtitle,
    );
    if (source != null) await cubit.pickLogo(source);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final BusinessSettingsCubit cubit = context.read<BusinessSettingsCubit>();

    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<BusinessSettingsCubit, BusinessSettingsState>(
          listener: (BuildContext context, BusinessSettingsState state) {
            if (state.status == BusinessSettingsStatus.saved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.accountBusinessSaved)),
              );
              widget.onSaved();
            }
            if (state.status == BusinessSettingsStatus.failure &&
                state.failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.failure!.localizedMessage(l10n))),
              );
            }
          },
          builder: (BuildContext context, BusinessSettingsState state) {
            return Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.xl,
                      AppSpacing.pageHorizontal,
                      AppSpacing.xxl,
                    ),
                    children: <Widget>[
                      PushedScreenHeader(
                        title: l10n.accountBusinessTitle,
                        subtitle: l10n.accountBusinessSubtitle,
                        onBack: widget.onBack,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Row(
                          children: <Widget>[
                            BusinessLogo(
                              initials: state.original.initials,
                              logoPath: state.logoPath,
                              size: 72,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    l10n.authBusinessProfileLogoTitle,
                                    style: AppTextStyles.bodyStrong,
                                  ),
                                  Text(
                                    l10n.authBusinessProfileLogoOptional,
                                    style: AppTextStyles.caption,
                                  ),
                                  TextButton.icon(
                                    onPressed: state.isBusy ? null : _pickLogo,
                                    icon:
                                        state.status ==
                                            BusinessSettingsStatus.pickingLogo
                                        ? const SizedBox.square(
                                            dimension: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.photo_camera_outlined,
                                            size: 18,
                                          ),
                                    label: Text(l10n.accountBusinessLogoChange),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            LabeledField(
                              label: l10n.authBusinessProfileNameLabel,
                              child: TextField(
                                controller: _nameController,
                                onChanged: cubit.nameChanged,
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
                              childAspectRatio: 1.05,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: <Widget>[
                                for (final BusinessType type
                                    in BusinessType.values)
                                  SelectableGridTile(
                                    label: type.label(l10n),
                                    icon: type.icon,
                                    isSelected: state.type == type,
                                    onTap: () => cubit.typeSelected(type),
                                  ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            LabeledField(
                              label: l10n.authBusinessProfileDepartmentLabel,
                              child: DropdownButtonFormField<BoliviaDepartment>(
                                initialValue: state.department,
                                isExpanded: true,
                                icon: const Icon(Icons.expand_more_rounded),
                                style: AppTextStyles.bodyLarge,
                                items: <DropdownMenuItem<BoliviaDepartment>>[
                                  for (final BoliviaDepartment department
                                      in BoliviaDepartment.values)
                                    DropdownMenuItem<BoliviaDepartment>(
                                      value: department,
                                      child: Text(department.displayName),
                                    ),
                                ],
                                onChanged: (BoliviaDepartment? value) {
                                  if (value != null) {
                                    cubit.departmentSelected(value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            LabeledField(
                              label: l10n.accountBusinessTaxIdLabel,
                              optionalText: l10n.accountBusinessOptional,
                              helperText: l10n.accountBusinessTaxIdHelper,
                              child: TextField(
                                controller: _taxIdController,
                                onChanged: cubit.taxIdChanged,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  hintText: l10n.accountBusinessTaxIdHint,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
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
                    child: PrimaryButton(
                      label: l10n.accountBusinessSave,
                      icon: Icons.check_rounded,
                      isLoading: state.status == BusinessSettingsStatus.saving,
                      onPressed: state.canSave ? cubit.save : null,
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
