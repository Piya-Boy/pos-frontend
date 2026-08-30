import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/staff/widgets/staff_queue.dart';

void main() {
  testWidgets('staff queue renders an open call and ready item actions', (
    tester,
  ) async {
    final api = FakeApiClient();
    final staff = await api.login(pin: 'zaq1234', expectedRole: 'STAFF');
    final kitchen = await api.login(pin: 'zaq1234', expectedRole: 'KITCHEN');
    final before = await api.opsDashboard(token: staff.token, view: 'STAFF');
    await api.updateOrderItem(
      token: kitchen.token,
      orderItemId: before.items.single.orderItemId,
      status: 'READY',
    );
    final dashboard = await api.opsDashboard(token: staff.token, view: 'STAFF');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StaffQueue(
            calls: dashboard.calls,
            items: dashboard.items,
            onUpdateCall: (call, status) => api.updateCall(
              token: staff.token,
              logId: call.logId,
              status: status,
            ),
            onUpdateItem: (item, status) => api.updateOrderItem(
              token: staff.token,
              orderItemId: item.orderItemId,
              status: status,
            ),
          ),
        ),
      ),
    );

    expect(find.text('งานเรียกจากโต๊ะ'), findsOneWidget);
    expect(find.text('รับงานนี้'), findsOneWidget);
    expect(find.text('อาหารพร้อมเสิร์ฟ'), findsOneWidget);
    expect(find.text('ยืนยันว่าเสิร์ฟแล้ว'), findsOneWidget);
  });
}
