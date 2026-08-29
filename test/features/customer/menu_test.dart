import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';
import 'package:pos_frontend/features/customer/widgets/menu_section.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('menu shows count and food cards', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('8 เมนู'), findsOneWidget);
    expect(find.text('กะเพราหมูสับ'), findsWidgets);
  });

  test('menuColumns breakpoints', () {
    expect(menuColumns(400), 2);
    expect(menuColumns(700), 3);
    expect(menuColumns(1000), 4);
  });
}
