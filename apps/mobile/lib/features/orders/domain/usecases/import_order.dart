import 'dart:convert';

import '../../../../core/domain/payment_method.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/use_case.dart';
import '../../../../core/utils/result.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/product_repository.dart';
import '../../../online_store/domain/entities/store_settings.dart';
import '../../../online_store/domain/repositories/store_settings_repository.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// An order as the web catalog packs it into the link of its WhatsApp
/// message (`apps/web/src/features/ordering/domain/order-link.ts`).
final class OrderLinkPayload {
  const OrderLinkPayload({
    required this.storeSlug,
    required this.order,
    required this.webNumber,
  });

  final String storeSlug;

  /// Number and token are the POS's own; these are placeholders.
  final Order order;

  /// The number the customer saw on the web.
  final int webNumber;
}

/// Reads the `d` parameter of an import link. Version 1 is compact JSON in
/// base64url:
///
/// ```json
/// {"v":1,"s":"illimani-store","id":"…","n":1003,"t":"2026-10-10T15:20:00Z",
///  "f":"pickup","m":"qr","c":{"n":"Ana","p":"76543210","a":"","o":""},
///  "l":[["p-001","rojo/40",1,450,"Zapatillas urbanas","Rojo · 40"]]}
/// ```
abstract final class OrderLinkCodec {
  static const int version = 1;

  /// Finds the payload in a link, or in a whole pasted WhatsApp message.
  /// `null` when there is none or it can't be read.
  static OrderLinkPayload? decode(String text) {
    final RegExpMatch? match = RegExp(r'[?&]d=([A-Za-z0-9_-]+)')
        .firstMatch(text.trim());
    final String? data =
        match?.group(1) ??
        (RegExp(r'^[A-Za-z0-9_-]{20,}$').hasMatch(text.trim())
            ? text.trim()
            : null);
    if (data == null) return null;
    try {
      final Object? json = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(data))),
      );
      return _fromJson(json! as Map<String, Object?>);
    } on Object {
      return null;
    }
  }

  static String encode(OrderLinkPayload payload) {
    final Order order = payload.order;
    final Map<String, Object?> json = <String, Object?>{
      'v': version,
      's': payload.storeSlug,
      'id': order.id,
      'n': payload.webNumber,
      't': order.createdAt.toUtc().toIso8601String(),
      'f': order.fulfillment.name,
      'm': order.paymentMethod.name,
      'c': <String, Object?>{
        'n': order.customer.name,
        'p': order.customer.phone,
        'a': order.customer.address,
        'o': order.customer.note,
      },
      'l': <List<Object?>>[
        for (final OrderLine line in order.lines)
          <Object?>[
            line.productId,
            line.variantId ?? '',
            line.quantity,
            line.unitPrice,
            line.productName,
            line.variantLabel ?? '',
          ],
      ],
    };
    return base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  }

  static OrderLinkPayload? _fromJson(Map<String, Object?> json) {
    if (json['v'] != version) return null;
    final Map<String, Object?> customer = json['c']! as Map<String, Object?>;
    final Fulfillment fulfillment = Fulfillment.values.byName(
      json['f']! as String,
    );
    final PaymentMethod method = PaymentMethod.values.byName(
      json['m']! as String,
    );
    final List<OrderLine> lines = <OrderLine>[
      for (final Object? raw in json['l']! as List<Object?>)
        _line(raw! as List<Object?>),
    ];
    if (lines.isEmpty || lines.any((OrderLine line) => line.quantity <= 0)) {
      return null;
    }
    return OrderLinkPayload(
      storeSlug: json['s']! as String,
      webNumber: (json['n']! as num).toInt(),
      order: Order(
        id: json['id']! as String,
        number: 0,
        createdAt: DateTime.parse(json['t']! as String).toLocal(),
        status: OrderStatus.newOrder,
        fulfillment: fulfillment,
        customer: OrderCustomer(
          name: customer['n']! as String,
          phone: customer['p']! as String,
          address: (customer['a'] as String?) ?? '',
          note: (customer['o'] as String?) ?? '',
        ),
        paymentMethod: method,
        lines: lines,
        publicToken: '',
        source: OrderSource.whatsappImport,
      ),
    );
  }

  static OrderLine _line(List<Object?> raw) {
    final String variantId = raw[1]! as String;
    final String variantLabel = raw[5]! as String;
    return OrderLine(
      productId: raw[0]! as String,
      variantId: variantId.isEmpty ? null : variantId,
      quantity: (raw[2]! as num).toInt(),
      unitPrice: (raw[3]! as num).toDouble(),
      productName: raw[4]! as String,
      variantLabel: variantLabel.isEmpty ? null : variantLabel,
    );
  }
}

/// Loads an order from the link the web adds to its WhatsApp message, so
/// web orders reach the inbox while the API is not connected (feature 13).
/// The order must be for this store and its products must still exist.
final class ImportOrder implements UseCase<Order, String> {
  const ImportOrder({
    required OrderRepository orderRepository,
    required ProductRepository productRepository,
    required StoreSettingsRepository storeSettingsRepository,
  }) : _orderRepository = orderRepository,
       _productRepository = productRepository,
       _storeSettingsRepository = storeSettingsRepository;

  final OrderRepository _orderRepository;
  final ProductRepository _productRepository;
  final StoreSettingsRepository _storeSettingsRepository;

  /// [input] is the link, or the whole message that contains it.
  @override
  Future<Result<Order>> call(String input) async {
    final OrderLinkPayload? payload = OrderLinkCodec.decode(input);
    if (payload == null) {
      return const Failed<Order>(
        ValidationFailure(FailureCode.invalidOrderLink),
      );
    }

    final Result<StoreSettings> settings = await _storeSettingsRepository
        .getSettings();
    if (settings case Failed<StoreSettings>(:final Failure failure)) {
      return Failed<Order>(failure);
    }
    if (settings.valueOrNull!.slug != payload.storeSlug) {
      return const Failed<Order>(
        ConflictFailure(FailureCode.orderFromAnotherStore),
      );
    }

    for (final OrderLine line in payload.order.lines) {
      final Result<Product> product = await _productRepository.getProductById(
        line.productId,
      );
      final Product? found = product.valueOrNull;
      final bool exists =
          found != null &&
          (line.variantId == null ||
              found.variantById(line.variantId!) != null);
      if (!exists) {
        return Failed<Order>(
          NotFoundFailure(
            FailureCode.productNotFound,
            detail: line.productName,
          ),
        );
      }
    }
    return _orderRepository.importOrder(payload.order);
  }
}
