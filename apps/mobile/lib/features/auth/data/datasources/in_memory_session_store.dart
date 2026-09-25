import '../../domain/entities/business_profile.dart';
import '../../domain/entities/user_account.dart';
import '../../domain/repositories/session_repository.dart';

/// Session held in memory for the app lifetime.
///
/// It is seeded with the demo store so every screen has data even when the
/// sign-in screen is skipped; the registration flow overwrites it.
final class InMemorySessionStore implements SessionRepository {
  InMemorySessionStore({UserAccount? user, BusinessProfile? business})
    : _user = user ?? demoUser,
      _business = business ?? demoBusiness;

  static const UserAccount demoUser = UserAccount(
    id: 'user-demo',
    fullName: 'Carla Mamani',
    provider: AuthProvider.phone,
    phoneNumber: '76543210',
  );

  static const BusinessProfile demoBusiness = BusinessProfile(
    id: 'business-demo',
    name: 'Illimani Store',
    type: BusinessType.clothingAndFootwear,
    department: BoliviaDepartment.laPaz,
    taxId: '1020304050',
  );

  UserAccount? _user;
  BusinessProfile? _business;

  @override
  UserAccount? get currentUser => _user;

  @override
  BusinessProfile? get currentBusiness => _business;

  @override
  String get currentCashierName => _user?.fullName ?? '';

  @override
  bool get isSignedIn => _user != null;

  @override
  void saveUser(UserAccount user) => _user = user;

  @override
  void saveBusiness(BusinessProfile business) => _business = business;

  @override
  void clear() {
    _user = null;
    _business = null;
  }
}
