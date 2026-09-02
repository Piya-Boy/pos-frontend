import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/api/api_client.dart';
import '../core/api/app_error.dart';
import '../core/offline/offline_store.dart';
import '../core/realtime/realtime_client.dart';
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
  RealtimeClient? _realtime;
  bool _live = false;
  late final OfflineStore _store = OfflineStore(tableToken);
  StreamSubscription<List<ConnectivityResult>>? _connSub;
  bool offline = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawCart = prefs.getString(_cartKey);
    try {
      data = await api.getCustomerData(tableToken: tableToken);
      final bootstrap = await api.bootstrap(tableToken: tableToken);
      app = AppConfig.fromJson(Map<String, dynamic>.from(bootstrap['app'] as Map));
      offline = false;
      // cache the fresh snapshot for offline reads
      await _store.cacheCatalog(data!.toJson(), {'app': app!.toJson()});
      // a successful load means we're online — flush any parked order
      await _drainQueue();
    } catch (_) {
      // network failed: fall back to the last cached catalog if we have one
      final cached = await _store.readCatalog();
      if (cached == null) rethrow; // nothing to show — let the UI surface the error
      data = CustomerData.fromJson(cached.customer);
      app = AppConfig.fromJson(Map<String, dynamic>.from(cached.bootstrap['app'] as Map));
      offline = true;
    }
    _watchConnectivity();
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
    startRealtime();
    notifyListeners();
  }

  /// Subscribes to this table's realtime channel. On any event (kitchen updated
  /// an item, table closed), refresh the session; polling stays as a fallback.
  void startRealtime() {
    final config = RealtimeConfig.fromEnvironment();
    if (!config.isEnabled || _realtime != null) return;
    _realtime = RealtimeClient(
      config: config,
      channels: ['pos-table.$tableToken'],
      onEvent: (_) => refreshStatus(),
      onConnectionChange: (connected) {
        _live = connected;
        if (session != null) startPolling(); // re-arm at the new interval
      },
    )..connect();
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
      final items = cart
          .map(
            (line) => OrderRequestItem(
              itemId: line.itemId,
              qty: line.qty,
              optionIds: line.optionIds,
              addOnIds: line.addOnIds,
              note: line.note,
            ),
          )
          .toList();
      try {
        await _sendOrder(_checkoutKey!, promoCode, items);
      } on AppError catch (error) {
        // Network failure → queue for reconnect; the key is reused so the server
        // dedupes if the request actually reached it. Business errors rethrow.
        if (_isNetworkError(error)) {
          await _store.queueOrder(QueuedOrder(idempotencyKey: _checkoutKey!, promoCode: promoCode, items: items));
          offline = true;
          notifyListeners();
          return;
        }
        rethrow;
      }
    } finally {
      _submitting = false;
    }
  }

  /// Submits an order and clears the cart/session on success. Shared by the
  /// online path and the offline-queue drain.
  Future<void> _sendOrder(String key, String promoCode, List<OrderRequestItem> items) async {
    final result = await api.submitOrder(
      tableToken: tableToken,
      idempotencyKey: key,
      promoCode: promoCode,
      items: items,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, result.sessionId);
    cart = [];
    await _saveCart();
    _checkoutKey = null;
    offline = false;
    await _store.clearQueue();
    await refreshStatus();
    startPolling();
  }

  bool _isNetworkError(AppError error) =>
      error.code == 'NETWORK_ERROR' || error.code == 'NETWORK_TIMEOUT';

  /// Listens for connectivity changes; on reconnect, drains a queued order.
  /// Guarded because the platform channel is unavailable in unit tests — the
  /// queue still drains via the next successful load/submit either way.
  void _watchConnectivity() {
    if (_connSub != null) return;
    try {
      _connSub = Connectivity().onConnectivityChanged.listen((results) {
        final online = results.any((r) => r != ConnectivityResult.none);
        if (online) _drainQueue();
      });
    } catch (_) {
      // no connectivity channel (headless/test) — rely on request-driven drain
    }
  }

  /// Sends a parked offline order exactly once. Server idempotency + our stored
  /// key dedupe a request that actually landed before we lost the response.
  Future<void> _drainQueue() async {
    if (_submitting) return;
    final queued = await _store.readQueued();
    if (queued == null) return;
    _submitting = true;
    try {
      await _sendOrder(queued.idempotencyKey, queued.promoCode, queued.items);
      notifyListeners();
    } on AppError catch (error) {
      // Real rejection (item archived, promo expired…) — drop it, surface later.
      if (!_isNetworkError(error)) {
        await _store.clearQueue();
        offline = false;
        notifyListeners();
      }
      // Network still down → leave it queued for the next reconnect.
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
    final base = (app?.pollSeconds ?? 5).clamp(5, 1 << 31);
    final seconds = _live ? 30 : base; // slow safety-net poll while socket is live
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
    _realtime?.dispose();
    _connSub?.cancel();
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
