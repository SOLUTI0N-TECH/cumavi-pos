import 'package:equatable/equatable.dart';

import '../../../../core/domain/payment_method.dart';

/// Last registration step: inventory categories, accepted payment methods and
/// the optional NIT.
final class SalesSetup extends Equatable {
  const SalesSetup({
    required this.categoryNames,
    required this.acceptedPaymentMethods,
    this.taxId,
  });

  final List<String> categoryNames;
  final Set<PaymentMethod> acceptedPaymentMethods;
  final String? taxId;

  @override
  List<Object?> get props => <Object?>[
    categoryNames,
    acceptedPaymentMethods,
    taxId,
  ];
}
