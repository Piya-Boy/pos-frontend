import 'call_log.dart';
import 'order_item.dart';
import 'order_session.dart';

class SessionBundle {
  const SessionBundle({
    required this.session,
    required this.items,
    required this.calls,
  });

  final OrderSession session;
  final List<OrderItem> items;
  final List<CallLog> calls;

  factory SessionBundle.fromJson(Map<String, dynamic> json) => SessionBundle(
    session: OrderSession.fromJson(Map<String, dynamic>.from(json['session'] as Map)),
    items: ((json['items'] as List?) ?? const [])
        .map((item) => OrderItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(),
    calls: ((json['calls'] as List?) ?? const [])
        .map((call) => CallLog.fromJson(Map<String, dynamic>.from(call as Map)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'session': session.toJson(),
    'items': items.map((item) => item.toJson()).toList(),
    'calls': calls.map((call) => call.toJson()).toList(),
  };
}
