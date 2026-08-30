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

  test('staff endpoints use their planned POST routes and payloads', () async {
    final requests = <String, Map<String, dynamic>>{};
    final mock = MockClient((request) async {
      requests[request.url.path] = Map<String, dynamic>.from(
        jsonDecode(request.body) as Map,
      );
      final user = {
        'staffId': 'S1',
        'name': 'Kitchen',
        'role': 'KITCHEN',
        'issuedAt': '2026-01-01T00:00:00Z',
        'mustChangePin': false,
      };
      final data = switch (request.url.path) {
        '/api/auth/login' => {'token': 'auth-1', 'user': user},
        '/api/ops/dashboard' => {
          'user': user,
          'view': 'KITCHEN',
          'items': [],
          'sessions': [],
          'calls': [],
          'summary': {},
        },
        '/api/ops/order-status' => {'OrderItemID': 'O1'},
        '/api/ops/call-status' => {'LogID': 'C1'},
        '/api/ops/close-table' => {
          'receipt': {
            'restaurantName': 'Phius',
            'table': 'T1',
            'session': {},
            'items': [],
            'generatedAt': '2026-01-01T00:00:00Z',
          },
        },
        '/api/admin/data' => {'user': user, 'settings': {}, 'summary': {}},
        _ => <String, dynamic>{},
      };
      return http.Response(jsonEncode({'ok': true, 'data': data}), 200);
    });
    final api = HttpApiClient(baseUrl: 'https://api.test', client: mock);

    final login = await api.login(pin: '1234');
    await api.logout(token: login.token);
    await api.changePin(token: login.token, newPin: 'abcdef');
    await api.opsDashboard(token: login.token, view: 'KITCHEN');
    await api.updateOrderItem(
      token: login.token,
      orderItemId: 'O1',
      status: 'PREPARING',
      kitchenNote: 'hot',
    );
    await api.updateCall(token: login.token, logId: 'C1', status: 'DONE');
    await api.closeTable(
      token: login.token,
      sessionId: 'S1',
      method: 'CASH',
      reference: 'ref',
      idempotencyKey: 'pay-1',
    );
    await api.adminData(token: login.token);
    await api.adminSaveSettings(
      token: login.token,
      settings: {'PrimaryColor': '#000000'},
    );
    await api.adminSaveEntity(
      token: login.token,
      entity: 'menu',
      data: {'ItemID': 'M1'},
    );
    await api.adminArchiveEntity(token: login.token, entity: 'menu', id: 'M1');
    await api.adminRotateToken(token: login.token, tableId: 'T1');

    expect(requests['/api/auth/login'], {'pin': '1234'});
    expect(requests['/api/auth/logout'], {'token': 'auth-1'});
    expect(requests['/api/auth/change-pin'], {
      'token': 'auth-1',
      'newPin': 'abcdef',
    });
    expect(requests['/api/ops/dashboard'], {
      'token': 'auth-1',
      'view': 'KITCHEN',
    });
    expect(requests['/api/ops/order-status'], {
      'token': 'auth-1',
      'orderItemId': 'O1',
      'status': 'PREPARING',
      'kitchenNote': 'hot',
    });
    expect(requests['/api/ops/call-status'], {
      'token': 'auth-1',
      'logId': 'C1',
      'status': 'DONE',
    });
    expect(requests['/api/ops/close-table'], {
      'token': 'auth-1',
      'sessionId': 'S1',
      'method': 'CASH',
      'reference': 'ref',
      'idempotencyKey': 'pay-1',
    });
    expect(requests['/api/admin/data'], {'token': 'auth-1'});
    expect(requests['/api/admin/settings'], {
      'token': 'auth-1',
      'settings': {'PrimaryColor': '#000000'},
    });
    expect(requests['/api/admin/entity'], {
      'token': 'auth-1',
      'entity': 'menu',
      'data': {'ItemID': 'M1'},
    });
    expect(requests['/api/admin/entity/archive'], {
      'token': 'auth-1',
      'entity': 'menu',
      'id': 'M1',
    });
    expect(requests['/api/admin/table/rotate-token'], {
      'token': 'auth-1',
      'tableId': 'T1',
    });
  });
}
