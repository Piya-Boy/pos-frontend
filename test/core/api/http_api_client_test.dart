import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pos_frontend/core/api/app_error.dart';
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/core/api/http_api_client.dart';

void main() {
  test('bootstrap unwraps an ok envelope', () async {
    final mock = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/bootstrap');
      expect(request.headers['accept'], 'application/json');
      expect(request.headers['content-type'], 'application/json');
      expect(jsonDecode(request.body), {'tableToken': 'table-token'});
      return http.Response(
        jsonEncode({
          'ok': true,
          'data': {
            'app': {'name': 'X'},
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final api = HttpApiClient(baseUrl: 'https://api.test/', client: mock);

    final data = await api.bootstrap(tableToken: 'table-token');

    expect(data['app']['name'], 'X');
  });

  test('error envelope throws AppError', () async {
    final mock = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'ok': false,
          'error': {'code': 'TABLE_NOT_FOUND', 'message': 'no'},
        }),
        200,
      ),
    );
    final api = HttpApiClient(baseUrl: 'https://api.test', client: mock);

    expect(
      () => api.getCustomerData(tableToken: 'x'),
      throwsA(
        isA<AppError>().having(
          (error) => error.code,
          'code',
          'TABLE_NOT_FOUND',
        ),
      ),
    );
  });

  test('non-success HTTP response preserves API error details', () async {
    final mock = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'ok': false,
          'error': {
            'code': 'INVALID_ORDER',
            'message': 'bad order',
            'details': {'itemId': 'M1'},
          },
        }),
        422,
      ),
    );
    final api = HttpApiClient(baseUrl: 'https://api.test', client: mock);

    expect(
      () => api.getCustomerData(tableToken: 'x'),
      throwsA(
        isA<AppError>().having((error) => error.details, 'details', {
          'itemId': 'M1',
        }),
      ),
    );
  });

  test(
    'customer endpoints use their planned POST routes and payloads',
    () async {
      final requests = <String, Map<String, dynamic>>{};
      final mock = MockClient((request) async {
        requests[request.url.path] = Map<String, dynamic>.from(
          jsonDecode(request.body) as Map,
        );
        final data = switch (request.url.path) {
          '/api/customer' => {
            'table': {'TableID': 'T1'},
            'categories': [],
            'menu': [],
            'promotions': [],
          },
          '/api/order/submit' => {
            'SessionID': 'S1',
            'table': {},
            'totals': {},
            'items': [],
            'submittedAt': '2026-01-01T00:00:00Z',
          },
          '/api/order/status' => {'session': {}, 'items': [], 'calls': []},
          '/api/call' => {'call': {}, 'duplicate': false},
          _ => <String, dynamic>{},
        };
        return http.Response(jsonEncode({'ok': true, 'data': data}), 200);
      });
      final api = HttpApiClient(baseUrl: 'https://api.test', client: mock);

      await api.getCustomerData(tableToken: 'table');
      await api.submitOrder(
        tableToken: 'table',
        idempotencyKey: 'key',
        promoCode: 'PROMO',
        items: const [
          OrderRequestItem(
            itemId: 'M1',
            qty: 2,
            optionIds: ['O1'],
            addOnIds: ['A1'],
            note: 'note',
          ),
        ],
      );
      await api.getOrderStatus(tableToken: 'table', sessionId: 'S1');
      await api.callStaff(
        tableToken: 'table',
        type: 'BILL',
        idempotencyKey: 'call',
      );

      expect(requests['/api/customer'], {'tableToken': 'table'});
      expect(requests['/api/order/submit'], {
        'tableToken': 'table',
        'idempotencyKey': 'key',
        'promoCode': 'PROMO',
        'items': [
          {
            'itemId': 'M1',
            'qty': 2,
            'optionIds': ['O1'],
            'addOnIds': ['A1'],
            'note': 'note',
          },
        ],
      });
      expect(requests['/api/order/status'], {
        'tableToken': 'table',
        'sessionId': 'S1',
      });
      expect(requests['/api/call'], {
        'tableToken': 'table',
        'type': 'BILL',
        'idempotencyKey': 'call',
      });
    },
  );
}
