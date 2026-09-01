import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/app.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';

void main() {
  testWidgets('root route renders the Phius Order portal', (tester) async {
    await tester.pumpWidget(PhiusApp(api: FakeApiClient()));
    await tester.pumpAndSettle();

    expect(find.text('Phius Order'), findsOneWidget);
    expect(find.text('Phius Thai Kitchen'), findsOneWidget);
    expect(find.text('รวมงานหน้าร้าน'), findsOneWidget);
    expect(find.text('หน้าลูกค้าต้องเปิดผ่าน QR ประจำโต๊ะ'), findsOneWidget);
  });

  testWidgets('kitchen portal link opens the guarded kitchen screen', (
    tester,
  ) async {
    await tester.pumpWidget(PhiusApp(api: FakeApiClient()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('หน้าครัว'));
    await tester.pumpAndSettle();

    expect(find.text('Kitchen Display System'), findsOneWidget);
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);

    await tester.tap(find.text('กลับหน้าหลัก'));
    await tester.pumpAndSettle();

    expect(find.text('Phius Order'), findsOneWidget);
  });

  testWidgets('every staff portal card opens its guarded path route', (
    tester,
  ) async {
    const expectations = {
      'รวมงานหน้าร้าน': 'Small Team Operations',
      'หน้าครัว': 'Kitchen Display System',
      'พนักงาน': 'Service Queue',
      'แคชเชียร์': 'Billing & Checkout',
      'ผู้ดูแล': 'เข้าสู่ระบบ',
    };

    for (final expectation in expectations.entries) {
      await tester.pumpWidget(PhiusApp(api: FakeApiClient()));
      await tester.pumpAndSettle();
      final portalCard = find.text(expectation.key);
      await tester.ensureVisible(portalCard);
      await tester.tap(portalCard);
      await tester.pumpAndSettle();

      expect(find.text(expectation.value), findsOneWidget);
      expect(find.text('เข้าสู่ระบบ'), findsOneWidget);
    }
  });

  testWidgets('setup-required bootstrap does not expose the portal', (
    tester,
  ) async {
    await tester.pumpWidget(PhiusApp(api: _SetupRequiredApi()));
    await tester.pumpAndSettle();

    expect(find.text('Phius Order ยังไม่พร้อมใช้งาน'), findsOneWidget);
    expect(find.text('รวมงานหน้าร้าน'), findsNothing);
  });

  testWidgets('bootstrap failure exposes retry state instead of the portal', (
    tester,
  ) async {
    await tester.pumpWidget(PhiusApp(api: _FailingBootstrapApi()));
    await tester.pumpAndSettle();

    expect(find.text('ไม่สามารถเปิดระบบ'), findsOneWidget);
    expect(find.text('ลองอีกครั้ง'), findsOneWidget);
    expect(find.text('รวมงานหน้าร้าน'), findsNothing);
  });
}

class _SetupRequiredApi extends FakeApiClient {
  @override
  Future<Map<String, dynamic>> bootstrap({required String tableToken}) async =>
      {'setupRequired': true};
}

class _FailingBootstrapApi extends FakeApiClient {
  @override
  Future<Map<String, dynamic>> bootstrap({required String tableToken}) =>
      Future.error(StateError('offline'));
}
