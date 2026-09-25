import 'package:equatable/equatable.dart';

/// An SMS verification code on its way to [phoneNumber].
final class SentVerificationCode extends Equatable {
  const SentVerificationCode({required this.phoneNumber, this.demoCode});

  /// National number without the country code.
  final String phoneNumber;

  /// Only set while the app runs without a backend: no SMS is sent, so the
  /// screen shows this code to keep every flow usable. `null` in production.
  final String? demoCode;

  @override
  List<Object?> get props => <Object?>[phoneNumber, demoCode];
}
