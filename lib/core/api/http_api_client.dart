import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/core/api/app_error.dart';
import 'package:pos_frontend/models/session_bundle.dart';

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
