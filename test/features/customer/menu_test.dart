import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/features/customer/widgets/menu_toolbar.dart';
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

  testWidgets('search field has the cp-pos radius and shadow wrapper', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MenuToolbar(
            categories: const [],
            activeCategory: 'ALL',
            onSearch: (_) {},
            onSelectCategory: (_) {},
          ),
        ),
      ),
    );

    final decoration = tester.widget<TextField>(find.byType(TextField)).decoration!;
    expect(decoration.enabledBorder, isA<OutlineInputBorder>());
    expect(
      (decoration.enabledBorder! as OutlineInputBorder).borderRadius,
      const BorderRadius.all(Radius.circular(16)),
    );
    expect(
      decoration.prefixIconConstraints,
      const BoxConstraints.tightFor(width: 44, height: 46),
    );
    final wrapper = find.ancestor(
      of: find.byType(TextField),
      matching: find.byType(DecoratedBox),
    );
    expect(wrapper, findsOneWidget);
    expect(
      (tester.widget<DecoratedBox>(wrapper).decoration as BoxDecoration)
          .boxShadow,
      PhiusTokens.shadowSm,
    );
  });
}
