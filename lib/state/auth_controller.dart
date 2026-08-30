import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../models/staff_models.dart';

enum StaffRoute { kitchen, staff, cashier, operations, admin }

extension StaffRouteDetails on StaffRoute {
  String get key => name;

  String get expectedRole => switch (this) {
    StaffRoute.kitchen => 'KITCHEN',
    StaffRoute.staff => 'STAFF',
    StaffRoute.cashier => 'CASHIER',
    StaffRoute.operations || StaffRoute.admin => 'ADMIN',
  };
}

class AuthController extends ChangeNotifier {
  AuthController({required this._api, required this.route});

  final ApiClient _api;
  final StaffRoute route;

  StaffSession? _session;
  bool _loading = false;
  String? _error;

  StaffSession? get session => _session;
  bool get loading => _loading;
  String? get error => _error;
  bool get mustChangePin => _session?.mustChangePin == true;
  String get storageKey => 'pos-auth-${route.key}';

  Future<bool> resolveOnBoot() async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(storageKey);
    if (token == null || token.isEmpty) return false;
    _session = StaffSession(
      token: token,
      staffId: '',
      name: '',
      role: route.expectedRole,
      issuedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      mustChangePin: false,
    );
    notifyListeners();
    return true;
  }

  Future<bool> login(String pin) async {
    if (!RegExp(r'^[A-Za-z0-9]{4,12}$').hasMatch(pin)) {
      _error = 'PIN ต้องเป็นตัวอักษรภาษาอังกฤษหรือตัวเลข 4–12 ตัว';
      notifyListeners();
      return false;
    }
    return _run(() async {
      final session = await _api.login(
        pin: pin,
        expectedRole: route.expectedRole,
      );
      _session = session;
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(storageKey, session.token);
    });
  }

  Future<bool> changePin(String newPin) async {
    final session = _session;
    if (session == null) return false;
    if (!RegExp(r'^[A-Za-z0-9]{6,12}$').hasMatch(newPin)) {
      _error = 'PIN ใหม่ต้องเป็นตัวอักษรภาษาอังกฤษหรือตัวเลข 6–12 ตัว';
      notifyListeners();
      return false;
    }
    return _run(() async {
      await _api.changePin(token: session.token, newPin: newPin);
      _session = StaffSession(
        token: session.token,
        staffId: session.staffId,
        name: session.name,
        role: session.role,
        issuedAt: session.issuedAt,
        mustChangePin: false,
      );
    });
  }

  Future<void> logout() async {
    final token = _session?.token;
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(storageKey);
    _session = null;
    _error = null;
    notifyListeners();
    if (token != null) {
      try {
        await _api.logout(token: token);
      } catch (_) {
        // Local token removal must not depend on network availability.
      }
    }
  }

  Future<bool> _run(Future<void> Function() action) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } catch (_) {
      _error = 'PIN หรือบทบาทไม่ถูกต้อง';
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
