import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/core/theme/tokens.dart';

void main() {
  test('core colors match cp-pos Styles.html :root', () {
    expect(PhiusTokens.primary, const Color(0xFFB7442B));
    expect(PhiusTokens.primaryDark, const Color(0xFF8F301E));
    expect(PhiusTokens.bg, const Color(0xFFFBF7F0));
    expect(PhiusTokens.green, const Color(0xFF2F6B4F));
    expect(PhiusTokens.ink, const Color(0xFF211E1B));
  });

  test('radius + typography constants', () {
    expect(PhiusTokens.radiusSm, 12.0);
    expect(PhiusTokens.radius, 18.0);
    expect(PhiusTokens.radiusLg, 24.0);
    expect(PhiusTokens.baseFontSize, 15.0);
  });
}
