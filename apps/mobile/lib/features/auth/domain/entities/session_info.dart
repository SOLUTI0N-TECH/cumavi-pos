import 'package:equatable/equatable.dart';

import 'business_profile.dart';
import 'user_account.dart';

/// Who is signed in and which store the POS is operating.
final class SessionInfo extends Equatable {
  const SessionInfo({this.user, this.business});

  const SessionInfo.empty() : this();

  final UserAccount? user;
  final BusinessProfile? business;

  bool get isSignedIn => user != null;

  @override
  List<Object?> get props => <Object?>[user, business];
}
