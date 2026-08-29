import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/features/customer/customer_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('renders restaurant name + guide steps', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CustomerPage(api: FakeApiClient(), tableToken: 't')));
    await tester.pumpAndSettle();
    expect(find.text('วิธีสั่งอาหาร'), findsOneWidget);
    expect(find.textContaining('เลือกเมนูโปรด'), findsOneWidget);
  });
}
