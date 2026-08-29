import 'package:flutter/material.dart';
import 'package:pos_frontend/core/utils/formatters.dart';
import 'package:pos_frontend/features/shared/widgets/app_buttons.dart';
import 'package:pos_frontend/features/shared/widgets/modal_sheet.dart';
import 'package:pos_frontend/models/cart_line.dart';
import 'package:pos_frontend/models/promotion.dart';
import 'package:pos_frontend/features/shared/widgets/status_capsule.dart';
import 'package:pos_frontend/state/customer_controller.dart';

void openCartModal(BuildContext context, CustomerController controller) =>
    showPhiusModal(context, child: _CartModal(controller: controller));

class _CartModal extends StatefulWidget {
  const _CartModal({required this.controller});
  final CustomerController controller;
  @override
  State<_CartModal> createState() => _CartModalState();
}

class _CartModalState extends State<_CartModal> {
  final _promo = TextEditingController();
  bool _submitting = false;
  @override
  void dispose() {
    _promo.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.cart.isEmpty) {
      showToast(context, 'ยังไม่มีรายการในตะกร้า', isError: true);
      return;
    }
    setState(() => _submitting = true);
    try {
      await widget.controller.submit(_promo.text.trim());
      if (mounted) {
        Navigator.pop(context);
        showToast(context, 'ส่งออเดอร์เข้าครัวแล้ว');
      }
    } catch (_) {
      if (mounted) {
        showToast(context, 'ส่งออเดอร์ไม่สำเร็จ กรุณาลองใหม่', isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final promotion = c.data?.promotions
        .where(
          (p) =>
              p.code.toUpperCase() == _promo.text.trim().toUpperCase() &&
              c.cartSubtotal() >= p.minSpend,
        )
        .firstOrNull;
    final discount = promotion == null
        ? 0
        : _discount(promotion, c.cartSubtotal());
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ตะกร้าของคุณ',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const Text('ตรวจสอบก่อนส่ง'),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              children: c.cart
                  .map((line) => _CartLine(line: line, controller: c))
                  .toList(),
            ),
          ),
          TextField(
            controller: _promo,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'โค้ดโปรโมชั่น',
              hintText: 'เช่น WELCOME10',
            ),
          ),
          const Text('ระบบจะตรวจสิทธิ์และยอดขั้นต่ำอีกครั้งก่อนยืนยัน'),
          const SizedBox(height: 8),
          Text('ยอดสินค้าโดยประมาณ ${formatMoney(c.cartSubtotal())}'),
          if (discount > 0) Text('ส่วนลดโดยประมาณ ${formatMoney(discount)}'),
          Text(
            'ประมาณการ ${formatMoney(c.cartSubtotal() - discount)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: _submitting || c.cart.isEmpty ? null : _submit,
              label: 'ยืนยันการสั่งอาหาร',
            ),
          ),
        ],
      ),
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({required this.line, required this.controller});
  final CartLine line;
  final CustomerController controller;
  @override
  Widget build(BuildContext context) => ListTile(
    title: Text('${line.name} ×${line.qty}'),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${formatMoney(line.unitPrice)} ต่อรายการ · ${formatMoney(line.unitPrice * line.qty)}',
        ),
        if (line.options.isNotEmpty)
          Text(line.options.map((o) => o.label).join(', ')),
        if (line.addOns.isNotEmpty)
          Text(line.addOns.map((a) => a.name).join(', ')),
        if (line.note.isNotEmpty) Text(line.note),
      ],
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => controller.changeQty(line.lineId, -1),
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          onPressed: () => controller.changeQty(line.lineId, 1),
          icon: const Icon(Icons.add),
        ),
        TextButton(
          onPressed: () => controller.removeLine(line.lineId),
          child: const Text('นำออก'),
        ),
      ],
    ),
  );
}

num _discount(Promotion promotion, num subtotal) =>
    promotion.discountType == 'PERCENT'
    ? subtotal * promotion.discountValue / 100
    : promotion.discountValue.clamp(0, subtotal);
