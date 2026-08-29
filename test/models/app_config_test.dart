import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/models/app_config.dart';

void main() {
  test('maps public bootstrap branding fields', () {
    final config = AppConfig.fromJson({
      'appName': 'Phius Order',
      'restaurantName': 'Phius Thai Kitchen',
      'logoText': 'ผ',
      'logoUrl': 'https://example.test/logo.png',
    });

    expect(config.appName, 'Phius Order');
    expect(config.restaurantName, 'Phius Thai Kitchen');
    expect(config.logoText, 'ผ');
    expect(config.logoUrl, 'https://example.test/logo.png');
  });
}
