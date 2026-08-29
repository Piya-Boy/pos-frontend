import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/features/customer/widgets/customer_guide.dart';
import 'package:pos_frontend/features/customer/widgets/customer_header.dart';
import 'package:pos_frontend/features/customer/widgets/customer_hero.dart';
import 'package:pos_frontend/features/shared/widgets/app_footer.dart';
import 'package:pos_frontend/state/customer_controller.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key, required this.api, required this.tableToken});
  final ApiClient api;
  final String tableToken;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CustomerController(api: api, tableToken: tableToken)..load(),
    child: Consumer<CustomerController>(builder: (context, controller, _) {
      final app = controller.app;
      final table = controller.data?.table;
      return Scaffold(body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        final padding = constraints.maxWidth >= 900 ? 32.0 : constraints.maxWidth >= 640 ? 24.0 : 16.0;
        return Center(child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Stack(children: [
            SingleChildScrollView(padding: EdgeInsets.all(padding), child: Column(children: [
              CustomerHeader(name: app?.name ?? 'Phius Order', tagline: app?.tagline ?? '', tableName: '${table?['Name'] ?? ''}'),
              const CustomerGuide(),
              CustomerHero(kicker: app?.heroKicker ?? 'อิ่มอร่อยในแบบของคุณ', title: app?.heroTitle ?? 'เลือกเมนูโปรด\nแล้วส่งตรงถึงครัว', badgeText: app?.heroBadgeText ?? 'อร่อย', badgeImageUrl: app?.heroBadgeImageUrl ?? ''),
              const AppFooter(),
            ])),
            const SizedBox.shrink(),
          ]),
        ));
      })));
    }),
  );
}
