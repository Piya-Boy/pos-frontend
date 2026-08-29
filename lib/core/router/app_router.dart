import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_client.dart';
import '../../features/customer/customer_page.dart';
import '../../features/home/home_page.dart';

GoRouter appRouter(ApiClient api) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // On Flutter web the query string can live before the hash (`/?page=..`),
        // which go_router's `state.uri` may not carry on first load. Fall back to
        // the real browser URL so `?page=order&table=..` (QR deep link) works.
        final q = {
          ...Uri.base.queryParameters,
          ...state.uri.queryParameters,
        };
        return _routeFor(api, q['page'] ?? 'home', q['table'] ?? '');
      },
    ),
  ],
);

Widget _routeFor(ApiClient api, String page, String table) => switch (page) {
  'order' => CustomerPage(api: api, tableToken: table),
  _ => HomePage(api: api),
};
