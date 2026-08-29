class AppConfig {
  const AppConfig({
    required this.name,
    required this.appName,
    required this.restaurantName,
    required this.tagline,
    required this.logoText,
    required this.logoUrl,
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
  final String appName;
  final String restaurantName;
  final String tagline;
  final String logoText;
  final String logoUrl;
  final String heroKicker;
  final String heroTitle;
  final String heroBadgeText;
  final String heroBadgeImageUrl;
  final String primaryColor;
  final String currency;
  final String currencySymbol;
  final int pollSeconds;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    name: '${json['name'] ?? json['restaurantName'] ?? json['appName'] ?? ''}',
    appName: '${json['appName'] ?? json['name'] ?? ''}',
    restaurantName: '${json['restaurantName'] ?? json['name'] ?? ''}',
    tagline: '${json['tagline'] ?? ''}',
    logoText: '${json['logoText'] ?? ''}',
    logoUrl: '${json['logoUrl'] ?? ''}',
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
    'appName': appName,
    'restaurantName': restaurantName,
    'tagline': tagline,
    'logoText': logoText,
    'logoUrl': logoUrl,
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

num _number(Object? value) =>
    value is num ? value : num.tryParse('$value') ?? 0;
