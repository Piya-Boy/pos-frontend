import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/staff/ops_page.dart';
import 'package:pos_frontend/state/auth_controller.dart';
import 'package:pos_frontend/state/ops_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('kitchen loads its board after first-login PIN change', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final api = FakeApiClient();
    final auth = AuthController(api: api, route: StaffRoute.kitchen);
    final controller = OpsController(api: api, token: '', view: 'KITCHEN');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(
          home: OpsPage(route: StaffRoute.kitchen, enablePolling: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'zaq1234');
    await tester.tap(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('ตั้ง PIN ใหม่'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'kitchen123');
    await tester.tap(find.widgetWithText(FilledButton, 'บันทึก PIN ใหม่'));
    await tester.pumpAndSettle();

    expect(controller.error, isNull);
    expect(find.text('ออเดอร์ใหม่'), findsOneWidget);
    expect(find.text('1 × กะเพราหมูสับ'), findsOneWidget);
    final summary = tester.widget<GridView>(find.byType(GridView).first);
    expect(
      (summary.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
          .crossAxisCount,
      4,
    );
  });

  testWidgets('operations dashboard renders summary cards and three tabs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final api = FakeApiClient();
    final auth = AuthController(api: api, route: StaffRoute.operations);
    await auth.login('zaq1234');
    await auth.changePin('admin123');
    final controller = OpsController(
      api: api,
      token: auth.session!.token,
      view: 'ALL',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(
          home: OpsPage(route: StaffRoute.operations, enablePolling: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('🍽️ โต๊ะเปิดอยู่'), findsOneWidget);
    expect(find.text('🔔 ออเดอร์ใหม่'), findsOneWidget);
    expect(find.text('🔥 กำลังทำ'), findsOneWidget);
    expect(find.text('🛎️ งานรอรับ'), findsOneWidget);
    expect(find.text('Small Team Operations'), findsOneWidget);
    expect(find.text('รวมงานหน้าร้าน'), findsOneWidget);
    expect(find.text('ผู้ดูแลระบบ'), findsOneWidget);
    expect(find.text('ครัว'), findsOneWidget);
    expect(find.text('พนักงาน'), findsOneWidget);
    expect(find.text('แคชเชียร์'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'ออกจากระบบ'));
    await tester.pumpAndSettle();

    expect(auth.session, isNull);
    expect(controller.polling, isFalse);
    expect(find.text('เข้าสู่ระบบ'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'admin123');
    await tester.tap(find.widgetWithText(FilledButton, 'เข้าสู่ระบบ'));
    await tester.pumpAndSettle();

    expect(controller.token, auth.session!.token);
    expect(find.text('Small Team Operations'), findsOneWidget);
  });

  testWidgets('stops polling while hidden and resumes it when enabled', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final api = FakeApiClient();
    final auth = AuthController(api: api, route: StaffRoute.operations);
    await auth.login('zaq1234');
    final controller = OpsController(
      api: api,
      token: auth.session!.token,
      view: 'ALL',
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider.value(value: controller),
        ],
        child: const MaterialApp(home: OpsPage(route: StaffRoute.operations)),
      ),
    );
    await tester.pumpAndSettle();

    expect(controller.polling, isTrue);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(controller.polling, isFalse);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.polling, isTrue);

    await auth.logout();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(controller.polling, isFalse);
  });
}
