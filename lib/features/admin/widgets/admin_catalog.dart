import 'package:flutter/material.dart';

import '../../../state/admin_controller.dart';
import 'admin_entity_form.dart';
import 'admin_entity_panel.dart';

class AdminCatalog extends StatelessWidget {
  const AdminCatalog({
    super.key,
    required this.categories,
    required this.menu,
    required this.options,
    required this.addOns,
    required this.controller,
  });
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> menu;
  final List<Map<String, dynamic>> options;
  final List<Map<String, dynamic>> addOns;
  final AdminController controller;

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      AdminEntityPanel(
        title: 'หมวดหมู่',
        entity: 'category',
        idKey: 'CategoryID',
        rows: categories,
        controller: controller,
        fields: const [
          AdminField('Name', 'ชื่อหมวด', required: true),
          AdminField('Icon', 'ไอคอน'),
          AdminField('SortOrder', 'ลำดับ', keyboardType: TextInputType.number),
          AdminField(
            'Status',
            'สถานะ',
            required: true,
            type: AdminFieldType.select,
            options: ['ACTIVE', 'INACTIVE'],
          ),
        ],
      ),
      const SizedBox(height: 24),
      AdminEntityPanel(
        title: 'รายการอาหาร',
        entity: 'menu',
        idKey: 'ItemID',
        rows: menu,
        controller: controller,
        fields: const [
          AdminField('Name', 'ชื่อเมนู', required: true),
          AdminField('CategoryID', 'รหัสหมวดหมู่', required: true),
          AdminField(
            'Price',
            'ราคา',
            required: true,
            type: AdminFieldType.number,
          ),
          AdminField('Description', 'รายละเอียด', type: AdminFieldType.multiline),
          AdminField('ImageURL', 'URL รูปภาพ', type: AdminFieldType.imageUrl),
          AdminField('SortOrder', 'ลำดับ', type: AdminFieldType.number),
          AdminField('IsPopular', 'เมนูแนะนำ', type: AdminFieldType.toggle),
          AdminField(
            'Status',
            'สถานะ',
            required: true,
            type: AdminFieldType.select,
            options: ['ACTIVE', 'INACTIVE', 'SOLD_OUT'],
          ),
        ],
      ),
      const SizedBox(height: 24),
      AdminEntityPanel(
        title: 'ตัวเลือกเมนู',
        entity: 'option',
        idKey: 'OptionID',
        rows: options,
        controller: controller,
        fields: const [
          AdminField('ItemID', 'รหัสเมนู', required: true),
          AdminField('GroupName', 'กลุ่มตัวเลือก', required: true),
          AdminField('Label', 'ตัวเลือก', required: true),
          AdminField('Price', 'ราคาเพิ่ม', type: AdminFieldType.number),
          AdminField(
            'InputType',
            'รูปแบบ',
            required: true,
            type: AdminFieldType.select,
            options: ['RADIO', 'CHECKBOX'],
          ),
          AdminField('IsRequired', 'จำเป็นต้องเลือก', type: AdminFieldType.toggle),
          AdminField('SortOrder', 'ลำดับ', type: AdminFieldType.number),
          AdminField(
            'Status',
            'สถานะ',
            required: true,
            type: AdminFieldType.select,
            options: ['ACTIVE', 'INACTIVE'],
          ),
        ],
      ),
      const SizedBox(height: 24),
      AdminEntityPanel(
        title: 'Add-on',
        entity: 'addon',
        idKey: 'AddOnID',
        rows: addOns,
        controller: controller,
        fields: const [
          AdminField('Name', 'ชื่อ Add-on', required: true),
          AdminField('Price', 'ราคาเพิ่ม', type: AdminFieldType.number),
          AdminField('LinkedItemID', 'รหัสเมนู'),
          AdminField('LinkedCategoryID', 'รหัสหมวดหมู่'),
          AdminField('SortOrder', 'ลำดับ', type: AdminFieldType.number),
          AdminField(
            'Status',
            'สถานะ',
            required: true,
            type: AdminFieldType.select,
            options: ['ACTIVE', 'INACTIVE'],
          ),
        ],
      ),
    ],
  );
}
