import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/admin/admin_page.dart';
import 'package:pos_frontend/features/admin/widgets/admin_catalog.dart';
import 'package:pos_frontend/features/admin/widgets/admin_settings.dart';
import 'package:pos_frontend/features/admin/widgets/admin_tables.dart';
import 'package:pos_frontend/state/admin_controller.dart';
import 'package:pos_frontend/state/auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('admin shell renders all navigation items and overview metrics', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 800));
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

  testWidgets(
    'admin overview keeps metrics compact in four columns on wide screens',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 800));
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

      final grid = tester.widget<GridView>(find.byType(GridView));
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, 4);
      expect(delegate.mainAxisExtent, 140);
    },
  );

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

  testWidgets('catalog renders menu and saves a new category', (tester) async {
    final api = FakeApiClient();
    final admin = await api.login(pin: 'zaq1234', expectedRole: 'ADMIN');
    final controller = AdminController(api: api, token: admin.token);
    await controller.load();
    final data = controller.data!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminCatalog(
            categories: data.entity('Categories'),
            menu: data.entity('MenuItems'),
            options: data.entity('Options'),
            addOns: data.entity('AddOns'),
            controller: controller,
          ),
        ),
      ),
    );
    expect(find.text('กะเพราหมูสับ'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'เพิ่มข้อมูล').first);
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'ของหวาน');
    await tester.enterText(fields.at(1), '🍰');
    await tester.enterText(fields.at(2), '9');
    await tester.tap(find.byKey(const Key('admin-field-Status')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ACTIVE').last);
    await tester.pumpAndSettle();
    final saveButton = find.widgetWithText(FilledButton, 'บันทึกข้อมูล');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(
      controller.data!
          .entity('Categories')
          .any((row) => row['Name'] == 'ของหวาน'),
      isTrue,
    );
  });

  testWidgets('catalog shows the category archive guard message', (
    tester,
  ) async {
    final api = FakeApiClient();
    final admin = await api.login(pin: 'zaq1234', expectedRole: 'ADMIN');
    final controller = AdminController(api: api, token: admin.token);
    await controller.load();
    final data = controller.data!;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminCatalog(
            categories: data.entity('Categories'),
            menu: data.entity('MenuItems'),
            options: data.entity('Options'),
            addOns: data.entity('AddOns'),
            controller: controller,
          ),
        ),
      ),
    );

    await tester.tap(find.widgetWithText(TextButton, 'ปิดรายการ').first);
    await tester.pumpAndSettle();

    expect(
      find.text('ย้ายหรือลบเมนูในหมวดนี้ก่อน แล้วจึงลบหมวดหมู่'),
      findsOneWidget,
    );
  });

  testWidgets('tables render an order URL and can display its QR details', (
    tester,
  ) async {
    final api = FakeApiClient();
    final admin = await api.login(pin: 'zaq1234', expectedRole: 'ADMIN');
    final controller = AdminController(api: api, token: admin.token);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminTables(
            rows: controller.data!.entity('Tables'),
            controller: controller,
          ),
        ),
      ),
    );
    await tester.tap(find.widgetWithText(TextButton, 'ดู QR'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('table=tbl_demo'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('settings update the live brand preview before saving', (
    tester,
  ) async {
    final api = FakeApiClient();
    final admin = await api.login(pin: 'zaq1234', expectedRole: 'ADMIN');
    final controller = AdminController(api: api, token: admin.token);
    await controller.load();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AdminSettings(
            settings: controller.data!.settings,
            controller: controller,
          ),
        ),
      ),
    );

    expect(find.text('แบรนด์และหน้าตาร้าน'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('settings-PrimaryColor')),
      '#2F6B4F',
    );
    await tester.pump();

    final preview = tester.widget<Container>(
      find.byKey(const Key('brand-preview')),
    );
    expect(
      (preview.decoration as BoxDecoration).color,
      const Color(0xFF2F6B4F),
    );
  });
}
