import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_client.dart';
import '../../features/customer/customer_page.dart';
import '../../features/admin/admin_page.dart';
import '../../features/home/home_page.dart';
import '../../features/staff/ops_page.dart';
import '../../state/auth_controller.dart';
import '../../state/admin_controller.dart';
import '../../state/ops_controller.dart';

import 'package:provider/provider.dart';

GoRouter appRouter(ApiClient api) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // On Flutter web the query string can live before the hash (`/?page=..`),
        // which go_router's `state.uri` may not carry on first load. Fall back to
        // the real browser URL so `?page=order&table=..` (QR deep link) works.
        final q = {...Uri.base.queryParameters, ...state.uri.queryParameters};
        return _routeFor(api, q['page'] ?? 'home', q['table'] ?? '');
      },
    ),
    GoRoute(
      path: '/kitchen',
      builder: (_, _) => _opsRoute(api, StaffRoute.kitchen, 'KITCHEN'),
    ),
    GoRoute(
      path: '/staff',
      builder: (_, _) => _opsRoute(api, StaffRoute.staff, 'STAFF'),
    ),
    GoRoute(
      path: '/cashier',
      builder: (_, _) => _opsRoute(api, StaffRoute.cashier, 'CASHIER'),
    ),
    GoRoute(path: '/admin', builder: (_, _) => _adminRoute(api)),
  ],
);

Widget _routeFor(ApiClient api, String page, String table) => switch (page) {
  'order' => CustomerPage(api: api, tableToken: table),
  'kitchen' => _opsRoute(api, StaffRoute.kitchen, 'KITCHEN'),
  'staff' => _opsRoute(api, StaffRoute.staff, 'STAFF'),
  'cashier' => _opsRoute(api, StaffRoute.cashier, 'CASHIER'),
  'admin' => _adminRoute(api),
  _ => HomePage(api: api),
};

Widget _opsRoute(ApiClient api, StaffRoute route, String view) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthController(api: api, route: route),
    ),
    ChangeNotifierProvider(
      create: (_) => OpsController(api: api, token: '', view: view),
    ),
  ],
  child: OpsPage(route: route),
);

Widget _adminRoute(ApiClient api) => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthController(api: api, route: StaffRoute.admin),
    ),
    ChangeNotifierProvider(
      create: (_) => AdminController(api: api, token: ''),
    ),
  ],
  child: const AdminPage(),
);
