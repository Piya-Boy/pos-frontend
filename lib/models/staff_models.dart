import 'call_log.dart';
import 'order_item.dart';
import 'order_session.dart';

class StaffSession {
  const StaffSession({
    required this.token,
    required this.staffId,
    required this.name,
    required this.role,
    required this.issuedAt,
    required this.mustChangePin,
  });

  final String token;
  final String staffId;
  final String name;
  final String role;
  final DateTime issuedAt;
  final bool mustChangePin;

  factory StaffSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;
    return StaffSession(
      token: '${json['token'] ?? ''}',
      staffId: '${user['staffId'] ?? user['StaffID'] ?? ''}',
      name: '${user['name'] ?? user['Name'] ?? ''}',
      role: '${user['role'] ?? user['Role'] ?? ''}',
      issuedAt:
          DateTime.tryParse('${user['issuedAt'] ?? ''}') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      mustChangePin:
          user['mustChangePin'] == true ||
          '${user['mustChangePin']}'.toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'user': {
      'staffId': staffId,
      'name': name,
      'role': role,
      'issuedAt': issuedAt.toUtc().toIso8601String(),
      'mustChangePin': mustChangePin,
    },
  };
}

class OpsOrderItem {
  const OpsOrderItem({
    required this.order,
    required this.table,
    required this.kitchenNote,
    required this.createdAt,
    required this.updatedAt,
  });

  final OrderItem order;
  final Map<String, dynamic> table;
  final String kitchenNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get orderItemId => order.orderItemId;
  String get status => order.status;

  factory OpsOrderItem.fromJson(Map<String, dynamic> json) => OpsOrderItem(
    order: OrderItem.fromJson(json),
    table: _map(json['table']),
    kitchenNote: '${json['KitchenNote'] ?? json['kitchenNote'] ?? ''}',
    createdAt: _date(json['CreatedAt'] ?? json['createdAt']),
    updatedAt: _date(json['UpdatedAt'] ?? json['updatedAt']),
  );

  Map<String, dynamic> toJson() => {
    ...order.toJson(),
    'table': table,
    'KitchenNote': kitchenNote,
    'CreatedAt': createdAt?.toUtc().toIso8601String(),
    'UpdatedAt': updatedAt?.toUtc().toIso8601String(),
  };
}

class OpsCall {
  const OpsCall({
    required this.call,
    required this.table,
    required this.createdAt,
    required this.acceptedAt,
    required this.completedAt,
  });

  final CallLog call;
  final Map<String, dynamic> table;
  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  String get logId => call.logId;
  String get status => call.status;

  factory OpsCall.fromJson(Map<String, dynamic> json) => OpsCall(
    call: CallLog.fromJson(json),
    table: _map(json['table']),
    createdAt: _date(json['CreatedAt'] ?? json['createdAt']),
    acceptedAt: _date(json['AcceptedAt'] ?? json['acceptedAt']),
    completedAt: _date(json['CompletedAt'] ?? json['completedAt']),
  );

  Map<String, dynamic> toJson() => {
    ...call.toJson(),
    'table': table,
    'CreatedAt': createdAt?.toUtc().toIso8601String(),
    'AcceptedAt': acceptedAt?.toUtc().toIso8601String(),
    'CompletedAt': completedAt?.toUtc().toIso8601String(),
  };
}

class OpsSession {
  const OpsSession({
    required this.session,
    required this.table,
    required this.items,
    required this.openTime,
    required this.closeTime,
    required this.paymentMethod,
  });

  final OrderSession session;
  final Map<String, dynamic> table;
  final List<OpsOrderItem> items;
  final DateTime? openTime;
  final DateTime? closeTime;
  final String paymentMethod;

  factory OpsSession.fromJson(Map<String, dynamic> json) => OpsSession(
    session: OrderSession.fromJson(json),
    table: _map(json['table']),
    items: ((json['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => OpsOrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    openTime: _date(json['OpenTime'] ?? json['openTime']),
    closeTime: _date(json['CloseTime'] ?? json['closeTime']),
    paymentMethod: '${json['PaymentMethod'] ?? json['paymentMethod'] ?? ''}',
  );
}

class OpsSummary {
  const OpsSummary({
    required this.openTables,
    required this.newOrders,
    required this.preparing,
    required this.ready,
    required this.waitingCalls,
  });

  final int openTables;
  final int newOrders;
  final int preparing;
  final int ready;
  final int waitingCalls;

  factory OpsSummary.fromJson(Map<String, dynamic> json) => OpsSummary(
    openTables: _number(json['openTables']).toInt(),
    newOrders: _number(json['newOrders']).toInt(),
    preparing: _number(json['preparing']).toInt(),
    ready: _number(json['ready']).toInt(),
    waitingCalls: _number(json['waitingCalls']).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'openTables': openTables,
    'newOrders': newOrders,
    'preparing': preparing,
    'ready': ready,
    'waitingCalls': waitingCalls,
  };
}

class OpsDashboard {
  const OpsDashboard({
    required this.user,
    required this.view,
    required this.items,
    required this.sessions,
    required this.calls,
    required this.summary,
  });

  final StaffSession user;
  final String view;
  final List<OpsOrderItem> items;
  final List<OpsSession> sessions;
  final List<OpsCall> calls;
  final OpsSummary summary;

  factory OpsDashboard.fromJson(Map<String, dynamic> json) => OpsDashboard(
    user: StaffSession.fromJson(_map(json['user'])),
    view: '${json['view'] ?? ''}',
    items: ((json['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => OpsOrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    sessions: ((json['sessions'] as List?) ?? const [])
        .whereType<Map>()
        .map(
          (session) => OpsSession.fromJson(Map<String, dynamic>.from(session)),
        )
        .toList(),
    calls: ((json['calls'] as List?) ?? const [])
        .whereType<Map>()
        .map((call) => OpsCall.fromJson(Map<String, dynamic>.from(call)))
        .toList(),
    summary: OpsSummary.fromJson(_map(json['summary'])),
  );
}

class Receipt {
  const Receipt({
    required this.restaurantName,
    required this.table,
    required this.session,
    required this.items,
    required this.payment,
    required this.generatedAt,
  });

  final String restaurantName;
  final String table;
  final OrderSession session;
  final List<OrderItem> items;
  final Map<String, dynamic>? payment;
  final DateTime generatedAt;

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    restaurantName: '${json['restaurantName'] ?? ''}',
    table: '${json['table'] ?? ''}',
    session: OrderSession.fromJson(_map(json['session'])),
    items: ((json['items'] as List?) ?? const [])
        .whereType<Map>()
        .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item)))
        .toList(),
    payment: json['payment'] is Map
        ? Map<String, dynamic>.from(json['payment'] as Map)
        : null,
    generatedAt:
        DateTime.tryParse('${json['generatedAt'] ?? ''}') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
  );
}

class AdminData {
  const AdminData({
    required this.user,
    required this.settings,
    required this.entities,
    required this.summary,
  });

  final StaffSession user;
  final Map<String, dynamic> settings;
  final Map<String, List<Map<String, dynamic>>> entities;
  final Map<String, dynamic> summary;

  List<Map<String, dynamic>> entity(String sheet) =>
      entities[sheet] ?? const [];

  factory AdminData.fromJson(Map<String, dynamic> json) {
    const sheets = [
      'Tables',
      'Categories',
      'MenuItems',
      'Options',
      'AddOns',
      'Promotions',
      'Staff',
    ];
    return AdminData(
      user: StaffSession.fromJson(_map(json['user'])),
      settings: _map(json['settings']),
      entities: {
        for (final sheet in sheets)
          sheet: ((json[sheet] as List?) ?? const [])
              .whereType<Map>()
              .map((row) => Map<String, dynamic>.from(row))
              .toList(),
      },
      summary: _map(json['summary']),
    );
  }
}

num _number(Object? value) =>
    value is num ? value : num.tryParse('$value') ?? 0;

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

DateTime? _date(Object? value) =>
    value == null || '$value'.isEmpty ? null : DateTime.tryParse('$value');
