import 'package:cumavi_pos_mobile/core/error/failure.dart';
import 'package:cumavi_pos_mobile/core/utils/result.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/entities/receipt_share_target.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/services/receipt_sharer.dart';
import 'package:cumavi_pos_mobile/features/sales/domain/usecases/share_receipt.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fake_receipt_services.dart';
import '../../../../helpers/sales_fixtures.dart';

void main() {
  late FakeReceiptSharer sharer;
  late ShareReceipt shareReceipt;

  setUp(() {
    sharer = FakeReceiptSharer();
    shareReceipt = ShareReceipt(sharer);
  });

  test('rejects an invalid WhatsApp number without sharing', () async {
    final Result<void> result = await shareReceipt(
      ReceiptShareRequest(
        receipt: sampleReceipt,
        target: const WhatsAppShareTarget('1234'),
      ),
    );

    expect(
      result,
      isA<Failed<void>>().having(
        (Failed<void> failed) => failed.failure,
        'failure',
        isA<ValidationFailure>(),
      ),
    );
    expect(sharer.requests, isEmpty);
  });

  test('shares to a valid WhatsApp number', () async {
    final ReceiptShareRequest request = ReceiptShareRequest(
      receipt: sampleReceipt,
      target: const WhatsAppShareTarget('765 43210'),
    );

    expect(await shareReceipt(request), isA<Success<void>>());
    expect(sharer.requests, <ReceiptShareRequest>[request]);
  });

  test('shares to destinations that need no phone number', () async {
    final ReceiptShareRequest request = ReceiptShareRequest(
      receipt: sampleReceipt,
      target: const SystemShareTarget(),
    );

    expect(await shareReceipt(request), isA<Success<void>>());
    expect(sharer.requests, hasLength(1));
  });
}
