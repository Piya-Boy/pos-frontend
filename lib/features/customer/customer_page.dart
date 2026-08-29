import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pos_frontend/features/customer/widgets/item_detail_modal.dart';
import 'package:pos_frontend/features/customer/widgets/cart_bar.dart';
import 'package:pos_frontend/features/customer/widgets/cart_modal.dart';
import 'package:provider/provider.dart';
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/features/customer/widgets/customer_guide.dart';
import 'package:pos_frontend/features/customer/widgets/customer_header.dart';
import 'package:pos_frontend/features/customer/widgets/customer_hero.dart';
import 'package:pos_frontend/features/customer/widgets/promotion_strip.dart';
import 'package:pos_frontend/features/customer/widgets/menu_toolbar.dart';
import 'package:pos_frontend/features/customer/widgets/menu_section.dart';
import 'package:pos_frontend/features/shared/widgets/app_footer.dart';
import 'package:pos_frontend/state/customer_controller.dart';

final _trackingAnchorKey = GlobalKey();

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key, required this.api, required this.tableToken});
  final ApiClient api;
  final String tableToken;

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => CustomerController(api: api, tableToken: tableToken)..load(),
    child: Consumer<CustomerController>(
      builder: (context, controller, _) {
        final app = controller.app;
        final table = controller.data?.table;
        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final padding = constraints.maxWidth >= 900
                    ? 32.0
                    : constraints.maxWidth >= 640
                    ? 24.0
                    : 16.0;
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: Stack(
                      children: [
                        CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                padding,
                                padding,
                                padding,
                                0,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    CustomerHeader(
                                      name: app?.name ?? 'Phius Order',
                                      tagline: app?.tagline ?? '',
                                      tableName: '${table?['Name'] ?? ''}',
                                    ),
                                    const CustomerGuide(),
                                    CustomerHero(
                                      kicker:
                                          app?.heroKicker ??
                                          'อิ่มอร่อยในแบบของคุณ',
                                      title:
                                          app?.heroTitle ??
                                          'เลือกเมนูโปรด\nแล้วส่งตรงถึงครัว',
                                      badgeText: app?.heroBadgeText ?? 'อร่อย',
                                      badgeImageUrl:
                                          app?.heroBadgeImageUrl ?? '',
                                    ),
                                    PromotionStrip(
                                      promotions:
                                          controller.data?.promotions ??
                                          const [],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SliverPersistentHeader(
                              pinned: true,
                              delegate: _MenuToolbarDelegate(
                                padding: padding,
                                child: MenuToolbar(
                                  categories:
                                      controller.data?.categories ?? const [],
                                  activeCategory: controller.activeCategory,
                                  onSearch: controller.setSearch,
                                  onSelectCategory: controller.setCategory,
                                ),
                              ),
                            ),
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                padding,
                                20,
                                padding,
                                padding,
                              ),
                              sliver: SliverToBoxAdapter(
                                child: Column(
                                  children: [
                                    MenuSection(
                                      items: controller.filteredMenu(),
                                      onQuickAdd: (item) => openItemModal(
                                        context,
                                        item,
                                        controller,
                                      ),
                                    ),
                                    const AppFooter(),
                                    SizedBox(key: _trackingAnchorKey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        CartBar(
                          count: controller.cartCount(),
                          subtotal: controller.cartSubtotal(),
                          sessionCount: controller.session?.items.where((item) => item.status != 'CANCELLED').fold<int>(0, (total, item) => total + item.qty) ?? 0,
                          sessionTotal: controller.session?.session.total ?? 0,
                          onTap: () { if (controller.cart.isNotEmpty) { openCartModal(context, controller); } else if (_trackingAnchorKey.currentContext != null) { Scrollable.ensureVisible(_trackingAnchorKey.currentContext!); } },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    ),
  );
}

class _MenuToolbarDelegate extends SliverPersistentHeaderDelegate {
  _MenuToolbarDelegate({required this.padding, required this.child});

  final double padding;
  final Widget child;

  @override
  double get minExtent => 126;

  @override
  double get maxExtent => 126;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ClipRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: .9),
        padding: EdgeInsets.fromLTRB(padding, 8, padding, 10),
        child: child,
      ),
    ),
  );

  @override
  bool shouldRebuild(covariant _MenuToolbarDelegate oldDelegate) =>
      oldDelegate.padding != padding || oldDelegate.child != child;
}
