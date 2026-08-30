import 'package:flutter/material.dart';

import '../../../state/admin_controller.dart';
import 'brand_preview.dart';

class AdminSettings extends StatefulWidget {
  const AdminSettings({super.key, required this.settings, required this.controller});

  final Map<String, dynamic> settings;
  final AdminController controller;

  @override
  State<AdminSettings> createState() => _AdminSettingsState();
}

class _AdminSettingsState extends State<AdminSettings> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers = {
    for (final field in _fields)
      field.key: TextEditingController(text: '${widget.settings[field.key] ?? field.fallback}'),
  };
  bool _saving = false;
  String? _error;

  static const _fields = [
    _SettingsField('AppName', 'ชื่อระบบ', fallback: 'Phius Order', required: true),
    _SettingsField('RestaurantName', 'ชื่อร้าน', fallback: 'Phius Thai Kitchen', required: true),
    _SettingsField('RestaurantTagline', 'คำโปรยร้าน'),
    _SettingsField('BrandLogoText', 'ข้อความสำรองในโลโก้', fallback: 'ผ'),
    _SettingsField('BrandLogoURL', 'URL โลโก้', httpsUrl: true),
    _SettingsField('PrimaryColor', 'สีหลัก', fallback: '#B7442B', color: true),
    _SettingsField('SuccessColor', 'สีสถานะสำเร็จ', fallback: '#2F6B4F', color: true),
    _SettingsField('BackgroundColor', 'สีพื้นหลังแอป', fallback: '#FBF7F0', color: true),
    _SettingsField('SurfaceColor', 'สีพื้นผิวการ์ด', fallback: '#FFFFFF', color: true),
    _SettingsField('TextColor', 'สีข้อความหลัก', fallback: '#211E1B', color: true),
    _SettingsField('HeroKicker', 'ข้อความบรรทัดเล็ก', fallback: 'อิ่มอร่อยในแบบของคุณ'),
    _SettingsField('HeroTitle', 'ข้อความหลักหน้าเมนู', fallback: 'เลือกเมนูโปรด\nแล้วส่งตรงถึงครัว', required: true, multiline: true),
    _SettingsField('HeroBadgeText', 'ข้อความในวงกลม', fallback: 'อร่อย'),
    _SettingsField('HeroBadgeImageURL', 'URL รูปในวงกลม', httpsUrl: true),
    _SettingsField('CurrencySymbol', 'สัญลักษณ์สกุลเงิน', fallback: '฿'),
    _SettingsField('ServiceChargePercent', 'Service charge (%)', fallback: '0', number: true),
    _SettingsField('VatPercent', 'VAT (%)', fallback: '0', number: true),
    _SettingsField('OrderPollingSeconds', 'อัปเดตสถานะทุก (วินาที)', fallback: '10', number: true),
  ];

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final preview = BrandPreview(settings: _values);
      final form = Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'แบรนด์และหน้าตาร้าน',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text('การเปลี่ยนแปลงจะแสดงในหน้าหลัก หน้าเมนูลูกค้า และแอปที่ติดตั้ง'),
            const SizedBox(height: 16),
            ..._fields.map(_input),
            if (_error != null) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'กำลังบันทึก...' : 'บันทึกและนำไปใช้'),
            ),
          ],
        ),
      );
      return SingleChildScrollView(
        child: constraints.maxWidth >= 960
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: form), const SizedBox(width: 24), SizedBox(width: 340, child: preview)],
              )
            : Column(children: [form, const SizedBox(height: 24), preview]),
      );
    },
  );

  Map<String, String> get _values => {
    for (final entry in _controllers.entries) entry.key: entry.value.text,
  };

  Widget _input(_SettingsField field) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      key: Key('settings-${field.key}'),
      controller: _controllers[field.key],
      maxLines: field.multiline ? 3 : 1,
      keyboardType: field.number ? TextInputType.number : field.httpsUrl ? TextInputType.url : null,
      decoration: InputDecoration(labelText: field.label, helperText: field.color ? 'รูปแบบ #RRGGBB' : field.httpsUrl ? 'วาง URL รูปภาพ HTTPS' : null),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        final text = value?.trim() ?? '';
        final url = field.httpsUrl && text.isNotEmpty ? Uri.tryParse(text) : null;
        if (field.required && text.isEmpty) return 'กรุณาระบุ${field.label}';
        if (field.color && !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(text)) return 'รหัสสีต้องอยู่ในรูปแบบ #RRGGBB';
        if (field.httpsUrl &&
            text.isNotEmpty &&
            (url == null || !url.isScheme('https') || url.host.isEmpty)) {
          return 'URL ต้องขึ้นต้นด้วย https://';
        }
        return null;
      },
    ),
  );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _saving = true; _error = null; });
    try {
      await widget.controller.saveSettings(_values);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('บันทึกการตั้งค่าแล้ว')));
    } catch (_) {
      if (mounted) setState(() => _error = 'ไม่สามารถบันทึกการตั้งค่าได้');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _SettingsField {
  const _SettingsField(this.key, this.label, {this.fallback = '', this.required = false, this.color = false, this.httpsUrl = false, this.multiline = false, this.number = false});

  final String key;
  final String label;
  final String fallback;
  final bool required;
  final bool color;
  final bool httpsUrl;
  final bool multiline;
  final bool number;
}
