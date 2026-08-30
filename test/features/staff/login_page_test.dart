import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/staff/login_page.dart';
import 'package:pos_frontend/state/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('kitchen login stores only its token and completes PIN change', (
    tester,
  ) async {
    final controller = AuthController(
      api: FakeApiClient(),
      route: StaffRoute.kitchen,
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          home: LoginPage(
            onAuthenticated: () => const Text('kitchen-authorized'),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'zaq1234');
    await tester.tap(find.text('เข้าสู่ระบบ'));
    await tester.pumpAndSettle();
    expect(find.text('ตั้ง PIN ใหม่'), findsOneWidget);
    expect(find.text('กลับหน้าหลัก'), findsNothing);
    final preferencesBeforeChange = await SharedPreferences.getInstance();
    expect(preferencesBeforeChange.getString('pos-auth-kitchen'), isNull);

    await tester.enterText(find.byType(TextFormField), 'zaq1234');
    await tester.tap(find.text('บันทึก PIN ใหม่'));
    await tester.pumpAndSettle();
    expect(find.text('กรุณาตั้ง PIN ใหม่ที่ไม่ใช่รหัสเริ่มต้น'), findsWidgets);

    await tester.enterText(find.byType(TextFormField), 'kitchen01');
    await tester.tap(find.text('บันทึก PIN ใหม่'));
    await tester.pumpAndSettle();

    expect(find.text('kitchen-authorized'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('pos-auth-kitchen'), isNotEmpty);
    expect(preferences.getString('pos-auth-kitchen-pin'), isNull);
  });
}
