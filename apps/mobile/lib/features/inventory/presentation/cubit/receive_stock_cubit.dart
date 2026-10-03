import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_code_match.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../../catalog/domain/usecases/find_product_by_code.dart';
import '../../../catalog/domain/usecases/get_products.dart';
import '../../domain/entities/stock_movement.dart';
import '../../domain/usecases/stock_usecases.dart';

/// A product (or variant) being received, with its units and cost.
final class ReceiptLine extends Equatable {
  const ReceiptLine({
    required this.product,
    required this.quantity,
    this.variant,
    this.unitCost,
  });

  final Product product;
  final ProductVariant? variant;
  final int quantity;

  /// `null` keeps it unknown; the product's cost is only a hint.
  final double? unitCost;

  bool isFor(Product product, ProductVariant? variant) =>
      this.product.id == product.id && this.variant?.id == variant?.id;

  int get currentStock => variant?.stockQuantity ?? product.stockQuantity;

  ReceiptLine withQuantity(int quantity) => ReceiptLine(
    product: product,
    variant: variant,
    quantity: quantity,
    unitCost: unitCost,
  );

  ReceiptLine withUnitCost(double? unitCost) => ReceiptLine(
    product: product,
    variant: variant,
    quantity: quantity,
    unitCost: unitCost,
  );

  @override
  List<Object?> get props => <Object?>[product, variant, quantity, unitCost];
}

enum ReceiveStockStatus { loading, editing, saving, saved }

final class ReceiveStockState extends Equatable {
  const ReceiveStockState({
    this.status = ReceiveStockStatus.loading,
    this.catalog = const <Product>[],
    this.lines = const <ReceiptLine>[],
    this.note = '',
    this.failure,
  });

  final ReceiveStockStatus status;

  /// Products the seller can pick from.
  final List<Product> catalog;
  final List<ReceiptLine> lines;

  /// Supplier or remark.
  final String note;
  final Failure? failure;

  int get totalUnits =>
      lines.fold(0, (int sum, ReceiptLine line) => sum + line.quantity);

  bool get canSubmit =>
      status == ReceiveStockStatus.editing &&
      lines.isNotEmpty &&
      lines.every((ReceiptLine line) => (line.unitCost ?? 0) >= 0);

  ReceiveStockState copyWith({
    ReceiveStockStatus? status,
    List<Product>? catalog,
    List<ReceiptLine>? lines,
    String? note,
    Failure? failure,
  }) => ReceiveStockState(
    status: status ?? this.status,
    catalog: catalog ?? this.catalog,
    lines: lines ?? this.lines,
    note: note ?? this.note,
    failure: failure,
  );

  @override
  List<Object?> get props => <Object?>[status, catalog, lines, note, failure];
}

/// "Ingreso de mercadería": several products received at once.
class ReceiveStockCubit extends Cubit<ReceiveStockState> {
  ReceiveStockCubit({
    required GetProducts getProducts,
    required FindProductByCode findProductByCode,
    required ReceiveStock receiveStock,
  }) : _getProducts = getProducts,
       _findProductByCode = findProductByCode,
       _receiveStock = receiveStock,
       super(const ReceiveStockState());

  final GetProducts _getProducts;
  final FindProductByCode _findProductByCode;
  final ReceiveStock _receiveStock;

  /// Loads the products; [productId] starts the receipt with that product
  /// when it has no variants, and returns it so the screen can ask for the
  /// variant otherwise.
  Future<Product?> load({String? productId}) async {
    final Result<List<Product>> result = await _getProducts(
      const ProductQuery(),
    );
    final List<Product> catalog = result.valueOrNull ?? const <Product>[];
    emit(
      state.copyWith(
        status: ReceiveStockStatus.editing,
        catalog: catalog,
        failure: result.failureOrNull,
      ),
    );
    final Product? product = catalog
        .where((Product product) => product.id == productId)
        .firstOrNull;
    if (product != null && !product.hasVariants) addLine(product);
    return product;
  }

  /// Adds one unit of [product] (in [variant]); picking it again adds one
  /// more to its line.
  void addLine(Product product, {ProductVariant? variant}) {
    final int index = state.lines.indexWhere(
      (ReceiptLine line) => line.isFor(product, variant),
    );
    emit(
      state.copyWith(
        lines: index == -1
            ? <ReceiptLine>[
                ...state.lines,
                ReceiptLine(product: product, variant: variant, quantity: 1),
              ]
            : <ReceiptLine>[
                for (int i = 0; i < state.lines.length; i++)
                  i == index
                      ? state.lines[i].withQuantity(state.lines[i].quantity + 1)
                      : state.lines[i],
              ],
      ),
    );
  }

  /// Finds a scanned code; a variant or a simple product is added right
  /// away, a product with variants is returned so the screen asks which.
  Future<Result<ProductCodeMatch>> addByCode(String code) async {
    final Result<ProductCodeMatch> result = await _findProductByCode(code);
    if (result
        case Success<ProductCodeMatch>(
          value: ProductCodeMatch(:final Product product, :final variant),
        )
        when variant != null || !product.hasVariants) {
      addLine(product, variant: variant);
    }
    return result;
  }

  void quantityChanged(int index, int quantity) {
    if (quantity < 1) return;
    _replace(index, state.lines[index].withQuantity(quantity));
  }

  void unitCostChanged(int index, double? unitCost) =>
      _replace(index, state.lines[index].withUnitCost(unitCost));

  void removeLine(int index) => emit(
    state.copyWith(lines: <ReceiptLine>[...state.lines]..removeAt(index)),
  );

  void noteChanged(String note) => emit(state.copyWith(note: note));

  Future<void> submit() async {
    if (!state.canSubmit) return;
    emit(state.copyWith(status: ReceiveStockStatus.saving));
    final Result<List<StockMovement>> result = await _receiveStock(
      GoodsReceipt(
        note: state.note,
        lines: <ReceivingLine>[
          for (final ReceiptLine line in state.lines)
            ReceivingLine(
              productId: line.product.id,
              variantId: line.variant?.id,
              quantity: line.quantity,
              unitCost: line.unitCost,
            ),
        ],
      ),
    );
    switch (result) {
      case Success<List<StockMovement>>():
        emit(state.copyWith(status: ReceiveStockStatus.saved));
      case Failed<List<StockMovement>>(:final failure):
        emit(
          state.copyWith(status: ReceiveStockStatus.editing, failure: failure),
        );
    }
  }

  void _replace(int index, ReceiptLine line) => emit(
    state.copyWith(
      lines: <ReceiptLine>[
        for (int i = 0; i < state.lines.length; i++)
          i == index ? line : state.lines[i],
      ],
    ),
  );
}
