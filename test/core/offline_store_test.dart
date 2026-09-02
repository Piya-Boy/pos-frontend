import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/core/offline/offline_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('catalog snapshot round-trips', () async {
    final store = OfflineStore('tbl_x');
    await store.cacheCatalog(
      {'menu': [], 'categories': [], 'promotions': []},
      {'app': {'name': 'Phius'}},
    );
    final cached = await store.readCatalog();
    expect(cached, isNotNull);
    expect(cached!.bootstrap['app']['name'], 'Phius');
  });

  test('readCatalog returns null when nothing cached', () async {
    expect(await OfflineStore('tbl_none').readCatalog(), isNull);
  });

  test('queued order round-trips and preserves idempotency key', () async {
    final store = OfflineStore('tbl_q');
    final order = QueuedOrder(
      idempotencyKey: 'order-abc',
      promoCode: 'WELCOME10',
      items: const [
        OrderRequestItem(itemId: 'M006', qty: 2, optionIds: ['o1'], addOnIds: [], note: 'less ice'),
      ],
    );
    await store.queueOrder(order);
    final back = await store.readQueued();
    expect(back!.idempotencyKey, 'order-abc');
    expect(back.promoCode, 'WELCOME10');
    expect(back.items.single.itemId, 'M006');
    expect(back.items.single.qty, 2);
    expect(back.items.single.optionIds, ['o1']);
    expect(back.items.single.note, 'less ice');
  });

  test('clearQueue removes the pending order', () async {
    final store = OfflineStore('tbl_c');
    await store.queueOrder(const QueuedOrder(idempotencyKey: 'k', promoCode: '', items: []));
    await store.clearQueue();
    expect(await store.readQueued(), isNull);
  });
}
