import 'add_on.dart';
import 'option.dart';

class CartLine {
  const CartLine({
    required this.lineId,
    required this.itemId,
    required this.name,
    required this.image,
    required this.basePrice,
    required this.qty,
    required this.optionIds,
    required this.addOnIds,
    required this.options,
    required this.addOns,
    required this.note,
    required this.unitPrice,
  });

  final String lineId;
  final String itemId;
  final String name;
  final String image;
  final num basePrice;
  final int qty;
  final List<String> optionIds;
  final List<String> addOnIds;
  final List<Option> options;
  final List<AddOn> addOns;
  final String note;
  final num unitPrice;

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    lineId: '${json['lineId'] ?? ''}',
    itemId: '${json['itemId'] ?? ''}',
    name: '${json['name'] ?? ''}',
    image: '${json['image'] ?? ''}',
    basePrice: _number(json['basePrice']),
    qty: _number(json['qty']).toInt(),
    optionIds: ((json['optionIds'] as List?) ?? const [])
        .map((optionId) => '$optionId')
        .toList(),
    addOnIds: ((json['addOnIds'] as List?) ?? const [])
        .map((addOnId) => '$addOnId')
        .toList(),
    options: ((json['options'] as List?) ?? const [])
        .map((option) => Option.fromJson(Map<String, dynamic>.from(option as Map)))
        .toList(),
    addOns: ((json['addOns'] as List?) ?? const [])
        .map((addOn) => AddOn.fromJson(Map<String, dynamic>.from(addOn as Map)))
        .toList(),
    note: '${json['note'] ?? ''}',
    unitPrice: _number(json['unitPrice']),
  );

  Map<String, dynamic> toJson() => {
    'lineId': lineId,
    'itemId': itemId,
    'name': name,
    'image': image,
    'basePrice': basePrice,
    'qty': qty,
    'optionIds': optionIds,
    'addOnIds': addOnIds,
    'options': options.map((option) => option.toJson()).toList(),
    'addOns': addOns.map((addOn) => addOn.toJson()).toList(),
    'note': note,
    'unitPrice': unitPrice,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
