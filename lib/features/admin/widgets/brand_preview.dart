import 'package:flutter/material.dart';

class BrandPreview extends StatelessWidget {
  const BrandPreview({super.key, required this.settings});

  final Map<String, String> settings;

  @override
  Widget build(BuildContext context) {
    final primary = _color(settings['PrimaryColor'], const Color(0xFFB7442B));
    final background = _color(
      settings['BackgroundColor'],
      const Color(0xFFFBF7F0),
    );
    final surface = _color(settings['SurfaceColor'], Colors.white);
    final text = _color(settings['TextColor'], const Color(0xFF211E1B));
    return Container(
      key: const Key('brand-preview'),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ตัวอย่าง',
              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  child: Text(settings['BrandLogoText']?.isEmpty ?? true
                      ? 'ผ'
                      : settings['BrandLogoText']!),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings['AppName']?.isEmpty ?? true
                            ? 'ชื่อระบบ'
                            : settings['AppName']!,
                        style: TextStyle(color: text, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        settings['RestaurantName']?.isEmpty ?? true
                            ? 'ชื่อร้าน'
                            : settings['RestaurantName']!,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withValues(alpha: .35)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    settings['HeroKicker'] ?? '',
                    style: TextStyle(color: primary, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings['HeroTitle']?.isEmpty ?? true
                        ? 'ข้อความหลักหน้าเมนู'
                        : settings['HeroTitle']!,
                    style: TextStyle(color: text, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      child: Text(settings['HeroBadgeText']?.isEmpty ?? true
                          ? 'อร่อย'
                          : settings['HeroBadgeText']!),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _color(String? value, Color fallback) {
    final normalized = value?.trim() ?? '';
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(normalized)) return fallback;
    return Color(int.parse('FF${normalized.substring(1)}', radix: 16));
  }
}
