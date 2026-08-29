import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos_frontend/core/theme/tokens.dart';

class CustomerHero extends StatelessWidget {
  const CustomerHero({super.key, required this.kicker, required this.title, required this.badgeText, required this.badgeImageUrl});
  final String kicker, title, badgeText, badgeImageUrl;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(24), gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [PhiusTokens.primaryDark, PhiusTokens.primary, PhiusTokens.primaryLight], stops: [0, .6, 1])),
    child: Row(children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kicker, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, height: 1.25, fontWeight: FontWeight.w700))])),
      Transform.rotate(angle: -9 * math.pi / 180, child: Container(width: 86, height: 86, alignment: Alignment.center, clipBehavior: Clip.antiAlias, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: badgeImageUrl.isEmpty ? Text(badgeText, style: const TextStyle(color: PhiusTokens.primaryDark, fontSize: 20, fontWeight: FontWeight.w700)) : CachedNetworkImage(imageUrl: badgeImageUrl, fit: BoxFit.cover, errorWidget: (_, _, _) => Text(badgeText, style: const TextStyle(color: PhiusTokens.primaryDark, fontSize: 20, fontWeight: FontWeight.w700))))),
    ]),
  );
}
