import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

/// E2 offline-first store (customer). Persists the last catalog snapshot and a
/// single pending order, both keyed per table token, in shared_preferences.
/// See docs/E2-offline-spec.md. Deliberately a one-slot order queue — the
/// customer flow holds one active order per table.
class OfflineStore {
  OfflineStore(this.tableToken);

  final String tableToken;

  String get _catalogKey => 'phius-catalog-$tableToken';
  String get _queueKey => 'phius-queued-order-$tableToken';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Caches the raw customer-data + bootstrap payloads for offline reads.
  Future<void> cacheCatalog(Map<String, dynamic> customer, Map<String, dynamic> bootstrap) async {
    final prefs = await _prefs;
    await prefs.setString(_catalogKey, jsonEncode({'customer': customer, 'bootstrap': bootstrap}));
  }

  /// Returns the cached ({customer, bootstrap}) snapshot, or null if none.
  Future<({Map<String, dynamic> customer, Map<String, dynamic> bootstrap})?> readCatalog() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_catalogKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (
        customer: Map<String, dynamic>.from(map['customer'] as Map),
        bootstrap: Map<String, dynamic>.from(map['bootstrap'] as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Stores a single pending order to send on reconnect. The idempotencyKey is
  /// part of the payload so retries dedupe server-side.
  Future<void> queueOrder(QueuedOrder order) async {
    final prefs = await _prefs;
    await prefs.setString(_queueKey, jsonEncode(order.toJson()));
  }

  Future<QueuedOrder?> readQueued() async {
    final prefs = await _prefs;
    final raw = prefs.getString(_queueKey);
    if (raw == null) return null;
    try {
      return QueuedOrder.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> clearQueue() async {
    final prefs = await _prefs;
    await prefs.remove(_queueKey);
  }
}

/// A submit payload parked while offline. Reused verbatim (same idempotencyKey)
/// on every retry so the server's idempotency guard dedupes a double-send.
class QueuedOrder {
  const QueuedOrder({
    required this.idempotencyKey,
    required this.promoCode,
    required this.items,
  });

  final String idempotencyKey;
  final String promoCode;
  final List<OrderRequestItem> items;

  Map<String, dynamic> toJson() => {
        'idempotencyKey': idempotencyKey,
        'promoCode': promoCode,
        'items': items
            .map((i) => {
                  'itemId': i.itemId,
                  'qty': i.qty,
                  'optionIds': i.optionIds,
                  'addOnIds': i.addOnIds,
                  'note': i.note,
                })
            .toList(),
      };

  factory QueuedOrder.fromJson(Map<String, dynamic> json) => QueuedOrder(
        idempotencyKey: '${json['idempotencyKey']}',
        promoCode: '${json['promoCode'] ?? ''}',
        items: (json['items'] as List)
            .map((raw) {
              final m = Map<String, dynamic>.from(raw as Map);
              return OrderRequestItem(
                itemId: '${m['itemId']}',
                qty: (m['qty'] as num).toInt(),
                optionIds: List<String>.from(m['optionIds'] as List? ?? const []),
                addOnIds: List<String>.from(m['addOnIds'] as List? ?? const []),
                note: '${m['note'] ?? ''}',
              );
            })
            .toList(),
      );
}
