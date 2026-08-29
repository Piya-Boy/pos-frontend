import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';

void main() {
  test('getCustomerData returns seeded catalog', () async {
    final api = FakeApiClient();
    final data = await api.getCustomerData(tableToken: 'any');

    expect(data.menu.length, 8);
    expect(data.categories.length, 5);
    expect(data.menu.any((item) => item.name == 'กะเพราหมูสับ'), true);
    expect(data.promotions.single.code, 'WELCOME10');
  });

  test('submitOrder is idempotent per key', () async {
    final api = FakeApiClient();
    final items = [
      const OrderRequestItem(
        itemId: 'M001',
        qty: 2,
        optionIds: ['OPT002'],
        addOnIds: [],
        note: '',
      ),
    ];

    final first = await api.submitOrder(
      tableToken: 't',
      idempotencyKey: 'k1',
      promoCode: '',
      items: items,
    );
    final second = await api.submitOrder(
      tableToken: 't',
      idempotencyKey: 'k1',
      promoCode: '',
      items: items,
    );

    expect(first.sessionId, second.sessionId);
  });
}
