import 'package:flutter/material.dart';
import 'package:pos_frontend/features/customer/widgets/food_card.dart';
import 'package:pos_frontend/models/menu_item.dart';

int menuColumns(double width) => width >= 900
    ? 4
    : width >= 640
    ? 3
    : 2;

class MenuSection extends StatelessWidget {
  const MenuSection({super.key, required this.items, required this.onQuickAdd});
  final List<MenuItem> items;
  final ValueChanged<MenuItem> onQuickAdd;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('เมนูของร้าน'),
      const Text(
        'เลือกอาหาร',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      Text(
        '${items.length} เมนู',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      ),
      LayoutBuilder(
        builder: (_, c) => items.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  '🍽️ ยังไม่พบเมนู\nลองเปลี่ยนคำค้นหรือเลือกหมวดอื่น',
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: menuColumns(c.maxWidth),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: .65,
                ),
                itemBuilder: (_, i) => FoodCard(
                  item: items[i],
                  onQuickAdd: () => onQuickAdd(items[i]),
                ),
              ),
      ),
    ],
  );
}
