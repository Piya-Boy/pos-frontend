import 'dart:convert';

class OrderItem {
  const OrderItem({
    required this.orderItemId,
    required this.sessionId,
    required this.itemId,
    required this.itemName,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
    required this.note,
    required this.status,
    required this.options,
    required this.addOns,
  });

  final String orderItemId;
  final String sessionId;
  final String itemId;
  final String itemName;
  final int qty;
  final num unitPrice;
  final num lineTotal;
  final String note;
  final String status;
  final List<Map<String, dynamic>> options;
  final List<Map<String, dynamic>> addOns;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    orderItemId: '${json['OrderItemID'] ?? ''}',
    sessionId: '${json['SessionID'] ?? ''}',
    itemId: '${json['ItemID'] ?? ''}',
    itemName: '${json['ItemName'] ?? ''}',
    qty: _number(json['Qty']).toInt(),
    unitPrice: _number(json['UnitPrice']),
    lineTotal: _number(json['LineTotal']),
    note: '${json['Note'] ?? ''}',
    status: '${json['Status'] ?? ''}',
    options: _jsonList(json['options'] ?? json['OptionsJSON']),
    addOns: _jsonList(json['addOns'] ?? json['AddOnsJSON']),
  );

  Map<String, dynamic> toJson() => {
    'OrderItemID': orderItemId,
    'SessionID': sessionId,
    'ItemID': itemId,
    'ItemName': itemName,
    'Qty': qty,
    'UnitPrice': unitPrice,
    'LineTotal': lineTotal,
    'Note': note,
    'Status': status,
    'OptionsJSON': jsonEncode(options),
    'AddOnsJSON': jsonEncode(addOns),
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;

List<Map<String, dynamic>> _jsonList(Object? value) {
  final decoded = value is String ? jsonDecode(value) : value;
  return decoded is List
      ? decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList()
      : const [];
}
