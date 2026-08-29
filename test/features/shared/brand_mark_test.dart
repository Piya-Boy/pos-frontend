import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/features/shared/widgets/brand_mark.dart';

void main() {
  testWidgets('BrandMark shows logo text when no image', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: BrandMark(logoText: 'ผ'))),
    );

    expect(find.text('ผ'), findsOneWidget);
  });
}
