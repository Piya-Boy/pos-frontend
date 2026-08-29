import 'package:flutter/material.dart';

import 'core/api/fake_api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/phius_theme.dart';

class PhiusApp extends StatelessWidget {
  PhiusApp({super.key, ApiClient? api}) : _api = api ?? FakeApiClient();

  final ApiClient _api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Phius Order',
      debugShowCheckedModeBanner: false,
      theme: phiusTheme(),
      routerConfig: appRouter(_api),
    );
  }
}
