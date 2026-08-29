import 'promotion.dart';

class Totals {
  const Totals({
    required this.subtotal,
    required this.discount,
    required this.serviceCharge,
    required this.vat,
    required this.total,
    this.promo,
  });

  final num subtotal;
  final num discount;
  final num serviceCharge;
  final num vat;
  final num total;
  final Promotion? promo;

  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
    subtotal: _number(json['subtotal'] ?? json['Subtotal']),
    discount: _number(json['discount'] ?? json['Discount']),
    serviceCharge: _number(json['serviceCharge'] ?? json['ServiceCharge']),
    vat: _number(json['vat'] ?? json['Vat']),
    total: _number(json['total'] ?? json['Total']),
    promo: json['promo'] is Map
        ? Promotion.fromJson(Map<String, dynamic>.from(json['promo'] as Map))
        : null,
  );

  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'discount': discount,
    'serviceCharge': serviceCharge,
    'vat': vat,
    'total': total,
    'promo': promo?.toJson(),
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
