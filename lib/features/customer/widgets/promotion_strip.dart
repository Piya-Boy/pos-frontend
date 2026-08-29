import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/models/promotion.dart';

class PromotionStrip extends StatelessWidget {
  const PromotionStrip({super.key, required this.promotions});
  final List<Promotion> promotions;

  @override
  Widget build(BuildContext context) => promotions.isEmpty
      ? const SizedBox.shrink()
      : SizedBox(
          height: 144,
          child: ListView.separated(
            physics: const PageScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: promotions.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, index) =>
                _PromotionCard(promotion: promotions[index]),
          ),
        );
}

class _PromotionCard extends StatelessWidget {
  const _PromotionCard({required this.promotion});
  final Promotion promotion;

  @override
  Widget build(BuildContext context) => Container(
    width: 280,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: PhiusTokens.green,
      borderRadius: BorderRadius.circular(PhiusTokens.radius),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (promotion.bannerImage.isNotEmpty)
          CachedNetworkImage(
            imageUrl: promotion.bannerImage,
            fit: BoxFit.cover,
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xC9211E1B), Color(0x00211E1B)],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                promotion.code,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                promotion.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  promotion.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
