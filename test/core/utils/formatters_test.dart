import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/utils/formatters.dart';

void main() {
  test('formatMoney matches th-TH baht (maxFractionDigits 2)', () {
    expect(formatMoney(85), '฿85');
    expect(formatMoney(1234), '฿1,234');
    expect(formatMoney(0), '฿0');
    expect(formatMoney(12.5), '฿12.50');
    expect(formatMoney(12), '฿12');
  });

  test('placeholderImage builds placehold.co url', () {
    expect(
      placeholderImage('อาหารไทย'),
      startsWith('https://placehold.co/900x700/F4EEE5/706A63?text='),
    );
  });
}
