import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/api/api_client_factory.dart';
import 'package:pos_frontend/core/api/fake_api_client.dart';
import 'package:pos_frontend/core/api/http_api_client.dart';

void main() {
  test('selects FakeApiClient without a base URL', () {
    expect(buildApiClient(baseUrl: ''), isA<FakeApiClient>());
  });

  test('selects HttpApiClient with a base URL', () {
    expect(
      buildApiClient(baseUrl: 'http://localhost:8000'),
      isA<HttpApiClient>(),
    );
  });
}
