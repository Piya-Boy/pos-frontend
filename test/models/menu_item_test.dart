import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/menu_item.dart';

void main() {
  test('MenuItem.fromJson maps sheet headers + nested', () {
    final item = MenuItem.fromJson({
      'ItemID': 'M001',
      'CategoryID': 'CAT_RICE',
      'Name': 'กะเพราหมูสับ',
      'Price': 85,
      'IsPopular': true,
      'available': true,
      'options': [
        {
          'OptionID': 'OPT001',
          'ItemID': 'M001',
          'GroupName': 'ระดับความเผ็ด',
          'Label': 'ไม่เผ็ด',
          'Price': 0,
          'InputType': 'RADIO',
          'IsRequired': true,
        },
      ],
      'addOns': [
        {'AddOnID': 'ADD001', 'Name': 'ไข่ดาว', 'Price': 15},
      ],
    });

    expect(item.itemId, 'M001');
    expect(item.name, 'กะเพราหมูสับ');
    expect(item.price, 85);
    expect(item.isPopular, true);
    expect(item.available, true);
    expect(item.options.single.groupName, 'ระดับความเผ็ด');
    expect(item.addOns.single.price, 15);
  });
}
