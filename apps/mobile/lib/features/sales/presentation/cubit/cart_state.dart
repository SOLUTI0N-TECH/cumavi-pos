import 'package:equatable/equatable.dart';

import '../../domain/entities/cart.dart';

final class CartState extends Equatable {
  const CartState({this.cart = const Cart.empty(), this.nextSaleNumber});

  final Cart cart;

  /// Number the sale will get once charged; `null` while it loads.
  final int? nextSaleNumber;

  /// `#0019`, or an empty string until the number is known.
  String get formattedSaleNumber => nextSaleNumber == null
      ? ''
      : '#${nextSaleNumber!.toString().padLeft(4, '0')}';

  CartState copyWith({Cart? cart, int? nextSaleNumber}) => CartState(
    cart: cart ?? this.cart,
    nextSaleNumber: nextSaleNumber ?? this.nextSaleNumber,
  );

  @override
  List<Object?> get props => <Object?>[cart, nextSaleNumber];
}
