import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/staff/widgets/cashier_bills.dart';
import 'package:pos_frontend/models/staff_models.dart';

void main() {
  testWidgets('cashier collects payment once and shows its receipt', (
    tester,
  ) async {
    final api = FakeApiClient();
    final cashier = await api.login(pin: 'zaq1234', expectedRole: 'CASHIER');
    final dashboard = await api.opsDashboard(
      token: cashier.token,
      view: 'CASHIER',
    );
    final idempotencyKeys = <String>[];

    Future<Receipt> close(
      OpsSession session,
      String method,
      String reference,
      String idempotencyKey,
    ) {
      idempotencyKeys.add(idempotencyKey);
      return api.closeTable(
        token: cashier.token,
        sessionId: session.session.sessionId,
        method: method,
        reference: reference,
        idempotencyKey: idempotencyKey,
      );
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CashierBills(sessions: dashboard.sessions, onClose: close),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'ตรวจบิล'));
    await tester.pumpAndSettle();
    expect(find.text('วิธีชำระเงิน'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'รับชำระเงินและรีเซตโต๊ะ'),
    );
    await tester.pumpAndSettle();
    expect(find.text('กรุณาเลือกวิธีชำระเงิน'), findsOneWidget);

    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('เงินสด').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'CASH-001');
    await tester.tap(
      find.widgetWithText(FilledButton, 'รับชำระเงินและรีเซตโต๊ะ'),
    );
    await tester.pumpAndSettle();
    expect(find.text('ยืนยันการปิดโต๊ะ?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'ยืนยันรับชำระ'));
    await tester.pumpAndSettle();

    expect(idempotencyKeys, hasLength(1));
    expect(idempotencyKeys.single, startsWith('pay_'));
    expect(find.text('✓ โต๊ะพร้อมรับลูกค้ารอบใหม่'), findsOneWidget);
    expect(find.text('พิมพ์ใบเสร็จ'), findsOneWidget);
  });
}
