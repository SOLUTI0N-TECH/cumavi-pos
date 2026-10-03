import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../cash_register/domain/entities/cash_session.dart';
import '../../../cash_register/domain/repositories/cash_register_repository.dart';
import '../../../inventory/domain/entities/stock_movement.dart';
import '../../../inventory/domain/repositories/inventory_repository.dart';
import '../entities/sale.dart';
import '../entities/sale_line.dart';
import '../entities/sale_return.dart';
import '../repositories/sales_repository.dart';

/// Rules shared by the detail screen (to offer the actions) and the use
/// cases (to enforce them).
abstract final class SaleCorrectionRules {
  /// Days after the sale a customer can still return units.
  static const int returnWindowDays = 30;

  /// A sale can be cancelled while the cash session it happened in is open,
  /// so the drawer can still give the money back and the close is right.
  static Failure? cancelBlocker(Sale sale, CashSession? session) {
    if (sale.isCancelled) {
      return const ConflictFailure(FailureCode.saleAlreadyCancelled);
    }
    if (sale.returns.isNotEmpty) {
      return const ConflictFailure(FailureCode.saleHasReturns);
    }
    if (session == null ||
        !session.isOpen ||
        sale.createdAt.isBefore(session.openedAt)) {
      return const ConflictFailure(FailureCode.saleCancelWindowClosed);
    }
    return null;
  }

  static Failure? returnBlocker(Sale sale, DateTime now) {
    if (sale.isCancelled) {
      return const ConflictFailure(FailureCode.saleAlreadyCancelled);
    }
    final DateTime lastDay = DateTime(
      sale.createdAt.year,
      sale.createdAt.month,
      sale.createdAt.day + returnWindowDays + 1,
    );
    if (!now.isBefore(lastDay)) {
      return const ConflictFailure(FailureCode.returnWindowClosed);
    }
    final bool anyLeft = <int>[
      for (int i = 0; i < sale.lines.length; i++) sale.returnableQuantity(i),
    ].any((int left) => left > 0);
    if (!anyLeft) {
      return const ConflictFailure(FailureCode.returnQuantityExceeded);
    }
    return null;
  }

  /// Methods the money can go back by: the sale's own, or cash.
  static List<PaymentMethod> refundMethodsFor(Sale sale) =>
      <PaymentMethod>{sale.paymentMethod, PaymentMethod.cash}.toList();
}

/// Input of [CancelSale].
final class SaleCancellationRequest {
  const SaleCancellationRequest({required this.saleId, required this.reason});

  final String saleId;
  final String reason;
}

/// "Anular": the whole sale leaves the totals and its units go back to the
/// stock.
final class CancelSale implements UseCase<Sale, SaleCancellationRequest> {
  const CancelSale({
    required SalesRepository salesRepository,
    required InventoryRepository inventoryRepository,
    required CashRegisterRepository cashRegisterRepository,
  }) : _salesRepository = salesRepository,
       _inventoryRepository = inventoryRepository,
       _cashRegisterRepository = cashRegisterRepository;

  final SalesRepository _salesRepository;
  final InventoryRepository _inventoryRepository;
  final CashRegisterRepository _cashRegisterRepository;

  @override
  Future<Result<Sale>> call(SaleCancellationRequest input) async {
    final String reason = input.reason.trim();
    if (reason.isEmpty) {
      return const Failed<Sale>(ValidationFailure(FailureCode.reasonRequired));
    }
    final Result<Sale> saleResult = await _salesRepository.getSaleById(
      input.saleId,
    );
    if (saleResult case Failed<Sale>()) return saleResult;
    final Result<CashSession?> sessionResult = await _cashRegisterRepository
        .getCurrentSession();
    if (sessionResult case Failed<CashSession?>(:final Failure failure)) {
      return Failed<Sale>(failure);
    }

    final Sale sale = saleResult.valueOrNull!;
    final Failure? blocker = SaleCorrectionRules.cancelBlocker(
      sale,
      sessionResult.valueOrNull,
    );
    if (blocker != null) return Failed<Sale>(blocker);

    final Result<Sale> cancelled = await _salesRepository.cancelSale(
      sale.id,
      reason: reason,
    );
    if (cancelled case Failed<Sale>()) return cancelled;

    final Result<List<StockMovement>> stock = await _inventoryRepository
        .recordMovements(<StockMovementDraft>[
          for (final SaleLine line in sale.lines)
            StockMovementDraft(
              productId: line.productId,
              variantId: line.variantId,
              delta: line.quantity,
              type: StockMovementType.cancellation,
              saleId: sale.id,
              note: reason,
            ),
        ]);
    if (stock case Failed<List<StockMovement>>(:final Failure failure)) {
      return Failed<Sale>(failure);
    }
    return cancelled;
  }
}

/// Units of one line to give back.
final class ReturnItem {
  const ReturnItem({
    required this.lineIndex,
    required this.quantity,
    this.restock = true,
  });

  final int lineIndex;
  final int quantity;
  final bool restock;
}

/// Input of [RegisterReturn].
final class SaleReturnRequest {
  const SaleReturnRequest({
    required this.saleId,
    required this.items,
    required this.refundMethod,
    required this.reason,
  });

  final String saleId;
  final List<ReturnItem> items;
  final PaymentMethod refundMethod;
  final String reason;
}

/// "Devolver": some units come back, the money goes back (discount
/// prorated) and, when they can be sold again, the units return to stock.
final class RegisterReturn implements UseCase<SaleReturn, SaleReturnRequest> {
  RegisterReturn({
    required SalesRepository salesRepository,
    required InventoryRepository inventoryRepository,
    required CashRegisterRepository cashRegisterRepository,
    DateTime Function()? clock,
  }) : _salesRepository = salesRepository,
       _inventoryRepository = inventoryRepository,
       _cashRegisterRepository = cashRegisterRepository,
       _clock = clock ?? DateTime.now;

  final SalesRepository _salesRepository;
  final InventoryRepository _inventoryRepository;
  final CashRegisterRepository _cashRegisterRepository;
  final DateTime Function() _clock;

  @override
  Future<Result<SaleReturn>> call(SaleReturnRequest input) async {
    final String reason = input.reason.trim();
    if (reason.isEmpty) {
      return const Failed<SaleReturn>(
        ValidationFailure(FailureCode.reasonRequired),
      );
    }
    final List<ReturnItem> items = input.items
        .where((ReturnItem item) => item.quantity > 0)
        .toList();
    if (items.isEmpty) {
      return const Failed<SaleReturn>(
        ValidationFailure(FailureCode.emptyReturn),
      );
    }

    // The refund leaves the drawer (or is recorded) in an open session.
    final Result<bool> drawer = await _cashRegisterRepository.hasOpenSession();
    switch (drawer) {
      case Failed<bool>(:final Failure failure):
        return Failed<SaleReturn>(failure);
      case Success<bool>(value: false):
        return const Failed<SaleReturn>(
          ConflictFailure(FailureCode.cashSessionRequired),
        );
      case Success<bool>():
        break;
    }

    final Result<Sale> saleResult = await _salesRepository.getSaleById(
      input.saleId,
    );
    if (saleResult case Failed<Sale>(:final Failure failure)) {
      return Failed<SaleReturn>(failure);
    }
    final Sale sale = saleResult.valueOrNull!;
    final Failure? blocker = SaleCorrectionRules.returnBlocker(sale, _clock());
    if (blocker != null) return Failed<SaleReturn>(blocker);
    if (!SaleCorrectionRules.refundMethodsFor(sale)
        .contains(input.refundMethod)) {
      return const Failed<SaleReturn>(
        ValidationFailure(FailureCode.invalidRefundMethod),
      );
    }

    final List<SaleReturnLine> lines = <SaleReturnLine>[];
    for (final ReturnItem item in items) {
      if (item.lineIndex < 0 ||
          item.lineIndex >= sale.lines.length ||
          item.quantity > sale.returnableQuantity(item.lineIndex)) {
        return const Failed<SaleReturn>(
          ValidationFailure(FailureCode.returnQuantityExceeded),
        );
      }
      final SaleLine line = sale.lines[item.lineIndex];
      lines.add(
        SaleReturnLine(
          lineIndex: item.lineIndex,
          productId: line.productId,
          productName: line.productName,
          variantId: line.variantId,
          variantLabel: line.variantLabel,
          quantity: item.quantity,
          amount: sale.refundFor(item.lineIndex, item.quantity),
          restock: item.restock,
        ),
      );
    }

    final Result<SaleReturn> recorded = await _salesRepository.registerReturn(
      SaleReturnDraft(
        saleId: sale.id,
        lines: lines,
        refundMethod: input.refundMethod,
        reason: reason,
      ),
    );
    if (recorded case Failed<SaleReturn>()) return recorded;

    final List<StockMovementDraft> restock = <StockMovementDraft>[
      for (final SaleReturnLine line in lines)
        if (line.restock)
          StockMovementDraft(
            productId: line.productId,
            variantId: line.variantId,
            delta: line.quantity,
            type: StockMovementType.saleReturn,
            saleId: sale.id,
            note: reason,
          ),
    ];
    final Result<List<StockMovement>> stock = await _inventoryRepository
        .recordMovements(restock);
    if (stock case Failed<List<StockMovement>>(:final Failure failure)) {
      return Failed<SaleReturn>(failure);
    }
    return recorded;
  }
}
