import '../../../../core/utils/result.dart';
import '../entities/store_settings.dart';

/// `GET/PATCH /online-store`. Mocked in memory until backend phase B7.
abstract interface class StoreSettingsRepository {
  Future<Result<StoreSettings>> getSettings();

  Future<Result<StoreSettings>> saveSettings(StoreSettings settings);
}
