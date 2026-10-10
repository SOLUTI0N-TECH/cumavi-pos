import '../../../../core/domain/bolivian_phone_number.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/text_normalizer.dart';
import '../entities/store_settings.dart';
import '../repositories/store_settings_repository.dart';

/// Rules of the online store settings.
abstract final class StoreSettingsRules {
  static const int maxTaglineLength = 80;
  static const int maxDeliveryNoteLength = 200;

  /// The first broken rule, or `null` when the settings can be saved.
  static Failure? validate(StoreSettings settings) {
    if (settings.whatsapp.trim().isNotEmpty &&
        !BolivianPhoneNumber.isValidMobile(settings.whatsapp)) {
      return const ValidationFailure(FailureCode.invalidMobileNumber);
    }
    if (!settings.pickupEnabled && !settings.deliveryEnabled) {
      return const ValidationFailure(FailureCode.onlineFulfillmentRequired);
    }
    if (settings.onlinePaymentMethods.isEmpty) {
      return const ValidationFailure(FailureCode.onlinePaymentMethodRequired);
    }
    return checkOpeningHours(settings.openingHours);
  }

  /// `SUC-R5`: closing after opening, and no overlapping ranges in a day.
  static Failure? checkOpeningHours(List<OpeningHoursRange> ranges) {
    for (int i = 0; i < ranges.length; i++) {
      final OpeningHoursRange range = ranges[i];
      final bool valid =
          range.weekday >= 1 &&
          range.weekday <= 7 &&
          range.opensAt >= 0 &&
          range.closesAt <= 24 * 60 &&
          range.closesAt > range.opensAt;
      if (!valid) {
        return const ValidationFailure(FailureCode.invalidOpeningHours);
      }
      for (int j = i + 1; j < ranges.length; j++) {
        if (range.overlaps(ranges[j])) {
          return const ValidationFailure(FailureCode.invalidOpeningHours);
        }
      }
    }
    return null;
  }

  /// `Illimani Store` → `illimani-store`.
  static String slugFor(String businessName) {
    final String slug = TextNormalizer.normalize(businessName)
        .replaceAll(RegExp('[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'mi-tienda' : slug;
  }
}

final class GetStoreSettings implements UseCase<StoreSettings, NoParams> {
  const GetStoreSettings(this._repository);

  final StoreSettingsRepository _repository;

  @override
  Future<Result<StoreSettings>> call(NoParams input) =>
      _repository.getSettings();
}

/// Validates and stores the settings; texts are saved trimmed.
final class SaveStoreSettings implements UseCase<StoreSettings, StoreSettings> {
  const SaveStoreSettings(this._repository);

  final StoreSettingsRepository _repository;

  @override
  Future<Result<StoreSettings>> call(StoreSettings input) async {
    final StoreSettings settings = input.copyWith(
      tagline: input.tagline.trim(),
      whatsapp: BolivianPhoneNumber.normalize(input.whatsapp),
      deliveryNote: input.deliveryNote.trim(),
    );
    final Failure? failure = StoreSettingsRules.validate(settings);
    if (failure != null) return Failed<StoreSettings>(failure);
    return _repository.saveSettings(settings);
  }
}
