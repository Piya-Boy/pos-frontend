import 'package:cached_network_image/cached_network_image.dart';
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
        // Sticky header bar — cp-pos ".modal-header" (App.html:437).
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'รายละเอียดเมนู',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large item image — cp-pos ".item-detail-image" aspect 1.6, radius 20.
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 1.6,
                    child: CachedNetworkImage(
                      imageUrl: widget.item.imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, _, _) => Image.network(
                        placeholderImage(widget.item.name),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Title row: name + description left, large price right — ".item-detail-title".
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.item.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                widget.item.description,
                                style: const TextStyle(color: PhiusTokens.muted),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      formatMoney(widget.item.price),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: PhiusTokens.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
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
                        return _ChoiceRow(
                          label: opt.label,
                          priceLabel: opt.price > 0
                              ? '+${formatMoney(opt.price)}'
                              : 'ไม่เพิ่มราคา',
                          selected: isOptSelected,
                          isRadio: isRadio,
                          onTap: () {
                            setState(() {
                              if (isRadio) {
                                _selectedOptions[groupName] = [opt];
                              } else {
                                if (isOptSelected) {
                                  selected.remove(opt);
                                } else {
                                  selected.add(opt);
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
                    return _ChoiceRow(
                      label: addOn.name,
                      priceLabel: '+${formatMoney(addOn.price)}',
                      selected: selected,
                      isRadio: false,
                      onTap: () {
                        setState(() {
                          if (selected) {
                            _selectedAddOns.remove(addOn);
                          } else {
                            _selectedAddOns.add(addOn);
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

/// One selectable option/add-on row — ports CSS `.choice-row`
/// (`Styles.html:205-208`): `[control] label(flex) price(muted, right)`.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.priceLabel,
    required this.selected,
    required this.isRadio,
    required this.onTap,
  });

  final String label;
  final String priceLabel;
  final bool selected;
  final bool isRadio;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: PhiusTokens.surface,
            border: Border.all(
              color: selected ? PhiusTokens.primary : PhiusTokens.border,
            ),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: isRadio
                    ? Icon(
                        selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 20,
                        color: selected ? PhiusTokens.primary : PhiusTokens.muted,
                      )
                    : Icon(
                        selected
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 20,
                        color: selected ? PhiusTokens.primary : PhiusTokens.muted,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label)),
              Text(
                priceLabel,
                style: const TextStyle(
                  color: PhiusTokens.muted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
