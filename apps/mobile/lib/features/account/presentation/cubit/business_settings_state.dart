import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../auth/domain/entities/business_profile.dart';

enum BusinessSettingsStatus { editing, pickingLogo, saving, saved, failure }

final class BusinessSettingsState extends Equatable {
  const BusinessSettingsState({
    required this.original,
    required this.name,
    required this.type,
    required this.department,
    required this.taxId,
    this.logoPath,
    this.status = BusinessSettingsStatus.editing,
    this.failure,
  });

  factory BusinessSettingsState.from(BusinessProfile business) {
    return BusinessSettingsState(
      original: business,
      name: business.name,
      type: business.type,
      department: business.department,
      taxId: business.taxId ?? '',
      logoPath: business.logoPath,
    );
  }

  /// Saved data, to know whether something changed.
  final BusinessProfile original;
  final String name;
  final BusinessType type;
  final BoliviaDepartment department;

  /// NIT as typed; empty means "no NIT".
  final String taxId;
  final String? logoPath;
  final BusinessSettingsStatus status;
  final Failure? failure;

  bool get isBusy =>
      status == BusinessSettingsStatus.saving ||
      status == BusinessSettingsStatus.pickingLogo;

  bool get hasChanges =>
      name.trim() != original.name ||
      type != original.type ||
      department != original.department ||
      taxId.trim() != (original.taxId ?? '') ||
      logoPath != original.logoPath;

  bool get canSave => hasChanges && name.trim().length >= 3 && !isBusy;

  BusinessSettingsState copyWith({
    BusinessProfile? original,
    String? name,
    BusinessType? type,
    BoliviaDepartment? department,
    String? taxId,
    String? logoPath,
    BusinessSettingsStatus? status,
    Failure? failure,
  }) {
    return BusinessSettingsState(
      original: original ?? this.original,
      name: name ?? this.name,
      type: type ?? this.type,
      department: department ?? this.department,
      taxId: taxId ?? this.taxId,
      logoPath: logoPath ?? this.logoPath,
      status: status ?? this.status,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    original,
    name,
    type,
    department,
    taxId,
    logoPath,
    status,
    failure,
  ];
}
