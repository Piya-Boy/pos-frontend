import 'add_on.dart';
import 'option.dart';

class MenuItem {
  const MenuItem({
    required this.itemId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.isPopular,
    required this.available,
    required this.options,
    required this.addOns,
  });

  final String itemId;
  final String categoryId;
  final String name;
  final String description;
  final String imageUrl;
  final num price;
  final bool isPopular;
  final bool available;
  final List<Option> options;
  final List<AddOn> addOns;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    itemId: '${json['ItemID'] ?? ''}',
    categoryId: '${json['CategoryID'] ?? ''}',
    name: '${json['Name'] ?? ''}',
    description: '${json['Description'] ?? ''}',
    imageUrl: '${json['ImageURL'] ?? ''}',
    price: _number(json['Price']),
    isPopular: _truthy(json['IsPopular']),
    available: json['available'] == null ? true : _truthy(json['available']),
    options: ((json['options'] as List?) ?? const [])
        .map((value) => Option.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList(),
    addOns: ((json['addOns'] as List?) ?? const [])
        .map((value) => AddOn.fromJson(Map<String, dynamic>.from(value as Map)))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'ItemID': itemId,
    'CategoryID': categoryId,
    'Name': name,
    'Description': description,
    'ImageURL': imageUrl,
    'Price': price,
    'IsPopular': isPopular,
    'available': available,
    'options': options.map((option) => option.toJson()).toList(),
    'addOns': addOns.map((addOn) => addOn.toJson()).toList(),
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;

bool _truthy(Object? value) =>
    value == true || '$value'.toLowerCase() == 'true' || '$value' == '1';
