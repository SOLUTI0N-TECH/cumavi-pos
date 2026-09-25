import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../cash_register/domain/repositories/cash_register_repository.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../entities/cart.dart';
import '../entities/cart_line.dart';
import '../entities/sale.dart';
import '../entities/sale_draft.dart';
import '../repositories/sales_repository.dart';

/// Registers a sale: checks the cash drawer is open, stores the sale and
/// discounts the sold units from the stock.
///
/// Orchestrating the three repositories here keeps the rule in the domain
/// instead of spreading it over the UI.
final class RegisterSale implements UseCase<Sale, SaleDraft> {
  const RegisterSale({
    required SalesRepository salesRepository,
    required ProductRepository productRepository,
    required CashRegisterRepository cashRegisterRepository,
  }) : _salesRepository = salesRepository,
       _productRepository = productRepository,
       _cashRegisterRepository = cashRegisterRepository;

  final SalesRepository _salesRepository;
  final ProductRepository _productRepository;
  final CashRegisterRepository _cashRegisterRepository;

  @override
  Future<Result<Sale>> call(SaleDraft input) async {
    final Cart cart = input.cart;
    if (cart.isEmpty) {
      return const Failed<Sale>(ValidationFailure(FailureCode.emptyCart));
    }
    if (input.amountReceived < cart.total) {
      return const Failed<Sale>(
        ValidationFailure(FailureCode.insufficientPayment),
      );
    }

    final Result<bool> drawerState = await _cashRegisterRepository
        .hasOpenSession();
    switch (drawerState) {
      case Failed<bool>(:final Failure failure):
        return Failed<Sale>(failure);
      case Success<bool>(value: false):
        return const Failed<Sale>(
          ConflictFailure(FailureCode.cashSessionRequired),
        );
      case Success<bool>():
        break;
    }

    final Result<Sale> saleResult = await _salesRepository.registerSale(input);
    if (saleResult case Failed<Sale>(:final Failure failure)) {
      return Failed<Sale>(failure);
    }

    final Result<void> stockResult = await _productRepository.reduceStock(
      cart.lines
          .map(
            (CartLine line) => StockMovement(
              productId: line.product.id,
              variantId: line.variant?.id,
              quantity: line.quantity,
            ),
          )
          .toList(),
    );
    if (stockResult case Failed<void>(:final Failure failure)) {
      return Failed<Sale>(failure);
    }

    return saleResult;
  }
}
