import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../core/realtime/realtime_client.dart';
import '../models/staff_models.dart';

class OpsController extends ChangeNotifier {
  factory OpsController({
    required ApiClient api,
    required String token,
    required String view,
    int pollSeconds = 10,
  }) => OpsController._(
    api: api,
    token: token,
    view: view,
    pollSeconds: pollSeconds,
  );

  OpsController._({
    required this._api,
    required this._token,
    required this.view,
    this.pollSeconds = 10,
  });

  final ApiClient _api;
  String _token;
  final String view;
  final int pollSeconds;

  OpsDashboard? _dashboard;
  bool _loading = false;
  String? _error;
  Timer? _pollTimer;
  Future<void>? _activeLoad;
  bool _disposed = false;
  int _tokenGeneration = 0;
  RealtimeClient? _realtime;
  bool _live = false; // true while the socket is connected

  /// When the socket is live, poll slowly as a safety net; otherwise poll at the
  /// normal interval so a dropped socket still gets timely updates.
  int get _effectivePollSeconds {
    final base = pollSeconds < 5 ? 5 : pollSeconds;
    return _live ? 30 : base;
  }

  OpsDashboard? get dashboard => _dashboard;
  String get token => _token;
  bool get loading => _loading;
  String? get error => _error;
  bool get polling => _pollTimer?.isActive ?? false;

  void useToken(String token) {
    if (token == _token) return;
    stopPolling();
    _token = token;
    _tokenGeneration++;
    _activeLoad = null;
    _dashboard = null;
    _error = null;
    _loading = false;
  }

  Future<void> load() async {
    if (_disposed) return;
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    final load = _loadDashboard(_token, _tokenGeneration);
    _activeLoad = load;
    try {
      await load;
    } finally {
      if (identical(_activeLoad, load)) _activeLoad = null;
    }
  }

  Future<void> updateOrderStatus(OpsOrderItem item, String status) async {
    await _api.updateOrderItem(
      token: token,
      orderItemId: item.orderItemId,
      status: status,
    );
    await load();
  }

  Future<void> updateCallStatus(OpsCall call, String status) async {
    await _api.updateCall(token: token, logId: call.logId, status: status);
    await load();
  }

  Future<Receipt> closeTable(
    OpsSession session,
    String method,
    String reference,
    String idempotencyKey,
  ) async {
    final receipt = await _api.closeTable(
      token: token,
      sessionId: session.session.sessionId,
      method: method,
      reference: reference.isEmpty ? null : reference,
      idempotencyKey: idempotencyKey,
    );
    await load();
    return receipt;
  }

  Future<void> _loadDashboard(String token, int tokenGeneration) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final dashboard = await _api.opsDashboard(token: token, view: view);
      if (_disposed || tokenGeneration != _tokenGeneration) return;
      _dashboard = dashboard;
    } catch (_) {
      if (_disposed || tokenGeneration != _tokenGeneration) return;
      _error = 'ไม่สามารถโหลดข้อมูลงานหน้าร้านได้';
    }
    if (_disposed || tokenGeneration != _tokenGeneration) return;
    _loading = false;
    notifyListeners();
  }

  void startPolling() {
    stopPolling();
    _pollTimer = Timer.periodic(
      Duration(seconds: _effectivePollSeconds),
      (_) => load(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Subscribes to the staff realtime channel. On every ops event, refresh the
  /// dashboard immediately; polling continues as a fallback (slower while live).
  void startRealtime() {
    final config = RealtimeConfig.fromEnvironment();
    if (!config.isEnabled || _realtime != null) return;
    _realtime = RealtimeClient(
      config: config,
      channels: const ['pos-ops'],
      onEvent: (_) => load(),
      onConnectionChange: (connected) {
        _live = connected;
        if (!_disposed) startPolling(); // re-arm timer at the new interval
      },
    )..connect();
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    _realtime?.dispose();
    super.dispose();
  }
}
