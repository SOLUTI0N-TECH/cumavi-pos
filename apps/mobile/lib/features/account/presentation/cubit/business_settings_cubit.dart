import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/result.dart';
import '../../../auth/domain/entities/business_profile.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/save_business_profile.dart';
import '../../../catalog/domain/services/photo_capturer.dart';
import '../../domain/usecases/pick_business_logo.dart';
import 'business_settings_state.dart';

/// Edits the business data from the "Más" hub: name, type, department,
/// logo and NIT.
class BusinessSettingsCubit extends Cubit<BusinessSettingsState> {
  BusinessSettingsCubit({
    required BusinessProfile business,
    required SaveBusinessProfile saveBusinessProfile,
    required PickBusinessLogo pickBusinessLogo,
  }) : _saveBusinessProfile = saveBusinessProfile,
       _pickBusinessLogo = pickBusinessLogo,
       super(BusinessSettingsState.from(business));

  final SaveBusinessProfile _saveBusinessProfile;
  final PickBusinessLogo _pickBusinessLogo;

  void nameChanged(String name) => _edit(state.copyWith(name: name));

  void typeSelected(BusinessType type) => _edit(state.copyWith(type: type));

  void departmentSelected(BoliviaDepartment department) =>
      _edit(state.copyWith(department: department));

  void taxIdChanged(String taxId) => _edit(state.copyWith(taxId: taxId));

  Future<void> pickLogo(PhotoSource source) async {
    emit(state.copyWith(status: BusinessSettingsStatus.pickingLogo));
    switch (await _pickBusinessLogo(source)) {
      case Success<String?>(value: null):
        emit(state.copyWith(status: BusinessSettingsStatus.editing));
      case Success<String?>(:final String? value):
        emit(
          state.copyWith(
            logoPath: value,
            status: BusinessSettingsStatus.editing,
          ),
        );
      case Failed<String?>(:final failure):
        emit(
          state.copyWith(
            status: BusinessSettingsStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  Future<void> save() async {
    if (!state.canSave) return;
    emit(state.copyWith(status: BusinessSettingsStatus.saving));

    final Result<BusinessProfile> result = await _saveBusinessProfile(
      BusinessProfileDraft(
        name: state.name,
        type: state.type,
        department: state.department,
        logoPath: state.logoPath,
        taxId: state.taxId,
      ),
    );

    switch (result) {
      case Success<BusinessProfile>(:final BusinessProfile value):
        emit(
          BusinessSettingsState.from(value)
              .copyWith(status: BusinessSettingsStatus.saved),
        );
      case Failed<BusinessProfile>(:final failure):
        emit(
          state.copyWith(
            status: BusinessSettingsStatus.failure,
            failure: failure,
          ),
        );
    }
  }

  /// Any edit leaves a previous error or confirmation behind.
  void _edit(BusinessSettingsState next) =>
      emit(next.copyWith(status: BusinessSettingsStatus.editing));
}
