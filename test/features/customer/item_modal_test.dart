import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('quick-add opens modal with options + live total', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
    ));
    await tester.pumpAndSettle();
    // M001 กะเพราหมูสับ has required RADIO group ระดับความเผ็ด
    final finder = find.byTooltip('เลือก กะเพราหมูสับ').first;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(find.text('ระดับความเผ็ด'), findsOneWidget);
    expect(find.textContaining('เพิ่มลงตะกร้า'), findsOneWidget);
  });
}
