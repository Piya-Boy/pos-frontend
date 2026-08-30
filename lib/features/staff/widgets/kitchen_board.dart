import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../models/staff_models.dart';

class KitchenBoard extends StatefulWidget {
  const KitchenBoard({
    super.key,
    required this.items,
    required this.onUpdateStatus,
  });

  final List<OpsOrderItem> items;
  final Future<void> Function(OpsOrderItem item, String status) onUpdateStatus;

  @override
  State<KitchenBoard> createState() => _KitchenBoardState();
}

class _KitchenBoardState extends State<KitchenBoard> {
  String? _updatingId;

  Future<void> _update(OpsOrderItem item, String status) async {
    setState(() => _updatingId = item.orderItemId);
    try {
      await widget.onUpdateStatus(item, status);
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 760 || constraints.maxHeight < 260;
      final columns = const [
        ('NEW', 'ออเดอร์ใหม่'),
        ('PREPARING', 'กำลังทำ'),
        ('READY', 'พร้อมเสิร์ฟ'),
      ];
      final boards = columns
          .map(
            (column) => _KitchenColumn(
              title: column.$2,
              items: widget.items
                  .where((item) => item.status == column.$1)
                  .toList(),
              updatingId: _updatingId,
              onUpdate: _update,
            ),
          )
          .toList();
      if (compact) {
        return ListView.separated(
          itemCount: boards.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, index) => boards[index],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final board in boards) ...[
            Expanded(child: board),
            if (board != boards.last) const SizedBox(width: 16),
          ],
        ],
      );
    },
  );
}

class _KitchenColumn extends StatelessWidget {
  const _KitchenColumn({
    required this.title,
    required this.items,
    required this.updatingId,
    required this.onUpdate,
  });

  final String title;
  final List<OpsOrderItem> items;
  final String? updatingId;
  final Future<void> Function(OpsOrderItem item, String status) onUpdate;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: PhiusTokens.surfaceSoft,
      borderRadius: BorderRadius.circular(PhiusTokens.radiusSm),
      border: Border.all(color: PhiusTokens.border),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            CircleAvatar(radius: 12, child: Text('${items.length}')),
          ],
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('✓ ยังไม่มีรายการ'),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) => _OrderCard(
              item: items[index],
              updating: updatingId == items[index].orderItemId,
              onUpdate: onUpdate,
            ),
          ),
      ],
    ),
  );
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.item,
    required this.updating,
    required this.onUpdate,
  });

  final OpsOrderItem item;
  final bool updating;
  final Future<void> Function(OpsOrderItem item, String status) onUpdate;

  @override
  Widget build(BuildContext context) {
    final nextStatus = item.status == 'NEW'
        ? 'PREPARING'
        : item.status == 'PREPARING'
        ? 'READY'
        : null;
    final selections = [
      ...item.order.options.map(
        (option) => '${option['label'] ?? option['Label'] ?? ''}',
      ),
      ...item.order.addOns.map(
        (addOn) => '${addOn['name'] ?? addOn['Name'] ?? ''}',
      ),
    ].where((value) => value.isNotEmpty).join(', ');
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PhiusTokens.surface,
        border: Border.all(color: PhiusTokens.border),
        borderRadius: BorderRadius.circular(PhiusTokens.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${item.table['Name'] ?? 'โต๊ะ'}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                _elapsed(item.createdAt),
                style: const TextStyle(color: PhiusTokens.muted, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${item.order.qty} × ${item.order.itemName}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (selections.isNotEmpty)
            Text(
              selections,
              style: const TextStyle(color: PhiusTokens.muted, fontSize: 12),
            ),
          if (item.order.note.isNotEmpty) Text('หมายเหตุ: ${item.order.note}'),
          const SizedBox(height: 12),
          if (nextStatus == null)
            const Text('รอพนักงานเสิร์ฟ')
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: updating ? null : () => onUpdate(item, nextStatus),
                child: Text(
                  nextStatus == 'PREPARING' ? 'เริ่มทำ' : 'พร้อมเสิร์ฟ',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _elapsed(DateTime? at) {
  if (at == null) return '';
  final minutes = DateTime.now().toUtc().difference(at).inMinutes;
  return minutes <= 0 ? 'เมื่อสักครู่' : '$minutes นาที';
}
