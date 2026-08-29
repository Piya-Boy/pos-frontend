import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/api/api_client.dart';
import '../core/utils/client_id.dart';
import '../models/app_config.dart';
import '../models/cart_line.dart';
import '../models/menu_item.dart';
import '../models/session_bundle.dart';

class CustomerController extends ChangeNotifier {
  CustomerController({required this.api, required this.tableToken});

  final ApiClient api;
  final String tableToken;
  String search = '';
  String activeCategory = 'ALL';
  List<CartLine> cart = [];
  SessionBundle? session;
  bool paymentComplete = false;
  AppConfig? app;
  CustomerData? data;
  Timer? _poller;
  bool _submitting = false;
  bool _refreshing = false;
  String? _checkoutKey;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawCart = prefs.getString(_cartKey);
    data = await api.getCustomerData(tableToken: tableToken);
    final bootstrap = await api.bootstrap(tableToken: tableToken);
    app = AppConfig.fromJson(
      Map<String, dynamic>.from(bootstrap['app'] as Map),
    );
    if (rawCart != null) {
      final available = data!.menu
          .where((item) => item.available)
          .map((item) => item.itemId)
          .toSet();
      try {
        cart = (jsonDecode(rawCart) as List)
            .map(
              (line) =>
                  CartLine.fromJson(Map<String, dynamic>.from(line as Map)),
            )
            .where((line) => available.contains(line.itemId))
            .toList();
      } catch (_) {
        await prefs.remove(_cartKey);
      }
    }
    final sessionId = prefs.getString(_sessionKey);
    if (sessionId != null) {
      await refreshStatus();
      startPolling();
    }
    notifyListeners();
  }

  List<MenuItem> filteredMenu() => (data?.menu ?? const []).where((item) {
    final matchesCategory =
        activeCategory == 'ALL' || item.categoryId == activeCategory;
    final query = search.toLowerCase();
    return matchesCategory &&
        (query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query));
  }).toList();

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  void setCategory(String value) {
    activeCategory = value;
    notifyListeners();
  }

  void addToCart(CartLine line) {
    cart = [...cart, line];
    _saveCart();
    notifyListeners();
  }

  void removeLine(String lineId) {
    cart.removeWhere((line) => line.lineId == lineId);
    _saveCart();
    notifyListeners();
  }

  void changeQty(String lineId, int delta) {
    cart = cart
        .map(
          (line) =>
              line.lineId != lineId ? line : _copy(line, qty: line.qty + delta),
        )
        .where((line) => line.qty > 0)
        .toList();
    _saveCart();
    notifyListeners();
  }

  num cartCount() => cart.fold(0, (total, line) => total + line.qty);
  num cartSubtotal() =>
      cart.fold(0, (total, line) => total + line.unitPrice * line.qty);

  Future<void> submit(String promoCode) async {
    if (_submitting || cart.isEmpty) return;
    _submitting = true;
    try {
      _checkoutKey ??= clientId('order');
      final result = await api.submitOrder(
        tableToken: tableToken,
        idempotencyKey: _checkoutKey!,
        promoCode: promoCode,
        items: cart
            .map(
              (line) => OrderRequestItem(
                itemId: line.itemId,
                qty: line.qty,
                optionIds: line.optionIds,
                addOnIds: line.addOnIds,
                note: line.note,
              ),
            )
            .toList(),
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, result.sessionId);
      cart = [];
      await _saveCart();
      _checkoutKey = null;
      await refreshStatus();
      startPolling();
    } finally {
      _submitting = false;
    }
  }

  Future<CallResult> callStaff(String type) async {
    if (type == 'BILL' && session == null) {
      throw StateError('NO_SESSION');
    }
    final result = await api.callStaff(
      tableToken: tableToken,
      type: type,
      idempotencyKey: clientId('call'),
    );
    await refreshStatus();
    return result;
  }

  Future<void> refreshStatus() async {
    if (_refreshing) return;
    _refreshing = true;
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_sessionKey);
    if (id == null) {
      _refreshing = false;
      return;
    }
    SessionBundle next;
    try {
      next = await api.getOrderStatus(tableToken: tableToken, sessionId: id);
    } on StateError catch (error) {
      if ('$error'.contains('SESSION_NOT_FOUND')) {
        await prefs.remove(_sessionKey);
        session = null;
        stopPolling();
        notifyListeners();
        return;
      }
      rethrow;
    } finally {
      _refreshing = false;
    }
    final status = next.session.status;
    if ({'PAID', 'CLOSED', 'CANCELLED'}.contains(status)) {
      cart = [];
      await _saveCart();
      await prefs.remove(_sessionKey);
      paymentComplete = status == 'PAID';
      session = null;
      stopPolling();
    } else {
      paymentComplete = false;
      session = next;
    }
    notifyListeners();
  }

  void startPolling() {
    stopPolling();
    if (session == null) return;
    final seconds = (app?.pollSeconds ?? 5).clamp(5, 1 << 31);
    _poller = Timer.periodic(Duration(seconds: seconds), (_) async {
      try {
        await refreshStatus();
      } catch (_) {}
    });
  }

  void stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cartKey,
      jsonEncode(cart.map((line) => line.toJson()).toList()),
    );
  }

  String get _cartKey => 'phius-cart-$tableToken';
  String get _sessionKey => 'phius-session-$tableToken';
  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

CartLine _copy(CartLine line, {required int qty}) => CartLine(
  lineId: line.lineId,
  itemId: line.itemId,
  name: line.name,
  image: line.image,
  basePrice: line.basePrice,
  qty: qty,
  optionIds: line.optionIds,
  addOnIds: line.addOnIds,
  options: line.options,
  addOns: line.addOns,
  note: line.note,
  unitPrice: line.unitPrice,
);
