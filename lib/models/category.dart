class Category {
  const Category({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.sortOrder,
  });

  final String categoryId;
  final String name;
  final String icon;
  final int sortOrder;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    categoryId: '${json['CategoryID'] ?? ''}',
    name: '${json['Name'] ?? ''}',
    icon: '${json['Icon'] ?? ''}',
    sortOrder: _number(json['SortOrder']).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'CategoryID': categoryId,
    'Name': name,
    'Icon': icon,
    'SortOrder': sortOrder,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
