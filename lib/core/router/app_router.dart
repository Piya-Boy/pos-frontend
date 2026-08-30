import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_client.dart';
import '../../features/customer/customer_page.dart';
import '../../features/home/home_page.dart';
import '../../features/staff/ops_page.dart';
import '../../state/auth_controller.dart';
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
  ],
);

Widget _routeFor(ApiClient api, String page, String table) => switch (page) {
  'order' => CustomerPage(api: api, tableToken: table),
  'kitchen' => _opsRoute(api, StaffRoute.kitchen, 'KITCHEN'),
  'staff' => _opsRoute(api, StaffRoute.staff, 'STAFF'),
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
