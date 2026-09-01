import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

Future<void> _openFirstItem(WidgetTester tester) async {
  await tester.pumpWidget(MaterialApp(
    home: CustomerPage(api: FakeApiClient(), tableToken: 't'),
  ));
  await tester.pumpAndSettle();
  // M001 กะเพราหมูสับ, first card, has required RADIO group ระดับความเผ็ด
  await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('เลือก กะเพราหมูสับ').first,
      warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('quick-add opens modal with options + live total', (tester) async {
    await _openFirstItem(tester);
    expect(find.text('ระดับความเผ็ด'), findsOneWidget);
    expect(find.textContaining('เพิ่มลงตะกร้า'), findsOneWidget);
  });

  testWidgets('modal has header, item image and price (parity F7)', (tester) async {
    await _openFirstItem(tester);
    // sticky header title (cp-pos "รายละเอียดเมนู")
    expect(find.text('รายละเอียดเมนู'), findsOneWidget);
    // large item image at the top
    expect(find.byType(CachedNetworkImage), findsWidgets);
    // price shown in the title row (M001 = ฿85)
    expect(find.textContaining('฿85'), findsWidgets);
  });
}
