class Promotion {
  const Promotion({
    required this.promoId,
    required this.code,
    required this.name,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minSpend,
    required this.bannerImage,
  });

  final String promoId;
  final String code;
  final String name;
  final String description;
  final String discountType;
  final num discountValue;
  final num minSpend;
  final String bannerImage;

  factory Promotion.fromJson(Map<String, dynamic> json) => Promotion(
    promoId: '${json['PromoID'] ?? ''}',
    code: '${json['Code'] ?? ''}',
    name: '${json['Name'] ?? ''}',
    description: '${json['Description'] ?? ''}',
    discountType: '${json['DiscountType'] ?? ''}',
    discountValue: _number(json['DiscountValue']),
    minSpend: _number(json['MinSpend']),
    bannerImage: '${json['BannerImage'] ?? ''}',
  );

  Map<String, dynamic> toJson() => {
    'PromoID': promoId,
    'Code': code,
    'Name': name,
    'Description': description,
    'DiscountType': discountType,
    'DiscountValue': discountValue,
    'MinSpend': minSpend,
    'BannerImage': bannerImage,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
