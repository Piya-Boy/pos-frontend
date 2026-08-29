class AppConfig {
  const AppConfig({
    required this.name,
    required this.tagline,
    required this.heroKicker,
    required this.heroTitle,
    required this.heroBadgeText,
    required this.heroBadgeImageUrl,
    required this.primaryColor,
    required this.currency,
    required this.currencySymbol,
    required this.pollSeconds,
  });

  final String name;
  final String tagline;
  final String heroKicker;
  final String heroTitle;
  final String heroBadgeText;
  final String heroBadgeImageUrl;
  final String primaryColor;
  final String currency;
  final String currencySymbol;
  final int pollSeconds;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    name: '${json['name'] ?? json['restaurantName'] ?? ''}',
    tagline: '${json['tagline'] ?? ''}',
    heroKicker: '${json['heroKicker'] ?? ''}',
    heroTitle: '${json['heroTitle'] ?? ''}',
    heroBadgeText: '${json['heroBadgeText'] ?? ''}',
    heroBadgeImageUrl: '${json['heroBadgeImageUrl'] ?? ''}',
    primaryColor: '${json['primaryColor'] ?? ''}',
    currency: '${json['currency'] ?? 'THB'}',
    currencySymbol: '${json['currencySymbol'] ?? '฿'}',
    pollSeconds: _number(json['pollSeconds']).toInt(),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'tagline': tagline,
    'heroKicker': heroKicker,
    'heroTitle': heroTitle,
    'heroBadgeText': heroBadgeText,
    'heroBadgeImageUrl': heroBadgeImageUrl,
    'primaryColor': primaryColor,
    'currency': currency,
    'currencySymbol': currencySymbol,
    'pollSeconds': pollSeconds,
  };
}

num _number(Object? value) => value is num ? value : num.tryParse('$value') ?? 0;
