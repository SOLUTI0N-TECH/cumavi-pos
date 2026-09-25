import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/business_profile.dart';
import 'sale.dart';

/// What gets printed or shared: the sale plus the store it belongs to.
final class Receipt extends Equatable {
  const Receipt({required this.sale, this.business});

  final Sale sale;

  /// `null` only if the session has no business yet; the receipt then shows
  /// a generic header.
  final BusinessProfile? business;

  /// `0019`
  String get number => sale.number.toString().padLeft(4, '0');

  @override
  List<Object?> get props => <Object?>[sale, business];
}
