import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/core/api/app_error.dart';
import 'package:pos_frontend/models/session_bundle.dart';
import 'package:pos_frontend/models/staff_models.dart';

class HttpApiClient implements ApiClient {
  HttpApiClient({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/+$'), ''),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  @override
  Future<Map<String, dynamic>> bootstrap({required String tableToken}) async =>
      _map(await _post('/api/bootstrap', {'tableToken': tableToken}));

  @override
  Future<CustomerData> getCustomerData({required String tableToken}) async =>
      CustomerData.fromJson(
        _map(await _post('/api/customer', {'tableToken': tableToken})),
      );

  @override
  Future<SubmitResult> submitOrder({
    required String tableToken,
    required String idempotencyKey,
    required String promoCode,
    required List<OrderRequestItem> items,
  }) async => SubmitResult.fromJson(
    _map(
      await _post('/api/order/submit', {
        'tableToken': tableToken,
        'idempotencyKey': idempotencyKey,
        'promoCode': promoCode,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    ),
  );

  @override
  Future<SessionBundle> getOrderStatus({
    required String tableToken,
    required String sessionId,
  }) async => SessionBundle.fromJson(
    _map(
      await _post('/api/order/status', {
        'tableToken': tableToken,
        'sessionId': sessionId,
      }),
    ),
  );

  @override
  Future<CallResult> callStaff({
    required String tableToken,
    required String type,
    required String idempotencyKey,
  }) async => CallResult.fromJson(
    _map(
      await _post('/api/call', {
        'tableToken': tableToken,
        'type': type,
        'idempotencyKey': idempotencyKey,
      }),
    ),
  );

  @override
  Future<StaffSession> login({
    required String pin,
    String? expectedRole,
  }) async => StaffSession.fromJson(
    _map(
      await _post('/api/auth/login', {
        'pin': pin,
        'expectedRole': ?expectedRole,
      }),
    ),
  );

  @override
  Future<void> logout({required String token}) async {
    await _post('/api/auth/logout', {'token': token});
  }

  @override
  Future<void> changePin({
    required String token,
    required String newPin,
  }) async {
    await _post('/api/auth/change-pin', {'token': token, 'newPin': newPin});
  }

  @override
  Future<OpsDashboard> opsDashboard({
    required String token,
    required String view,
  }) async => OpsDashboard.fromJson(
    _map(await _post('/api/ops/dashboard', {'token': token, 'view': view})),
  );

  @override
  Future<OpsOrderItem> updateOrderItem({
    required String token,
    required String orderItemId,
    required String status,
    String? kitchenNote,
  }) async => OpsOrderItem.fromJson(
    _map(
      await _post('/api/ops/order-status', {
        'token': token,
        'orderItemId': orderItemId,
        'status': status,
        'kitchenNote': ?kitchenNote,
      }),
    ),
  );

  @override
  Future<OpsCall> updateCall({
    required String token,
    required String logId,
    required String status,
  }) async => OpsCall.fromJson(
    _map(
      await _post('/api/ops/call-status', {
        'token': token,
        'logId': logId,
        'status': status,
      }),
    ),
  );

  @override
  Future<Receipt> closeTable({
    required String token,
    required String sessionId,
    required String method,
    String? reference,
    required String idempotencyKey,
  }) async {
    final result = _map(
      await _post('/api/ops/close-table', {
        'token': token,
        'sessionId': sessionId,
        'method': method,
        'reference': ?reference,
        'idempotencyKey': idempotencyKey,
      }),
    );
    return Receipt.fromJson(
      Map<String, dynamic>.from(result['receipt'] as Map),
    );
  }

  @override
  Future<AdminData> adminData({required String token}) async =>
      AdminData.fromJson(
        _map(await _post('/api/admin/data', {'token': token})),
      );

  @override
  Future<Map<String, dynamic>> adminSaveSettings({
    required String token,
    required Map<String, dynamic> settings,
  }) async => _map(
    await _post('/api/admin/settings', {'token': token, 'settings': settings}),
  );

  @override
  Future<Map<String, dynamic>> adminSaveEntity({
    required String token,
    required String entity,
    required Map<String, dynamic> data,
  }) async => _map(
    await _post('/api/admin/entity', {
      'token': token,
      'entity': entity,
      'data': data,
    }),
  );

  @override
  Future<Map<String, dynamic>> adminArchiveEntity({
    required String token,
    required String entity,
    required String id,
  }) async => _map(
    await _post('/api/admin/entity/archive', {
      'token': token,
      'entity': entity,
      'id': id,
    }),
  );

  @override
  Future<Map<String, dynamic>> adminRotateToken({
    required String token,
    required String tableId,
  }) async => _map(
    await _post('/api/admin/table/rotate-token', {
      'token': token,
      'tableId': tableId,
    }),
  );

  @override
  Future<String> adminUploadImage({
    required String token,
    required List<int> bytes,
    required String filename,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/api/admin/upload-image'),
    )
      ..fields['token'] = token
      ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: filename));

    http.Response response;
    try {
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const AppError(code: 'NETWORK_TIMEOUT', message: 'The upload timed out.');
    } on http.ClientException catch (error) {
      throw AppError(code: 'NETWORK_ERROR', message: error.message);
    }

    final decoded = _decode(response.body);
    if (decoded == null || decoded['ok'] != true) {
      final error = decoded?['error'] is Map
          ? Map<String, dynamic>.from(decoded!['error'] as Map)
          : const <String, dynamic>{};
      throw AppError(
        code: '${error['code'] ?? 'UPLOAD_FAILED'}',
        message: '${error['message'] ?? 'Image upload failed.'}',
        details: error['details'],
      );
    }
    final data = decoded['data'] is Map
        ? Map<String, dynamic>.from(decoded['data'] as Map)
        : const <String, dynamic>{};
    return '${data['url'] ?? ''}';
  }

  Future<Object?> _post(String path, Map<String, dynamic> body) async {
    http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('$_baseUrl$path'),
            headers: const {
              'accept': 'application/json',
              'content-type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const AppError(
        code: 'NETWORK_TIMEOUT',
        message: 'The request timed out.',
      );
    } on http.ClientException catch (error) {
      throw AppError(code: 'NETWORK_ERROR', message: error.message);
    }

    final decoded = _decode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded?['error'] is Map
          ? Map<String, dynamic>.from(decoded!['error'] as Map)
          : const <String, dynamic>{};
      throw AppError(
        code: '${error['code'] ?? 'HTTP_ERROR'}',
        message: '${error['message'] ?? 'Request failed.'}',
        details: error['details'],
      );
    }
    if (decoded == null) {
      throw const AppError(
        code: 'INVALID_RESPONSE',
        message: 'The server returned invalid JSON.',
      );
    }
    if (decoded['ok'] == true) return decoded['data'];

    final error = decoded['error'] is Map
        ? Map<String, dynamic>.from(decoded['error'] as Map)
        : const <String, dynamic>{};
    throw AppError(
      code: '${error['code'] ?? 'API_ERROR'}',
      message: '${error['message'] ?? 'The request failed.'}',
      details: error['details'],
    );
  }

  Map<String, dynamic>? _decode(String body) {
    try {
      final value = jsonDecode(body);
      return value is Map ? Map<String, dynamic>.from(value) : null;
    } on FormatException {
      return null;
    }
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    throw const AppError(
      code: 'INVALID_RESPONSE',
      message: 'The server returned an invalid data payload.',
    );
  }
}
