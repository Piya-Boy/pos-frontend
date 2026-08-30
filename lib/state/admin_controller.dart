import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/api/api_client.dart';
import '../models/staff_models.dart';

class AdminController extends ChangeNotifier {
  factory AdminController({
    required ApiClient api,
    required String token,
    int pollSeconds = 15,
  }) => AdminController._(api, token, pollSeconds: pollSeconds);

  AdminController._(this._api, this._token, {required this.pollSeconds});

  final ApiClient _api;
  final int pollSeconds;
  String _token;
  AdminData? _data;
  Timer? _pollTimer;
  Future<void>? _activeLoad;
  bool _loading = false;
  bool _editing = false;
  bool _disposed = false;
  String? _error;

  AdminData? get data => _data;
  bool get loading => _loading;
  bool get editing => _editing;
  String? get error => _error;

  void useToken(String token) {
    if (token == _token) return;
    stopPolling();
    _token = token;
    _data = null;
    _error = null;
    _activeLoad = null;
  }

  Future<void> load() async {
    if (_disposed || _token.isEmpty || _editing) return;
    final activeLoad = _activeLoad;
    if (activeLoad != null) return activeLoad;
    final load = _load();
    _activeLoad = load;
    try {
      await load;
    } finally {
      if (identical(_activeLoad, load)) _activeLoad = null;
    }
  }

  void setEditing(bool value) {
    if (_editing == value) return;
    _editing = value;
    if (value) {
      stopPolling();
    } else {
      load();
      startPolling();
    }
    notifyListeners();
  }

  void startPolling() {
    if (_editing || _token.isEmpty || _pollTimer != null) return;
    _pollTimer = Timer.periodic(
      Duration(seconds: pollSeconds < 5 ? 5 : pollSeconds),
      (_) => load(),
    );
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> saveEntity(String entity, Map<String, dynamic> data) async {
    await _mutate(
      () => _api.adminSaveEntity(token: _token, entity: entity, data: data),
    );
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _mutate(
      () => _api.adminSaveSettings(token: _token, settings: settings),
    );
  }

  Future<void> archiveEntity(String entity, String id) async {
    await _mutate(
      () => _api.adminArchiveEntity(token: _token, entity: entity, id: id),
    );
  }

  Future<void> rotateTableToken(String tableId) async {
    await _mutate(() => _api.adminRotateToken(token: _token, tableId: tableId));
  }

  Future<void> _mutate(Future<Object?> Function() action) async {
    final resumePolling = _pollTimer != null;
    setEditing(true);
    try {
      await action();
      _editing = false;
      await load();
    } finally {
      _editing = false;
      if (resumePolling) startPolling();
      notifyListeners();
    }
  }

  Future<void> _load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _data = await _api.adminData(token: _token);
    } catch (_) {
      _error = 'ไม่สามารถโหลดข้อมูลผู้ดูแลได้';
    } finally {
      _loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    super.dispose();
  }
}
