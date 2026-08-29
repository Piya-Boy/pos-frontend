import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/models/cart_line.dart';
import 'package:pos_frontend/state/customer_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('filteredMenu respects category + search', () async {
    final controller = CustomerController(api: FakeApiClient(), tableToken: 't');
    await controller.load();
    expect(controller.filteredMenu().length, 8);
    controller.setCategory('CAT_DRINK');
    expect(controller.filteredMenu().every((item) => item.categoryId == 'CAT_DRINK'), true);
    controller.setCategory('ALL');
    controller.setSearch('ผัดไทย');
    expect(controller.filteredMenu().any((item) => item.name.contains('ผัดไทย')), true);
  });

  test('addToCart + changeQty + subtotal', () async {
    final controller = CustomerController(api: FakeApiClient(), tableToken: 't');
    await controller.load();
    controller.addToCart(const CartLine(lineId: 'l1', itemId: 'M001', name: 'กะเพราหมูสับ', image: '', basePrice: 85, qty: 1, optionIds: [], addOnIds: [], options: [], addOns: [], note: '', unitPrice: 85));
    expect(controller.cartCount(), 1);
    controller.changeQty('l1', 1);
    expect(controller.cartSubtotal(), 170);
  });
}
