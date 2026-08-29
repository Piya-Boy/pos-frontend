class AddOn {
  const AddOn({
    required this.addOnId,
    required this.name,
    required this.price,
    required this.linkedItemId,
    required this.linkedCategoryId,
  });

  final String addOnId;
  final String name;
  final num price;
  final String linkedItemId;
  final String linkedCategoryId;

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    addOnId: '${json['AddOnID'] ?? ''}',
    name: '${json['Name'] ?? ''}',
    price: _number(json['Price']),
    linkedItemId: '${json['LinkedItemID'] ?? ''}',
    linkedCategoryId: '${json['LinkedCategoryID'] ?? ''}',
  );

  Map<String, dynamic> toJson() => {
    'AddOnID': addOnId,
    'Name': name,
    'Price': price,
    'LinkedItemID': linkedItemId,
    'LinkedCategoryID': linkedCategoryId,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
