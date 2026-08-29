import 'package:flutter/material.dart';
import 'package:pos_frontend/core/utils/client_id.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/core/utils/formatters.dart';
import 'package:pos_frontend/features/shared/widgets/app_buttons.dart';
import 'package:pos_frontend/features/shared/widgets/modal_sheet.dart';
import 'package:pos_frontend/features/shared/widgets/status_capsule.dart';
import 'package:pos_frontend/models/add_on.dart';
import 'package:pos_frontend/models/cart_line.dart';
import 'package:pos_frontend/models/menu_item.dart';
import 'package:pos_frontend/models/option.dart';
import 'package:pos_frontend/state/customer_controller.dart';

void openItemModal(
  BuildContext context,
  MenuItem item,
  CustomerController controller,
) {
  showPhiusModal(
    context,
    child: _ItemDetailContent(item: item, controller: controller),
  );
}

class _ItemDetailContent extends StatefulWidget {
  const _ItemDetailContent({required this.item, required this.controller});
  final MenuItem item;
  final CustomerController controller;

  @override
  State<_ItemDetailContent> createState() => _ItemDetailContentState();
}

class _ItemDetailContentState extends State<_ItemDetailContent> {
  final Map<String, List<Option>> _selectedOptions = {};
  final List<AddOn> _selectedAddOns = [];
  final TextEditingController _noteController = TextEditingController();
  int _qty = 1;

  @override
  void initState() {
    super.initState();
    final grouped = <String, List<Option>>{};
    for (final opt in widget.item.options) {
      grouped.putIfAbsent(opt.groupName, () => []).add(opt);
    }
    for (final entry in grouped.entries) {
      final options = entry.value;
      if (options.any((o) => o.isRequired) && options.first.inputType == 'RADIO') {
        _selectedOptions[entry.key] = [options.first];
      } else {
        _selectedOptions[entry.key] = [];
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  num get _unitPrice {
    num total = widget.item.price;
    for (final opts in _selectedOptions.values) {
      for (final o in opts) {
        total += o.price;
      }
    }
    for (final a in _selectedAddOns) {
      total += a.price;
    }
    return total;
  }

  void _submit() {
    final grouped = <String, List<Option>>{};
    for (final opt in widget.item.options) {
      grouped.putIfAbsent(opt.groupName, () => []).add(opt);
    }

    for (final entry in grouped.entries) {
      final isRequired = entry.value.any((o) => o.isRequired);
      final selected = _selectedOptions[entry.key] ?? [];
      if (isRequired && selected.isEmpty) {
        showToast(context, 'กรุณาเลือก ${entry.key}', isError: true);
        return;
      }
    }

    final allSelectedOpts = <Option>[];
    for (final list in _selectedOptions.values) {
      allSelectedOpts.addAll(list);
    }

    final line = CartLine(
      lineId: clientId('line'),
      itemId: widget.item.itemId,
      name: widget.item.name,
      image: widget.item.imageUrl,
      basePrice: widget.item.price,
      qty: _qty,
      optionIds: allSelectedOpts.map((o) => o.optionId).toList(),
      addOnIds: _selectedAddOns.map((a) => a.addOnId).toList(),
      options: allSelectedOpts,
      addOns: List.from(_selectedAddOns),
      note: _noteController.text.trim(),
      unitPrice: _unitPrice,
    );

    widget.controller.addToCart(line);
    Navigator.of(context).pop();
    showToast(context, 'เพิ่ม ${widget.item.name} ลงตะกร้าแล้ว');
  }

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<Option>>{};
    for (final opt in widget.item.options) {
      grouped.putIfAbsent(opt.groupName, () => []).add(opt);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                widget.item.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        if (widget.item.description.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.item.description,
              style: const TextStyle(color: PhiusTokens.muted),
            ),
          ),
        const Divider(),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...grouped.entries.map((entry) {
                  final groupName = entry.key;
                  final options = entry.value;
                  final isRequired = options.any((o) => o.isRequired);
                  final isRadio = options.first.inputType == 'RADIO';
                  final selected = _selectedOptions[groupName] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              groupName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRequired ? 'จำเป็นต้องเลือก' : 'เลือกได้',
                              style: TextStyle(
                                fontSize: 12,
                                color: isRequired ? PhiusTokens.primary : PhiusTokens.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...options.map((opt) {
                        final isOptSelected = selected.contains(opt);
                        return CheckboxListTile(
                          title: Text(opt.label),
                          secondary: opt.price > 0 ? Text('+${formatMoney(opt.price)}') : null,
                          value: isOptSelected,
                          onChanged: (val) {
                            setState(() {
                              if (isRadio) {
                                _selectedOptions[groupName] = [opt];
                              } else {
                                if (val == true) {
                                  selected.add(opt);
                                } else {
                                  selected.remove(opt);
                                }
                                _selectedOptions[groupName] = selected;
                              }
                            });
                          },
                        );
                      }),
                    ],
                  );
                }),
                if (widget.item.addOns.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'เพิ่มความอร่อย',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                  ...widget.item.addOns.map((addOn) {
                    final selected = _selectedAddOns.contains(addOn);
                    return CheckboxListTile(
                      title: Text(addOn.name),
                      secondary: Text('+${formatMoney(addOn.price)}'),
                      value: selected,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedAddOns.add(addOn);
                          } else {
                            _selectedAddOns.remove(addOn);
                          }
                        });
                      },
                    );
                  }),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLength: 300,
                  decoration: const InputDecoration(
                    labelText: 'หมายเหตุถึงครัว',
                    hintText: 'เช่น ไม่ใส่ผัก แยกน้ำ',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: PhiusTokens.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _qty > 1 ? () => setState(() => _qty--) : null,
                  ),
                  Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => _qty++),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                onPressed: _submit,
                label: 'เพิ่มลงตะกร้า · ${formatMoney(_unitPrice * _qty)}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}
