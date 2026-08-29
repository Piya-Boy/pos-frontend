import 'package:pos_frontend/core/api/api_config.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/core/api/http_api_client.dart';

ApiClient buildApiClient({String? baseUrl}) {
  final resolvedBaseUrl = (baseUrl ?? ApiConfig.baseUrl).trim();
  return resolvedBaseUrl.isEmpty
      ? FakeApiClient()
      : HttpApiClient(baseUrl: resolvedBaseUrl);
}
