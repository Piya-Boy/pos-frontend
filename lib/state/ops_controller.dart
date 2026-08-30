import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
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
    _pollTimer ??= Timer.periodic(
      Duration(seconds: pollSeconds < 5 ? 5 : pollSeconds),
      (_) => load(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    super.dispose();
  }
}
