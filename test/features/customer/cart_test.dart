import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('add item then cart bar appears and opens cart', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -850));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('เลือก ชาไทยเย็น').first);
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('เพิ่มลงตะกร้า'));
    await tester.pumpAndSettle();
    expect(find.text('ดูตะกร้า →'), findsOneWidget);

    await tester.tap(find.text('ดูตะกร้า →'));
    await tester.pumpAndSettle();
    expect(find.text('ตะกร้าของคุณ'), findsOneWidget);
    expect(find.text('ยืนยันการสั่งอาหาร'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
}
