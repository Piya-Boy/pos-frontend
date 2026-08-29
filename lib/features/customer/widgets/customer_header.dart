import 'package:flutter/material.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/features/shared/widgets/brand_mark.dart';
import 'package:pos_frontend/features/shared/widgets/eyebrow_text.dart';

class CustomerHeader extends StatelessWidget {
  const CustomerHeader({super.key, required this.name, required this.tagline, required this.tableName, this.onTapTablePill});

  final String name;
  final String tagline;
  final String tableName;
  final VoidCallback? onTapTablePill;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      const BrandMark(small: true),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (tagline.isNotEmpty) EyebrowText(tagline), Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700, color: PhiusTokens.ink))])),
      Semantics(button: true, label: 'โต๊ะ $tableName', child: InkWell(onTap: onTapTablePill, borderRadius: BorderRadius.circular(14), child: Container(
        constraints: const BoxConstraints(minWidth: 76, minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: PhiusTokens.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: PhiusTokens.border), boxShadow: PhiusTokens.shadowSm),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [const Text('โต๊ะ', style: TextStyle(fontSize: 10, color: PhiusTokens.muted)), Text(tableName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))]),
      ))),
    ],
  );
}
