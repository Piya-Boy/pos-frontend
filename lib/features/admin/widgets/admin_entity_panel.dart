import 'package:flutter/material.dart';

import '../../../core/api/app_error.dart';
import '../../../state/admin_controller.dart';
import 'admin_entity_form.dart';

class AdminEntityPanel extends StatelessWidget {
  const AdminEntityPanel({
    super.key,
    required this.title,
    required this.entity,
    required this.idKey,
    required this.rows,
    required this.fields,
    required this.controller,
  });

  final String title;
  final String entity;
  final String idKey;
  final List<Map<String, dynamic>> rows;
  final List<AdminField> fields;
  final AdminController controller;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          FilledButton(
            onPressed: () => _openForm(context, const {}),
            child: const Text('เพิ่มข้อมูล'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('ยังไม่มีข้อมูล')),
        ),
      ...rows.map(
        (row) => Card(
          child: ListTile(
            title: Text('${row['Name'] ?? row['Code'] ?? row[idKey] ?? ''}'),
            subtitle: Text('${row[idKey] ?? ''} · ${row['Status'] ?? ''}'),
            trailing: Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => _openForm(context, row),
                  child: const Text('แก้ไข'),
                ),
                TextButton(
                  onPressed: () => _archive(context, '${row[idKey] ?? ''}'),
                  child: const Text('ปิดรายการ'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Future<void> _openForm(BuildContext context, Map<String, dynamic> initial) =>
      showDialog<void>(
        context: context,
        builder: (_) => AdminEntityForm(
          title: initial.isEmpty ? 'เพิ่มข้อมูล' : 'แก้ไขข้อมูล',
          fields: fields,
          initial: initial,
          onSave: (data) => controller.saveEntity(entity, data),
          onUploadImage: controller.uploadImage,
        ),
      );

  Future<void> _archive(BuildContext context, String id) async {
    try {
      await controller.archiveEntity(entity, id);
    } on AppError catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ไม่สามารถปิดรายการได้')));
      }
    }
  }
}
