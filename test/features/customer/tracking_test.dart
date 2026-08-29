import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';
import 'package:pos_frontend/features/customer/widgets/bill_status_banner.dart';
import 'package:pos_frontend/features/customer/widgets/order_tracking_section.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('empty tracking and service actions render', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await tester.pumpAndSettle();

    expect(find.text('พร้อมรับออเดอร์'), findsOneWidget);
    expect(find.text('เรียกพนักงาน'), findsOneWidget);
    expect(find.text('เรียกเก็บเงิน'), findsOneWidget);
  });

  testWidgets('bill request without a session explains why it cannot be sent', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrderTrackingSection(
            session: null,
            paymentComplete: false,
            onRefresh: () async {},
            onCallStaff: (_) async => throw StateError('NO_SESSION'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('เรียกเก็บเงิน'));
    await tester.pump();
    expect(find.text('ยังไม่มีออเดอร์สำหรับเรียกเก็บเงิน'), findsOneWidget);
  });

  test('open BILL call makes the session bill pending', () async {
    final api = FakeApiClient();
    final submission = await api.submitOrder(
      tableToken: 't',
      idempotencyKey: 'submit-1',
      promoCode: '',
      items: const [
        OrderRequestItem(
          itemId: 'M002',
          qty: 1,
          optionIds: [],
          addOnIds: [],
          note: '',
        ),
      ],
    );

    await api.callStaff(
      tableToken: 't',
      type: 'BILL',
      idempotencyKey: 'call-1',
    );

    final bundle = await api.getOrderStatus(
      tableToken: 't',
      sessionId: submission.sessionId,
    );
    expect(isBillPending(bundle), isTrue);
  });

  testWidgets('bill request shows the pending banner and disables its action', (
    tester,
  ) async {
    final api = FakeApiClient();
    final submission = await api.submitOrder(
      tableToken: 't',
      idempotencyKey: 'submit-2',
      promoCode: '',
      items: const [
        OrderRequestItem(
          itemId: 'M002',
          qty: 1,
          optionIds: [],
          addOnIds: [],
          note: '',
        ),
      ],
    );
    SharedPreferences.setMockInitialValues({
      'phius-session-t': submission.sessionId,
    });

    await tester.pumpWidget(
      MaterialApp(
        home: CustomerPage(api: api, tableToken: 't'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -2000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('เรียกเก็บเงิน'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('เรียกเก็บเงิน'));
    await tester.pumpAndSettle();

    expect(find.text('เรียกเก็บเงินแล้ว'), findsNWidgets(2));
    final billButton = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('เรียกเก็บเงินแล้ว').first,
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(billButton.onPressed, isNull);
  });
}
