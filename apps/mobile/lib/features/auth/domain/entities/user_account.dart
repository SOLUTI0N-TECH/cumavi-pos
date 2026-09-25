import 'package:equatable/equatable.dart';

/// How the account was created or authenticated.
enum AuthProvider { google, email, phone }

/// The person using the POS.
final class UserAccount extends Equatable {
  const UserAccount({
    required this.id,
    required this.fullName,
    required this.provider,
    this.email,
    this.phoneNumber,
  });

  final String id;
  final String fullName;
  final AuthProvider provider;
  final String? email;
  final String? phoneNumber;

  /// `CM` for "Carla Mamani" — used by the avatar.
  String get initials {
    final List<String> parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    provider,
    email,
    phoneNumber,
  ];
}
