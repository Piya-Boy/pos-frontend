import 'package:flutter/material.dart';
import 'package:pos_frontend/core/theme/tokens.dart';

class StatusMeta {
  const StatusMeta(
    this.label,
    this.icon,
    this.dotColor,
    this.pillFg,
    this.pillBg,
  );
  final String label;
  final String icon;
  final Color dotColor;
  final Color pillFg;
  final Color pillBg;
}

StatusMeta statusMeta(String status) => switch (status) {
  'PREPARING' => const StatusMeta(
    'กำลังปรุง',
    '🔥',
    PhiusTokens.primary,
    PhiusTokens.primaryDark,
    PhiusTokens.redSoft,
  ),
  'READY' => const StatusMeta(
    'พร้อมเสิร์ฟ',
    '✓',
    PhiusTokens.green,
    PhiusTokens.green,
    PhiusTokens.greenSoft,
  ),
  'SERVED' => const StatusMeta(
    'เสิร์ฟแล้ว',
    '✓',
    PhiusTokens.green,
    PhiusTokens.green,
    PhiusTokens.greenSoft,
  ),
  _ => const StatusMeta(
    'ออเดอร์ใหม่',
    '●',
    PhiusTokens.saffron,
    Color(0xFF754707),
    PhiusTokens.saffronSoft,
  ),
};
