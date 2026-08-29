class Option {
  const Option({
    required this.optionId,
    required this.itemId,
    required this.groupName,
    required this.label,
    required this.price,
    required this.inputType,
    required this.isRequired,
  });

  final String optionId;
  final String itemId;
  final String groupName;
  final String label;
  final num price;
  final String inputType;
  final bool isRequired;

  factory Option.fromJson(Map<String, dynamic> json) => Option(
    optionId: '${json['OptionID'] ?? ''}',
    itemId: '${json['ItemID'] ?? ''}',
    groupName: '${json['GroupName'] ?? 'ตัวเลือก'}',
    label: '${json['Label'] ?? ''}',
    price: _number(json['Price']),
    inputType: '${json['InputType'] ?? 'CHECKBOX'}'.toUpperCase(),
    isRequired: _truthy(json['IsRequired']),
  );

  Map<String, dynamic> toJson() => {
    'OptionID': optionId,
    'ItemID': itemId,
    'GroupName': groupName,
    'Label': label,
    'Price': price,
    'InputType': inputType,
    'IsRequired': isRequired,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;

bool _truthy(Object? value) =>
    value == true || '$value'.toLowerCase() == 'true' || '$value' == '1';
