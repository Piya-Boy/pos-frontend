import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/app_error.dart';
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

  test(
    'staff login exposes seeded kitchen work and updates its status',
    () async {
      final api = FakeApiClient();

      final staff = await api.login(pin: 'zaq1234', expectedRole: 'KITCHEN');
      final before = await api.opsDashboard(
        token: staff.token,
        view: 'KITCHEN',
      );

      expect(staff.role, 'KITCHEN');
      expect(staff.token, isNotEmpty);
      expect(before.items, isNotEmpty);
      expect(before.items.first.status, 'NEW');

      await api.updateOrderItem(
        token: staff.token,
        orderItemId: before.items.first.orderItemId,
        status: 'PREPARING',
      );
      final after = await api.opsDashboard(token: staff.token, view: 'KITCHEN');

      expect(after.items.first.status, 'PREPARING');
    },
  );

  test('staff token is restricted to its permitted ops view', () async {
    final api = FakeApiClient();
    final kitchen = await api.login(pin: 'zaq1234', expectedRole: 'KITCHEN');

    expect(
      () => api.opsDashboard(token: kitchen.token, view: 'CASHIER'),
      throwsA(
        isA<AppError>().having(
          (error) => error.code,
          'code',
          'PERMISSION_DENIED',
        ),
      ),
    );
  });

  test(
    "changing a PIN enables the staff member's new fake credential",
    () async {
      final api = FakeApiClient();
      final first = await api.login(pin: 'zaq1234', expectedRole: 'KITCHEN');

      await api.changePin(token: first.token, newPin: 'kitchen01');
      await api.logout(token: first.token);

      final fallback = await api.login(pin: 'zaq1234', expectedRole: 'KITCHEN');
      final renewed = await api.login(
        pin: 'kitchen01',
        expectedRole: 'KITCHEN',
      );

      expect(fallback.role, 'ADMIN');
      expect(renewed.role, 'KITCHEN');
      expect(renewed.mustChangePin, isFalse);
    },
  );

  test(
    'paid fake sessions no longer appear in the cashier dashboard',
    () async {
      final api = FakeApiClient();
      final cashier = await api.login(pin: 'zaq1234', expectedRole: 'CASHIER');
      final before = await api.opsDashboard(
        token: cashier.token,
        view: 'CASHIER',
      );

      await api.closeTable(
        token: cashier.token,
        sessionId: before.sessions.single.session.sessionId,
        method: 'CASH',
        idempotencyKey: 'payment-1',
      );
      final after = await api.opsDashboard(
        token: cashier.token,
        view: 'CASHIER',
      );

      expect(after.sessions, isEmpty);
    },
  );
}
