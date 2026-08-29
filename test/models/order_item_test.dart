import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/order_item.dart';

void main() {
  test('OrderItem writes parsed selections back to sheet JSON headers', () {
    const item = OrderItem(
      orderItemId: 'ord_001',
      sessionId: 'ses_001',
      itemId: 'M001',
      itemName: 'กะเพราหมูสับ',
      qty: 1,
      unitPrice: 85,
      lineTotal: 85,
      note: '',
      status: 'NEW',
      options: [
        {'id': 'OPT002', 'label': 'เผ็ดปกติ', 'price': 0},
      ],
      addOns: [
        {'id': 'ADD001', 'name': 'ไข่ดาว', 'price': 15},
      ],
    );

    final json = item.toJson();
    expect(json['OptionsJSON'], isA<String>());
    expect(json['AddOnsJSON'], isA<String>());
  });
}
