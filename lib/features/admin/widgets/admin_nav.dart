import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';

const adminNavItems = <AdminNavItem>[
  AdminNavItem('overview', 'ภาพรวม'),
  AdminNavItem('tables', 'โต๊ะและ QR'),
  AdminNavItem('catalog', 'เมนูอาหาร'),
  AdminNavItem('promotions', 'โปรโมชั่น'),
  AdminNavItem('staff', 'พนักงาน'),
  AdminNavItem('settings', 'ตั้งค่าร้าน'),
];

class AdminNavItem {
  const AdminNavItem(this.id, this.label);

  final String id;
  final String label;
}

class AdminNav extends StatelessWidget {
  const AdminNav({super.key, required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'Admin Console',
        style: TextStyle(
          color: PhiusTokens.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 12),
      ...adminNavItems.map(
        (item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: TextButton(
            onPressed: () => onSelected(item.id),
            style: TextButton.styleFrom(
              alignment: Alignment.centerLeft,
              backgroundColor: item.id == selected
                  ? PhiusTokens.redSoft
                  : Colors.transparent,
            ),
            child: Text(item.label),
          ),
        ),
      ),
    ],
  );
}
