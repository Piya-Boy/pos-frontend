import 'package:flutter/material.dart';

enum AdminFieldType { text, number, select, color, multiline, imageUrl, password, toggle }

class AdminField {
  const AdminField(
    this.key,
    this.label, {
    this.required = false,
    this.keyboardType,
    this.type = AdminFieldType.text,
    this.options = const [],
  });

  final String key;
  final String label;
  final bool required;
  final TextInputType? keyboardType;
  final AdminFieldType type;
  final List<String> options;
}

class AdminEntityForm extends StatefulWidget {
  const AdminEntityForm({
    super.key,
    required this.title,
    required this.fields,
    required this.initial,
    required this.onSave,
  });

  final String title;
  final List<AdminField> fields;
  final Map<String, dynamic> initial;
  final Future<void> Function(Map<String, dynamic>) onSave;

  @override
  State<AdminEntityForm> createState() => _AdminEntityFormState();
}

class _AdminEntityFormState extends State<AdminEntityForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers = {
    for (final field in widget.fields)
      field.key: TextEditingController(
        text: '${widget.initial[field.key] ?? ''}',
      ),
  };
  late final Map<String, String?> _selected = {
    for (final field in widget.fields.where(
      (field) => field.type == AdminFieldType.select,
    ))
      field.key: '${widget.initial[field.key] ?? ''}'.isEmpty
          ? null
          : '${widget.initial[field.key]}',
  };
  late final Map<String, bool> _toggles = {
    for (final field in widget.fields.where(
      (field) => field.type == AdminFieldType.toggle,
    ))
      field.key: widget.initial[field.key] == true ||
          '${widget.initial[field.key]}'.toLowerCase() == 'true',
  };
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final field in widget.fields) ...[
              _field(field),
              const SizedBox(height: 12),
            ],
            if (_error != null) Text(_error!),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.pop(context),
        child: const Text('ยกเลิก'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(_saving ? 'กำลังบันทึก...' : 'บันทึกข้อมูล'),
      ),
    ],
  );

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave({
        ...widget.initial,
        for (final entry in _controllers.entries)
          entry.key: entry.value.text.trim(),
        for (final entry in _selected.entries) entry.key: entry.value ?? '',
        for (final entry in _toggles.entries) entry.key: entry.value,
      });
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _error = 'ไม่สามารถบันทึกข้อมูลได้');
    }
  }

  Widget _field(AdminField field) {
    if (field.type == AdminFieldType.select) {
      return DropdownButtonFormField<String>(
        key: Key('admin-field-${field.key}'),
        initialValue: _selected[field.key],
        decoration: InputDecoration(labelText: field.label),
        items: field.options
            .map((option) => DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: (value) => setState(() => _selected[field.key] = value),
        validator: field.required
            ? (value) => value == null || value.isEmpty
                  ? 'กรุณาระบุ${field.label}'
                  : null
            : null,
      );
    }
    if (field.type == AdminFieldType.toggle) {
      return SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(field.label),
        value: _toggles[field.key]!,
        onChanged: (value) => setState(() => _toggles[field.key] = value),
      );
    }
    return TextFormField(
      controller: _controllers[field.key],
      keyboardType: field.keyboardType ??
          switch (field.type) {
            AdminFieldType.number => TextInputType.number,
            AdminFieldType.imageUrl => TextInputType.url,
            _ => null,
          },
      obscureText: field.type == AdminFieldType.password,
      maxLines: field.type == AdminFieldType.multiline ? 3 : 1,
      decoration: InputDecoration(labelText: field.label),
      validator: field.required
          ? (value) => value == null || value.trim().isEmpty
                ? 'กรุณาระบุ${field.label}'
                : null
          : null,
    );
  }
}
