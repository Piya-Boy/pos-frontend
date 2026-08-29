import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app.dart';
import 'core/api/api_client_factory.dart';

void main() {
  // Use `/?page=..&table=..` path URLs (no `#`), matching the original
  // Apps Script deep links from table QR codes.
  usePathUrlStrategy();
  runApp(PhiusApp(api: buildApiClient()));
}
