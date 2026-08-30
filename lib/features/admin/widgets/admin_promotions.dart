import 'package:flutter/material.dart';

import '../../../state/admin_controller.dart';
import 'admin_entity_form.dart';
import 'admin_entity_panel.dart';

class AdminPromotions extends StatelessWidget {
  const AdminPromotions({
    super.key,
    required this.rows,
    required this.controller,
  });
  final List<Map<String, dynamic>> rows;
  final AdminController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: AdminEntityPanel(
      title: 'โปรโมชั่น',
      entity: 'promotion',
      idKey: 'PromoID',
      rows: rows,
      controller: controller,
      fields: const [
        AdminField('Name', 'ชื่อโปรโมชั่น', required: true),
        AdminField('Code', 'โค้ด', required: true),
        AdminField(
          'DiscountType',
          'ประเภทส่วนลด',
          required: true,
          type: AdminFieldType.select,
          options: ['PERCENT', 'FIXED'],
        ),
        AdminField('DiscountValue', 'มูลค่าส่วนลด', required: true, type: AdminFieldType.number),
        AdminField('MinSpend', 'ยอดขั้นต่ำ', type: AdminFieldType.number),
        AdminField('StartDate', 'วันเริ่ม', required: true),
        AdminField('EndDate', 'วันสิ้นสุด', required: true),
        AdminField('BannerImage', 'URL แบนเนอร์', type: AdminFieldType.imageUrl),
        AdminField(
          'Status',
          'สถานะ',
          required: true,
          type: AdminFieldType.select,
          options: ['ACTIVE', 'INACTIVE'],
        ),
      ],
    ),
  );
}
