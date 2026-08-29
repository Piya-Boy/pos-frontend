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
                  top: 8,
                  left: 8,
                  child: Text(
                    widget.item.available ? 'เมนูยอดนิยม' : 'หมดชั่วคราว',
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: widget.item.available
                          ? PhiusTokens.green
                          : PhiusTokens.ink,
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
                Text(
                  widget.item.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(
                  widget.item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: PhiusTokens.muted),
                ),
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
