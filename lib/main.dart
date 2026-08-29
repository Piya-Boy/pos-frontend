import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/api_client_factory.dart';

void main() => runApp(PhiusApp(api: buildApiClient()));
