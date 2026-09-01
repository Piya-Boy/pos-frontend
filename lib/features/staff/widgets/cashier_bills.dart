import 'package:flutter/material.dart';

import '../../../core/utils/client_id.dart';
import '../../../core/theme/tokens.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../../models/order_session.dart';
import '../../../models/staff_models.dart';

class CashierBills extends StatefulWidget {
  const CashierBills({
    super.key,
    required this.sessions,
    required this.onClose,
  });
  final List<OpsSession> sessions;
  final Future<Receipt> Function(
    OpsSession session,
    String method,
    String reference,
    String idempotencyKey,
  )
  onClose;
  @override
  State<CashierBills> createState() => _CashierBillsState();
}

class _CashierBillsState extends State<CashierBills> {
  final Map<String, String> _paymentKeys = {};

  @override
  Widget build(BuildContext context) {
    if (widget.sessions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🧾', style: TextStyle(fontSize: 36)),
            SizedBox(height: 8),
            Text('ยังไม่มีบิลเปิดอยู่'),
            Text(
              'เมื่อมีลูกค้าสั่งอาหาร บิลจะแสดงที่นี่',
              style: TextStyle(color: PhiusTokens.muted),
            ),
          ],
        ),
      );
    }
    return ListView(
      children: [
        const Text(
          'Active Bills',
          style: TextStyle(
            color: PhiusTokens.primary,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'โต๊ะที่กำลังใช้งาน',
          style: Theme.of(context).textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        ...widget.sessions.map(_billCard),
      ],
    );
  }

  Widget _billCard(OpsSession session) {
    final pending = session.session.status == 'PAYMENT_PENDING';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatusPill(
                        pending ? 'เรียกเก็บเงินแล้ว' : 'กำลังรับประทาน',
                        highlighted: pending,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${session.table['Name'] ?? session.session.tableId}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                Text(
                  _money(session.session.total),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${session.items.length} รายการ · เปิด ${session.session.sessionId}',
              style: const TextStyle(color: PhiusTokens.muted),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => _open(session),
              child: const Text('ตรวจบิล'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(OpsSession session) async {
    final paymentKey = _paymentKeys.putIfAbsent(
      session.session.sessionId,
      () => clientId('pay'),
    );
    final receipt = await showDialog<Receipt>(
      context: context,
      builder: (_) => _BillDialog(
        session: session,
        onClose: widget.onClose,
        idempotencyKey: paymentKey,
      ),
    );
    if (receipt != null && mounted) {
      _paymentKeys.remove(session.session.sessionId);
      showDialog<void>(
        context: context,
        builder: (_) => _ReceiptDialog(receipt: receipt),
      );
    }
  }
}

class _BillDialog extends StatefulWidget {
  const _BillDialog({
    required this.session,
    required this.onClose,
    required this.idempotencyKey,
  });
  final OpsSession session;
  final Future<Receipt> Function(OpsSession, String, String, String) onClose;
  final String idempotencyKey;
  @override
  State<_BillDialog> createState() => _BillDialogState();
}

class _BillDialogState extends State<_BillDialog> {
  String? _method;
  String? _error;
  final _reference = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      '${widget.session.table['Name'] ?? widget.session.session.tableId}',
    ),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...widget.session.items.map(_receiptItem),
          const Divider(height: 28),
          _Totals(session: widget.session.session),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'วิธีชำระเงิน'),
            initialValue: _method,
            items: const [
              DropdownMenuItem(value: 'CASH', child: Text('เงินสด')),
              DropdownMenuItem(value: 'TRANSFER', child: Text('โอนเงิน')),
              DropdownMenuItem(value: 'CARD', child: Text('บัตร')),
              DropdownMenuItem(value: 'OTHER', child: Text('อื่น ๆ')),
            ],
            onChanged: _busy
                ? null
                : (value) => setState(() {
                    _method = value;
                    _error = null;
                  }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reference,
            enabled: !_busy,
            maxLength: 100,
            decoration: const InputDecoration(labelText: 'เลขอ้างอิง (ถ้ามี)'),
          ),
          if (_error != null)
            Text(
              _error!,
              style: const TextStyle(color: PhiusTokens.primaryDark),
            ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('ตรวจสอบอีกครั้ง'),
      ),
      FilledButton(
        onPressed: _busy ? null : _confirmAndClose,
        child: Text(
          _busy ? 'กำลังบันทึกการชำระ...' : 'รับชำระเงินและรีเซตโต๊ะ',
        ),
      ),
    ],
  );

  Widget _receiptItem(OpsOrderItem item) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Expanded(child: Text('${item.order.itemName} × ${item.order.qty}')),
        Text(_money(item.order.lineTotal)),
      ],
    ),
  );

  Future<void> _confirmAndClose() async {
    final method = _method;
    if (method == null) {
      setState(() => _error = 'กรุณาเลือกวิธีชำระเงิน');
      return;
    }
    final confirmed = await showConfirmDialog(
      context,
      title: 'ยืนยันการปิดโต๊ะ?',
      message: 'ระบบจะบันทึกการชำระและเปิดโต๊ะสำหรับลูกค้ารอบใหม่',
      confirmLabel: 'ยืนยันรับชำระ',
      cancelLabel: 'ตรวจสอบอีกครั้ง',
      icon: '🧾',
    );
    if (!confirmed || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final receipt = await widget.onClose(
        widget.session,
        method,
        _reference.text.trim(),
        widget.idempotencyKey,
      );
      if (mounted) Navigator.pop(context, receipt);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'ไม่สามารถบันทึกการชำระเงินได้';
        });
      }
    }
  }
}

class _ReceiptDialog extends StatelessWidget {
  const _ReceiptDialog({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    final payment = receipt.payment ?? const <String, dynamic>{};
    return AlertDialog(
      title: const Text('ชำระเงินและรีเซตโต๊ะแล้ว'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              receipt.restaurantName,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text('${receipt.table} · ${receipt.session.sessionId}'),
            const SizedBox(height: 12),
            Text('ชำระโดย ${_paymentMethodLabel(payment['Method'])}'),
            if ('${payment['Reference'] ?? ''}'.isNotEmpty)
              Text('อ้างอิง ${payment['Reference']}'),
            const SizedBox(height: 12),
            ...receipt.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.itemName} × ${item.qty}')),
                    Text(_money(item.lineTotal)),
                  ],
                ),
              ),
            ),
            const Divider(height: 28),
            _Totals(session: receipt.session),
            const SizedBox(height: 16),
            const Text(
              '✓ โต๊ะพร้อมรับลูกค้ารอบใหม่',
              style: TextStyle(
                color: PhiusTokens.green,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text('ออเดอร์เดิมถูกปิดและแยกออกจากรอบถัดไปแล้ว'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () {}, child: const Text('พิมพ์ใบเสร็จ')),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label, {required this.highlighted});

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: highlighted ? PhiusTokens.redSoft : PhiusTokens.greenSoft,
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: highlighted ? PhiusTokens.primaryDark : PhiusTokens.green,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );
}

class _Totals extends StatelessWidget {
  const _Totals({required this.session});

  final OrderSession session;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _line('ยอดอาหาร', session.subtotal),
      if (session.discount != 0) _line('ส่วนลด', -session.discount),
      if (session.serviceCharge != 0) _line('ค่าบริการ', session.serviceCharge),
      if (session.vat != 0) _line('ภาษีมูลค่าเพิ่ม', session.vat),
      const Divider(),
      _line('ยอดรวม', session.total, emphasized: true),
    ],
  );

  Widget _line(String label, num amount, {bool emphasized = false}) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(fontWeight: emphasized ? FontWeight.w800 : null),
        ),
      ),
      Text(
        _money(amount),
        style: TextStyle(fontWeight: emphasized ? FontWeight.w800 : null),
      ),
    ],
  );
}

String _money(num amount) => '${amount.toStringAsFixed(2)} บาท';

String _paymentMethodLabel(Object? method) => switch ('$method'.toUpperCase()) {
  'CASH' => 'เงินสด',
  'TRANSFER' => 'โอนเงิน',
  'CARD' => 'บัตร',
  'OTHER' => 'อื่น ๆ',
  _ => 'ไม่ระบุ',
};
