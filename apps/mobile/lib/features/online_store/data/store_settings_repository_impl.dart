import '../../../core/domain/payment_method.dart';
import '../../../core/utils/result.dart';
import '../../auth/domain/repositories/session_repository.dart';
import '../domain/entities/store_settings.dart';
import '../domain/repositories/store_settings_repository.dart';
import '../domain/usecases/store_settings_usecases.dart';

/// Settings kept in memory, starting like the demo store of the web catalog
/// (`packages/mock-catalog/catalog.json`): Mon–Sat 09:00–20:00, pickup and
/// delivery, cash, QR and transfer.
final class InMemoryStoreSettingsRepository implements StoreSettingsRepository {
  InMemoryStoreSettingsRepository({
    required SessionRepository sessionRepository,
    Duration? latency,
  }) : _sessionRepository = sessionRepository,
       _latency = latency ?? const Duration(milliseconds: 200);

  final SessionRepository _sessionRepository;
  final Duration _latency;
  StoreSettings? _settings;

  @override
  Future<Result<StoreSettings>> getSettings() async {
    await Future<void>.delayed(_latency);
    return Success<StoreSettings>(_settings ??= _initial());
  }

  @override
  Future<Result<StoreSettings>> saveSettings(StoreSettings settings) async {
    await Future<void>.delayed(_latency);
    return Success<StoreSettings>(_settings = settings);
  }

  StoreSettings _initial() => StoreSettings(
    isEnabled: true,
    slug: StoreSettingsRules.slugFor(
      _sessionRepository.currentBusiness?.name ?? '',
    ),
    tagline: 'Ropa, calzado y accesorios',
    whatsapp: '76543210',
    deliveryNote: 'Envíos en el día dentro de la ciudad.',
    deliveryEnabled: true,
    onlinePaymentMethods: const <PaymentMethod>[
      PaymentMethod.cash,
      PaymentMethod.qr,
      PaymentMethod.bankTransfer,
    ],
    openingHours: <OpeningHoursRange>[
      for (int day = 1; day <= 6; day++)
        OpeningHoursRange(weekday: day, opensAt: 9 * 60, closesAt: 20 * 60),
    ],
  );
}
