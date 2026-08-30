import 'package:flutter/material.dart';

import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/models/category.dart';

class MenuToolbar extends StatelessWidget {
  const MenuToolbar({
    super.key,
    required this.categories,
    required this.activeCategory,
    required this.onSearch,
    required this.onSelectCategory,
  });

  final List<Category> categories;
  final String activeCategory;
  final ValueChanged<String> onSearch;
  final ValueChanged<String> onSelectCategory;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DecoratedBox(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          boxShadow: PhiusTokens.shadowSm,
        ),
        child: TextField(
          onChanged: onSearch,
          decoration: const InputDecoration(
            prefixIcon: Center(child: Text('⌕', style: TextStyle(fontSize: 24))),
            prefixIconConstraints: BoxConstraints.tightFor(width: 44, height: 46),
            hintText: 'ค้นหาเมนูที่อยากทาน',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: PhiusTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
              borderSide: BorderSide(color: PhiusTokens.primary, width: 2),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip('ALL', '🍽️ ทั้งหมด'),
            ...categories.map(
              (category) => _chip(
                category.categoryId,
                '${category.icon} ${category.name}',
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _chip(String id, String label) {
    final selected = activeCategory == id;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          softWrap: false,
          overflow: TextOverflow.visible,
          maxLines: 1,
          style: TextStyle(
            color: selected ? Colors.white : PhiusTokens.muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        showCheckmark: false,
        selected: selected,
        backgroundColor: PhiusTokens.surface,
        selectedColor: PhiusTokens.primary,
        side: BorderSide(
          color: selected ? PhiusTokens.primary : PhiusTokens.border,
        ),
        shape: const StadiumBorder(),
        onSelected: (_) => onSelectCategory(id),
      ),
    );
  }
}
