import 'package:flutter/material.dart';

class PhiusTokens {
  PhiusTokens._();

  static const bg = Color(0xFFFBF7F0);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSoft = Color(0xFFF4EEE5);
  static const ink = Color(0xFF211E1B);
  static const muted = Color(0xFF706A63);
  static const primary = Color(0xFFB7442B);
  static const primaryDark = Color(0xFF8F301E);
  static const primaryLight = Color(0xFFCE735C);
  static const green = Color(0xFF2F6B4F);
  static const greenSoft = Color(0xFFE1EEE7);
  static const saffron = Color(0xFFD9911D);
  static const saffronSoft = Color(0xFFFFF0D2);
  static const redSoft = Color(0xFFFBE5DE);
  static const border = Color(0xFFE7DED2);

  static const shadowSm = [
    BoxShadow(offset: Offset(0, 3), blurRadius: 12, color: Color(0x123A271C)),
  ];
  static const shadowMd = [
    BoxShadow(
      offset: Offset(0, 14),
      blurRadius: 40,
      color: Color(0x213A271C),
    ),
  ];

  static const radiusSm = 12.0;
  static const radius = 18.0;
  static const radiusLg = 24.0;

  static const baseFontSize = 15.0;
  static const lineHeight = 1.55;
}
