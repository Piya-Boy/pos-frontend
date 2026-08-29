class OrderSession {
  const OrderSession({
    required this.sessionId,
    required this.tableId,
    required this.status,
    required this.subtotal,
    required this.discount,
    required this.serviceCharge,
    required this.vat,
    required this.total,
    required this.promoCode,
  });

  final String sessionId;
  final String tableId;
  final String status;
  final num subtotal;
  final num discount;
  final num serviceCharge;
  final num vat;
  final num total;
  final String promoCode;

  factory OrderSession.fromJson(Map<String, dynamic> json) => OrderSession(
    sessionId: '${json['SessionID'] ?? ''}',
    tableId: '${json['TableID'] ?? ''}',
    status: '${json['Status'] ?? ''}',
    subtotal: _number(json['Subtotal']),
    discount: _number(json['Discount']),
    serviceCharge: _number(json['ServiceCharge']),
    vat: _number(json['Vat']),
    total: _number(json['Total']),
    promoCode: '${json['PromoCode'] ?? ''}',
  );

  Map<String, dynamic> toJson() => {
    'SessionID': sessionId,
    'TableID': tableId,
    'Status': status,
    'Subtotal': subtotal,
    'Discount': discount,
    'ServiceCharge': serviceCharge,
    'Vat': vat,
    'Total': total,
    'PromoCode': promoCode,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
