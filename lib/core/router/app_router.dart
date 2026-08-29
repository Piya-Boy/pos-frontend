import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/api_client.dart';
import '../../features/customer/customer_page.dart';
import '../../features/home/home_page.dart';

GoRouter appRouter(ApiClient api) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => _routeFor(
        api,
        state.uri.queryParameters['page'] ?? 'home',
        state.uri.queryParameters['table'] ?? '',
      ),
    ),
  ],
);

Widget _routeFor(ApiClient api, String page, String table) => switch (page) {
  'order' => CustomerPage(api: api, tableToken: table),
  _ => HomePage(api: api),
};
