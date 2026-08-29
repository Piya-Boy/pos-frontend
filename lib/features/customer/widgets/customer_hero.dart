import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pos_frontend/core/theme/tokens.dart';

class CustomerHero extends StatelessWidget {
  const CustomerHero({
    super.key,
    required this.kicker,
    required this.title,
    required this.badgeText,
    required this.badgeImageUrl,
  });
  final String kicker, title, badgeText, badgeImageUrl;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final tiny = constraints.maxWidth <= 430;
      final wide = constraints.maxWidth >= 640;
      final emblemSize = tiny ? 88.0 : 120.0;
      return Container(
        margin: const EdgeInsets.only(top: 16),
        constraints: BoxConstraints(
          minHeight: tiny
              ? 205
              : wide
              ? 270
              : 230,
        ),
        padding: EdgeInsets.all(
          wide
              ? 38
              : tiny
              ? 22
              : 30,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              PhiusTokens.primaryDark,
              PhiusTokens.primary,
              PhiusTokens.primaryLight,
            ],
            stops: [0, .6, 1],
          ),
          boxShadow: PhiusTokens.shadowMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    kicker,
                    style: const TextStyle(
                      color: Color(0xFFFFD9CA),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: wide ? 46 : 29,
                      height: 1.18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 18),
            Transform.rotate(
              angle: -9 * math.pi / 180,
              child: Container(
                width: emblemSize,
                height: emblemSize,
                alignment: Alignment.center,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: badgeImageUrl.isEmpty
                      ? const Color(0x1FFFFFFF)
                      : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x47FFFFFF),
                    width: badgeImageUrl.isEmpty ? 1 : 3,
                  ),
                ),
                child: badgeImageUrl.isEmpty
                    ? Text(
                        badgeText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: tiny ? 17 : 22,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: badgeImageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Text(
                          badgeText,
                          style: TextStyle(
                            color: PhiusTokens.primaryDark,
                            fontSize: tiny ? 17 : 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
