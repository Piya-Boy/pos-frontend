import '../../models/call_log.dart';
import '../../models/category.dart';
import '../../models/menu_item.dart';
import '../../models/order_item.dart';
import '../../models/promotion.dart';
import '../../models/session_bundle.dart';
import '../../models/staff_models.dart';
import '../../models/totals.dart';

abstract class ApiClient {
  Future<Map<String, dynamic>> bootstrap({required String tableToken});

  Future<CustomerData> getCustomerData({required String tableToken});

  Future<SubmitResult> submitOrder({
    required String tableToken,
    required String idempotencyKey,
    required String promoCode,
    required List<OrderRequestItem> items,
  });

  Future<SessionBundle> getOrderStatus({
    required String tableToken,
    required String sessionId,
  });

  Future<CallResult> callStaff({
    required String tableToken,
    required String type,
    required String idempotencyKey,
  });

  Future<StaffSession> login({required String pin, String? expectedRole});

  Future<void> logout({required String token});

  Future<void> changePin({required String token, required String newPin});

  Future<OpsDashboard> opsDashboard({
    required String token,
    required String view,
  });

  Future<OpsOrderItem> updateOrderItem({
    required String token,
    required String orderItemId,
    required String status,
    String? kitchenNote,
  });

  Future<OpsCall> updateCall({
    required String token,
    required String logId,
    required String status,
  });

  Future<Receipt> closeTable({
    required String token,
    required String sessionId,
    required String method,
    String? reference,
    required String idempotencyKey,
  });

  Future<AdminData> adminData({required String token});

  Future<Map<String, dynamic>> adminSaveSettings({
    required String token,
    required Map<String, dynamic> settings,
  });

  Future<Map<String, dynamic>> adminSaveEntity({
    required String token,
    required String entity,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> adminArchiveEntity({
    required String token,
    required String entity,
    required String id,
  });

  Future<Map<String, dynamic>> adminRotateToken({
    required String token,
    required String tableId,
  });

  /// Uploads an image and returns its public URL (E3). [bytes] is the raw file.
  Future<String> adminUploadImage({
    required String token,
    required List<int> bytes,
    required String filename,
  });
}

class CustomerData {
  const CustomerData({
    required this.table,
    required this.categories,
    required this.menu,
    required this.promotions,
    this.session,
  });

  final Map<String, dynamic> table;
  final List<Category> categories;
  final List<MenuItem> menu;
  final List<Promotion> promotions;
  final SessionBundle? session;

  factory CustomerData.fromJson(Map<String, dynamic> json) => CustomerData(
    table: Map<String, dynamic>.from(json['table'] as Map),
    categories: ((json['categories'] as List?) ?? const [])
        .map(
          (category) =>
              Category.fromJson(Map<String, dynamic>.from(category as Map)),
        )
        .toList(),
    menu: ((json['menu'] as List?) ?? const [])
        .map(
          (item) => MenuItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    promotions: ((json['promotions'] as List?) ?? const [])
        .map(
          (promotion) =>
              Promotion.fromJson(Map<String, dynamic>.from(promotion as Map)),
        )
        .toList(),
    session: json['session'] is Map
        ? SessionBundle.fromJson(
            Map<String, dynamic>.from(json['session'] as Map),
          )
        : null,
  );

  Map<String, dynamic> toJson() => {
    'table': table,
    'categories': categories.map((category) => category.toJson()).toList(),
    'menu': menu.map((item) => item.toJson()).toList(),
    'promotions': promotions.map((promotion) => promotion.toJson()).toList(),
    'session': session?.toJson(),
  };
}

class OrderRequestItem {
  const OrderRequestItem({
    required this.itemId,
    required this.qty,
    required this.optionIds,
    required this.addOnIds,
    required this.note,
  });

  final String itemId;
  final int qty;
  final List<String> optionIds;
  final List<String> addOnIds;
  final String note;

  factory OrderRequestItem.fromJson(Map<String, dynamic> json) =>
      OrderRequestItem(
        itemId: '${json['itemId'] ?? ''}',
        qty: _number(json['qty']).toInt(),
        optionIds: _stringList(json['optionIds']),
        addOnIds: _stringList(json['addOnIds']),
        note: '${json['note'] ?? ''}',
      );

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'qty': qty,
    'optionIds': optionIds,
    'addOnIds': addOnIds,
    'note': note,
  };
}

class SubmitResult {
  const SubmitResult({
    required this.sessionId,
    required this.table,
    required this.totals,
    required this.items,
    required this.submittedAt,
  });

  final String sessionId;
  final Map<String, dynamic> table;
  final Totals totals;
  final List<OrderItem> items;
  final DateTime submittedAt;

  factory SubmitResult.fromJson(Map<String, dynamic> json) => SubmitResult(
    sessionId: '${json['SessionID'] ?? ''}',
    table: Map<String, dynamic>.from(json['table'] as Map),
    totals: Totals.fromJson(Map<String, dynamic>.from(json['totals'] as Map)),
    items: ((json['items'] as List?) ?? const [])
        .map(
          (item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    submittedAt:
        DateTime.tryParse('${json['submittedAt'] ?? ''}') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );

  Map<String, dynamic> toJson() => {
    'SessionID': sessionId,
    'table': table,
    'totals': totals.toJson(),
    'items': items.map((item) => item.toJson()).toList(),
    'submittedAt': submittedAt.toUtc().toIso8601String(),
  };
}

class CallResult {
  const CallResult({required this.call, required this.duplicate});

  final CallLog call;
  final bool duplicate;

  factory CallResult.fromJson(Map<String, dynamic> json) => CallResult(
    call: CallLog.fromJson(Map<String, dynamic>.from(json['call'] as Map)),
    duplicate:
        json['duplicate'] == true ||
        '${json['duplicate']}'.toLowerCase() == 'true',
  );

  Map<String, dynamic> toJson() => {
    'call': call.toJson(),
    'duplicate': duplicate,
  };
}

num _number(Object? value) =>
    value is num ? value : num.tryParse('$value') ?? 0;

List<String> _stringList(Object? value) =>
    value is List ? value.map((item) => '$item').toList() : const [];
