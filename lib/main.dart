import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/fake_api_client.dart';

void main() => runApp(PhiusApp(api: FakeApiClient()));
