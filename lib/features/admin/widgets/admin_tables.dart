import 'package:flutter/material.dart';

import '../../../state/admin_controller.dart';
import 'admin_entity_form.dart';
import 'admin_entity_panel.dart';

class AdminTables extends StatelessWidget {
  const AdminTables({super.key, required this.rows, required this.controller});
  final List<Map<String, dynamic>> rows;
  final AdminController controller;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AdminEntityPanel(
          title: 'รายการโต๊ะ',
          entity: 'table',
          idKey: 'TableID',
          rows: rows,
          controller: controller,
          fields: const [
            AdminField('Name', 'ชื่อโต๊ะ', required: true),
            AdminField('Zone', 'โซน'),
            AdminField(
              'Status',
              'สถานะ',
              required: true,
              type: AdminFieldType.select,
              options: ['AVAILABLE', 'DISABLED'],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'QR สำหรับสั่งอาหาร',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...rows.map(
          (table) => Card(
            child: ListTile(
              title: Text('${table['Name'] ?? table['TableID']}'),
              subtitle: Text(_orderUrl(table)),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 4,
                children: [
                  TextButton(
                    onPressed: () => _showQr(context, table),
                    child: const Text('ดู QR'),
                  ),
                  TextButton(
                    onPressed: () => _rotate(context, '${table['TableID']}'),
                    child: const Text('เปลี่ยน QR'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  static String _orderUrl(Map<String, dynamic> table) =>
      '${table['OrderURL'] ?? table['orderUrl'] ?? 'https://phius.order/?page=order&table=${table['Token'] ?? ''}'}';

  void _showQr(BuildContext context, Map<String, dynamic> table) {
    final orderUrl = _orderUrl(table);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('QR ${table['Name'] ?? ''}'),
        content: SelectableText(orderUrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Future<void> _rotate(BuildContext context, String tableId) async {
    try {
      await controller.rotateTableToken(tableId);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเปลี่ยน QR ขณะโต๊ะกำลังใช้งาน')),
        );
      }
    }
  }
}
