import '../entities/business_profile.dart';
import '../entities/user_account.dart';

/// Holds who is signed in and which business the POS is operating.
///
/// Other features read it (the receipt needs the store, sales need the
/// cashier name); only the auth feature writes to it.
abstract interface class SessionRepository {
  UserAccount? get currentUser;

  BusinessProfile? get currentBusiness;

  /// Name printed on receipts; empty while nobody is signed in (selling
  /// requires a session, so receipts always carry one).
  String get currentCashierName;

  bool get isSignedIn;

  void saveUser(UserAccount user);

  void saveBusiness(BusinessProfile business);

  void clear();
}
