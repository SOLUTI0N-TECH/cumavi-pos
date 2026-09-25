import 'package:cumavi_pos_mobile/core/domain/payment_method.dart';
import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/entities/cash_session.dart';
import 'package:cumavi_pos_mobile/features/cash_register/domain/repositories/cash_register_repository.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_category.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_draft.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_image.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/entities/product_variant.dart';
import 'package:cumavi_pos_mobile/features/catalog/domain/repositories/product_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/cart.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/daily_sales_summary.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_draft.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/sale_line.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/repositories/sales_repository.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/register_sale.dart';
import 'package:flutter_test/flutter_test.dart';

final Product _product = Product(
  id: 'p-1',
  name: 'Billetera de cuero',
  category: const ProductCategory(id: 'accessories', name: 'Accesorios'),
  salePrice: 450,
  costPrice: 290,
  stockQuantity: 5,
  images: const <ProductImage>[
    ProductImage(id: 'img-1', path: 'assets/images/products/wallet.jpg'),
  ],
  createdAt: DateTime(2026, 9, 2),
);

class FakeSalesRepository implements SalesRepository {
  int registerCalls = 0;

  @override
  Future<Result<Sale>> registerSale(SaleDraft draft) async {
    registerCalls++;
    return Success<Sale>(
      Sale(
        id: 'sale-1',
        number: 1,
        createdAt: DateTime(2026, 9, 17, 11, 24),
        lines: <SaleLine>[
          SaleLine(
            productId: _product.id,
            productName: _product.name,
            unitPrice: _product.salePrice,
            quantity: draft.cart.itemCount,
          ),
        ],
        discount: draft.cart.discount,
        paymentMethod: draft.paymentMethod,
        amountReceived: draft.amountReceived,
        cashierName: 'Carla Mamani',
      ),
    );
  }

  @override
  Future<Result<DailySalesSummary>> getDailySummary(DateTime date) async =>
      Success<DailySalesSummary>(DailySalesSummary.empty(date));

  @override
  Future<Result<int>> getNextSaleNumber() async => const Success<int>(1);

  @override
  Future<Result<Sale>> getSaleById(String id) async =>
      const Failed<Sale>(NotFoundFailure(FailureCode.saleNotFound));

  @override
  Future<Result<DailySalesSummary>> getSummarySince(DateTime moment) async =>
      Success<DailySalesSummary>(DailySalesSummary.empty(moment));
}

class FakeProductRepository implements ProductRepository {
  List<StockMovement> movements = <StockMovement>[];

  @override
  Future<Result<Product>> createProduct(ProductDraft draft) async =>
      Success<Product>(_product);

  @override
  Future<Result<List<ProductCategory>>> getCategories() async =>
      const Success<List<ProductCategory>>(<ProductCategory>[]);

  @override
  Future<Result<List<Product>>> getLowStockProducts() async =>
      const Success<List<Product>>(<Product>[]);

  @override
  Future<Result<Product>> getProductById(String id) async =>
      Success<Product>(_product);

  @override
  Future<Result<List<Product>>> getProducts({
    String query = '',
    String? categoryId,
  }) async => Success<List<Product>>(<Product>[_product]);

  @override
  Future<Result<Product>> updateProduct(String id, ProductDraft draft) async =>
      Success<Product>(_product);

  @override
  Future<Result<void>> reduceStock(List<StockMovement> movements) async {
    this.movements = movements;
    return const Success<void>(null);
  }
}

class FakeCashRegisterRepository implements CashRegisterRepository {
  FakeCashRegisterRepository({required this.isOpen});

  final bool isOpen;

  @override
  Future<Result<CashSession>> closeSession(CloseCashSessionInput input) async =>
      const Failed<CashSession>(
        ConflictFailure(FailureCode.cashSessionNotOpen),
      );

  @override
  Future<Result<CashSession?>> getCurrentSession() async =>
      const Success<CashSession?>(null);

  @override
  Future<Result<bool>> hasOpenSession() async => Success<bool>(isOpen);

  @override
  Future<Result<CashSession>> openSession({
    required double openingAmount,
  }) async => const Failed<CashSession>(
    ConflictFailure(FailureCode.cashSessionNotOpen),
  );
}

RegisterSale buildUseCase({
  required FakeSalesRepository sales,
  required FakeProductRepository products,
  required bool isCashRegisterOpen,
}) {
  return RegisterSale(
    salesRepository: sales,
    productRepository: products,
    cashRegisterRepository: FakeCashRegisterRepository(
      isOpen: isCashRegisterOpen,
    ),
  );
}

void main() {
  group('RegisterSale', () {
    test('registers the sale and discounts the stock', () async {
      final FakeSalesRepository sales = FakeSalesRepository();
      final FakeProductRepository products = FakeProductRepository();
      final RegisterSale useCase = buildUseCase(
        sales: sales,
        products: products,
        isCashRegisterOpen: true,
      );

      final Result<Sale> result = await useCase(
        SaleDraft(
          cart: const Cart.empty().addProduct(_product),
          paymentMethod: PaymentMethod.cash,
          amountReceived: 500,
        ),
      );

      expect(result, isA<Success<Sale>>());
      expect(sales.registerCalls, 1);
      expect(products.movements, hasLength(1));
      expect(products.movements.first.productId, _product.id);
      expect(products.movements.first.quantity, 1);
      expect(result.valueOrNull!.change, 50);
    });

    test('discounts the stock of the sold variant', () async {
      final ProductVariant blackM = ProductVariant.fromValues(
        optionValues: const <String, String>{'Color': 'Negra', 'Talla': 'M'},
        stockQuantity: 4,
      );
      final Product tee = _product.copyWith(
        options: const <VariantOption>[
          VariantOption(name: 'Color', values: <String>['Negra']),
          VariantOption(name: 'Talla', values: <String>['M']),
        ],
        variants: <ProductVariant>[blackM],
      );
      final FakeProductRepository products = FakeProductRepository();
      final RegisterSale useCase = buildUseCase(
        sales: FakeSalesRepository(),
        products: products,
        isCashRegisterOpen: true,
      );

      await useCase(
        SaleDraft(
          cart: const Cart.empty().addProduct(
            tee,
            variant: blackM,
            quantity: 2,
          ),
          paymentMethod: PaymentMethod.qr,
          amountReceived: 900,
        ),
      );

      expect(products.movements.single.variantId, blackM.id);
      expect(products.movements.single.quantity, 2);
    });

    test('rejects the sale when the cash drawer is closed', () async {
      final FakeSalesRepository sales = FakeSalesRepository();
      final RegisterSale useCase = buildUseCase(
        sales: sales,
        products: FakeProductRepository(),
        isCashRegisterOpen: false,
      );

      final Result<Sale> result = await useCase(
        SaleDraft(
          cart: const Cart.empty().addProduct(_product),
          paymentMethod: PaymentMethod.cash,
          amountReceived: 450,
        ),
      );

      expect(result.failureOrNull, isA<ConflictFailure>());
      expect(sales.registerCalls, 0);
    });

    test('rejects an empty cart', () async {
      final RegisterSale useCase = buildUseCase(
        sales: FakeSalesRepository(),
        products: FakeProductRepository(),
        isCashRegisterOpen: true,
      );

      final Result<Sale> result = await useCase(
        const SaleDraft(
          cart: Cart.empty(),
          paymentMethod: PaymentMethod.cash,
          amountReceived: 0,
        ),
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('rejects cash below the total', () async {
      final RegisterSale useCase = buildUseCase(
        sales: FakeSalesRepository(),
        products: FakeProductRepository(),
        isCashRegisterOpen: true,
      );

      final Result<Sale> result = await useCase(
        SaleDraft(
          cart: const Cart.empty().addProduct(_product),
          paymentMethod: PaymentMethod.cash,
          amountReceived: 100,
        ),
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });
}
