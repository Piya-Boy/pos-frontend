import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/admin/admin_page.dart';
import 'package:pos_frontend/state/admin_controller.dart';
import 'package:pos_frontend/state/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('admin shell renders all navigation items and overview metrics', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final api = FakeApiClient();
    final auth = AuthController(api: api, route: StaffRoute.admin);
    await auth.login('zaq1234');
    await auth.changePin('admin123');
    final controller = AdminController(api: api, token: auth.session!.token);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(home: AdminPage(enablePolling: false)),
      ),
    );
    await tester.pumpAndSettle();

    for (final label in const [
      'ภาพรวม',
      'โต๊ะและ QR',
      'เมนูอาหาร',
      'โปรโมชั่น',
      'พนักงาน',
      'ตั้งค่าร้าน',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('โต๊ะทั้งหมด'), findsOneWidget);
    expect(find.text('รอบโต๊ะที่เปิด'), findsOneWidget);
    expect(find.text('รายการเมนู'), findsOneWidget);
    expect(find.text('ยอดขายวันนี้'), findsOneWidget);
  });

  testWidgets('mobile admin shell exposes navigation from its menu toggle', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final api = FakeApiClient();
    final auth = AuthController(api: api, route: StaffRoute.admin);
    await auth.login('zaq1234');
    await auth.changePin('admin123');
    final controller = AdminController(api: api, token: auth.session!.token);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(home: AdminPage(enablePolling: false)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('โต๊ะและ QR'), findsNothing);
    await tester.tap(find.byTooltip('เปิดเมนู'));
    await tester.pumpAndSettle();
    expect(find.text('โต๊ะและ QR'), findsOneWidget);
  });
}
