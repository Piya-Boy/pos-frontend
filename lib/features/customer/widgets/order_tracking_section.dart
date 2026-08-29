import 'package:flutter/material.dart';
import 'package:pos_frontend/core/api/api_client.dart';
import 'package:pos_frontend/core/theme/tokens.dart';
import 'package:pos_frontend/core/utils/formatters.dart';
import 'package:pos_frontend/features/customer/widgets/bill_status_banner.dart';
import 'package:pos_frontend/features/customer/widgets/status_meta.dart';
import 'package:pos_frontend/features/shared/widgets/app_buttons.dart';
import 'package:pos_frontend/models/order_item.dart';
import 'package:pos_frontend/models/order_session.dart';
import 'package:pos_frontend/models/session_bundle.dart';

class OrderTrackingSection extends StatefulWidget {
  const OrderTrackingSection({
    super.key,
    required this.session,
    required this.paymentComplete,
    required this.onRefresh,
    required this.onCallStaff,
  });

  final SessionBundle? session;
  final bool paymentComplete;
  final Future<void> Function() onRefresh;
  final Future<CallResult> Function(String type) onCallStaff;

  @override
  State<OrderTrackingSection> createState() => _OrderTrackingSectionState();
}

class _OrderTrackingSectionState extends State<OrderTrackingSection> {
  bool _refreshing = false;
  final Set<String> _pendingCalls = {};

  @override
  Widget build(BuildContext context) {
    final hasItems = widget.session?.items.isNotEmpty == true;
    final closed =
        widget.session != null &&
        const {
          'PAID',
          'CLOSED',
          'CANCELLED',
        }.contains(widget.session!.session.status);
    final billPending = isBillPending(widget.session);
    final narrow = MediaQuery.sizeOf(context).width <= 430;

    return Container(
      key: const ValueKey('order-tracking'),
      margin: const EdgeInsets.only(top: 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'อัปเดตล่าสุด',
                      style: TextStyle(
                        color: PhiusTokens.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ออเดอร์ของโต๊ะ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              GhostButton(
                onPressed: _refreshing ? null : _refresh,
                label: _refreshing ? 'กำลังรีเฟรช...' : 'รีเฟรช',
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!hasItems)
            _EmptyTracking(paymentComplete: widget.paymentComplete)
          else ...[
            if (billPending) const _InlineBillStatus(),
            ...widget.session!.items.map(_TrackingItem.new),
            const SizedBox(height: 12),
            _TotalsCard(session: widget.session!.session),
          ],
          const SizedBox(height: 16),
          narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _serviceButtons(closed, billPending),
                )
              : Row(
                  children: _serviceButtons(
                    closed,
                    billPending,
                    expanded: true,
                  ),
                ),
        ],
      ),
    );
  }

  List<Widget> _serviceButtons(
    bool closed,
    bool billPending, {
    bool expanded = false,
  }) {
    final assistance = SecondaryButton(
      onPressed: closed || _pendingCalls.contains('ASSISTANCE')
          ? null
          : () => _callStaff('ASSISTANCE'),
      child: const _ServiceLabel(icon: '🛎️', label: 'เรียกพนักงาน'),
    );
    final bill = OutlineButton(
      onPressed: closed || billPending || _pendingCalls.contains('BILL')
          ? null
          : () => _callStaff('BILL'),
      child: _ServiceLabel(
        icon: '🧾',
        label: billPending ? 'เรียกเก็บเงินแล้ว' : 'เรียกเก็บเงิน',
      ),
    );
    if (!expanded) return [assistance, const SizedBox(height: 10), bill];
    return [
      Expanded(child: assistance),
      const SizedBox(width: 10),
      Expanded(child: bill),
    ];
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      await widget.onRefresh();
    } catch (_) {
      _showMessage('ไม่สามารถรีเฟรชสถานะได้ กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _callStaff(String type) async {
    setState(() => _pendingCalls.add(type));
    try {
      final result = await widget.onCallStaff(type);
      _showMessage(
        result.duplicate
            ? 'ส่งคำขอนี้ไปแล้ว กรุณารอสักครู่'
            : type == 'BILL'
            ? 'แจ้งเรียกเก็บเงินแล้ว'
            : 'เรียกพนักงานแล้ว',
      );
    } on StateError catch (error) {
      _showMessage(
        '$error'.contains('NO_SESSION')
            ? 'ยังไม่มีออเดอร์สำหรับเรียกเก็บเงิน'
            : 'ไม่สามารถส่งคำขอได้ กรุณาลองใหม่',
      );
    } catch (_) {
      _showMessage('ไม่สามารถส่งคำขอได้ กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _pendingCalls.remove(type));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ServiceLabel extends StatelessWidget {
  const _ServiceLabel({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [Text(icon), const SizedBox(width: 6), Text(label)],
  );
}

class _EmptyTracking extends StatelessWidget {
  const _EmptyTracking({required this.paymentComplete});
  final bool paymentComplete;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: _cardDecoration(),
    child: paymentComplete
        ? const Column(
            children: [
              Text(
                '✓',
                style: TextStyle(fontSize: 28, color: PhiusTokens.green),
              ),
              SizedBox(height: 8),
              Text(
                'ชำระเงินเรียบร้อยแล้ว',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('โต๊ะถูกรีเซตและพร้อมสำหรับการสั่งรอบใหม่'),
            ],
          )
        : const Column(
            children: [
              Text('🥢', style: TextStyle(fontSize: 28)),
              SizedBox(height: 8),
              Text(
                'พร้อมรับออเดอร์',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text('เลือกรายการที่ต้องการแล้วกดดูตะกร้า'),
            ],
          ),
  );
}

class _InlineBillStatus extends StatelessWidget {
  const _InlineBillStatus();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: PhiusTokens.redSoft,
      borderRadius: BorderRadius.circular(PhiusTokens.radiusSm),
    ),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🧾 แจ้งเรียกเก็บเงินแล้ว',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        Text('คุณยังตรวจสอบยอดและรายการทั้งหมดได้ระหว่างรอ'),
      ],
    ),
  );
}

class _TrackingItem extends StatelessWidget {
  const _TrackingItem(this.item);
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final meta = statusMeta(item.status);
    final selections = [
      ...item.options.map(
        (option) =>
            '${option['group'] ?? option['GroupName'] ?? 'ตัวเลือก'}: ${option['label'] ?? option['Label'] ?? ''}',
      ),
      ...item.addOns.map(
        (addOn) => '+ ${addOn['name'] ?? addOn['Name'] ?? ''}',
      ),
      if (item.note.isNotEmpty) 'หมายเหตุ: ${item.note}',
    ];
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.only(top: 7, right: 10),
            decoration: BoxDecoration(
              color: meta.dotColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.itemName} × ${item.qty}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text(
                      formatMoney(item.lineTotal),
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  '${formatMoney(item.unitPrice)} ต่อรายการ',
                  style: const TextStyle(color: PhiusTokens.muted),
                ),
                ...selections.map(
                  (text) => Text(
                    text,
                    style: const TextStyle(color: PhiusTokens.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: meta.pillBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${meta.icon} ${meta.label}',
              style: TextStyle(
                color: meta.pillFg,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.session});
  final OrderSession session;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      children: [
        _row('ยอดก่อนส่วนลด', session.subtotal),
        if (session.discount != 0)
          _row('ส่วนลด', session.discount, prefix: '−'),
        if (session.serviceCharge != 0)
          _row('ค่าบริการ', session.serviceCharge),
        if (session.vat != 0) _row('VAT', session.vat),
        const Divider(height: 24),
        _row('ยอดรวมทั้งหมด', session.total, bold: true),
      ],
    ),
  );

  Widget _row(
    String label,
    num value, {
    String prefix = '',
    bool bold = false,
  }) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
          ),
        ),
      ),
      Text(
        '$prefix${formatMoney(value)}',
        style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600),
      ),
    ],
  );
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: PhiusTokens.surface,
  border: Border.all(color: PhiusTokens.border),
  borderRadius: BorderRadius.circular(PhiusTokens.radius),
);
