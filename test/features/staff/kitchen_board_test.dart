import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/staff/widgets/kitchen_board.dart';

void main() {
  testWidgets('new kitchen item moves to preparing after starting it', (
    tester,
  ) async {
    final api = FakeApiClient();
    final kitchen = await api.login(pin: 'zaq1234', expectedRole: 'KITCHEN');
    final dashboard = await api.opsDashboard(
      token: kitchen.token,
      view: 'KITCHEN',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: KitchenBoard(
            items: dashboard.items,
            onUpdateStatus: (item, status) => api.updateOrderItem(
              token: kitchen.token,
              orderItemId: item.orderItemId,
              status: status,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(dashboard.items.single.order.itemName, 'กะเพราหมูสับ');
    expect(dashboard.items.single.status, 'NEW');
    expect(find.text('ออเดอร์ใหม่'), findsOneWidget);
    expect(find.text('1 × กะเพราหมูสับ'), findsOneWidget);
    expect(find.text('เริ่มทำ'), findsOneWidget);

    await tester.tap(find.text('เริ่มทำ'));
    await tester.pumpAndSettle();
    final updated = await api.opsDashboard(
      token: kitchen.token,
      view: 'KITCHEN',
    );

    expect(updated.items.single.status, 'PREPARING');
  });
}
