import 'package:flutter/material.dart';

import '../../../state/admin_controller.dart';
import 'admin_entity_form.dart';
import 'admin_entity_panel.dart';

class AdminStaff extends StatelessWidget {
  const AdminStaff({super.key, required this.rows, required this.controller});
  final List<Map<String, dynamic>> rows;
  final AdminController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: AdminEntityPanel(
      title: 'พนักงาน',
      entity: 'staff',
      idKey: 'StaffID',
      rows: rows,
      controller: controller,
      fields: const [
        AdminField('Name', 'ชื่อพนักงาน', required: true),
        AdminField(
          'Role',
          'บทบาท',
          required: true,
          type: AdminFieldType.select,
          options: ['ADMIN', 'KITCHEN', 'STAFF', 'CASHIER'],
        ),
        AdminField('PIN', 'PIN ใหม่', type: AdminFieldType.password),
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
