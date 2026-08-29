import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/core/utils/formatters.dart';
import 'package:pos_frontend/models/menu_item.dart';

class FoodCard extends StatefulWidget {
  const FoodCard({super.key, required this.item, required this.onQuickAdd});
  final MenuItem item;
  final VoidCallback onQuickAdd;
  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: widget.item.available ? 1 : .66,
    child: Container(
      decoration: BoxDecoration(
        color: PhiusTokens.surface,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: PhiusTokens.border),
        boxShadow: PhiusTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.15,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hovered = true),
                    onExit: (_) => setState(() => _hovered = false),
                    child: AnimatedScale(
                      scale: _hovered ? 1.04 : 1,
                      duration: const Duration(milliseconds: 180),
                      child: CachedNetworkImage(
                        imageUrl: widget.item.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => Image.network(
                          placeholderImage('อาหารไทย'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.item.isPopular || !widget.item.available)
                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.item.available
                          ? PhiusTokens.green
                          : PhiusTokens.ink,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      widget.item.available ? 'เมนูยอดนิยม' : 'หมดชั่วคราว',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 39),
                  child: Text(
                    widget.item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 36),
                  child: Text(
                    widget.item.description.isEmpty
                        ? 'เมนูแนะนำจากทางร้าน'
                        : widget.item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: PhiusTokens.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        formatMoney(widget.item.price),
                        style: const TextStyle(
                          color: PhiusTokens.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        tooltip: 'เลือก ${widget.item.name}',
                        onPressed: widget.item.available
                            ? widget.onQuickAdd
                            : null,
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(
                          backgroundColor: PhiusTokens.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: PhiusTokens.surfaceSoft,
                          disabledForegroundColor: PhiusTokens.muted,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
