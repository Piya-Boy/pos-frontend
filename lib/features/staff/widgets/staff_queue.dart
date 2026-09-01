import 'package:flutter/material.dart';

import '../../../models/staff_models.dart';

class StaffQueue extends StatelessWidget {
  const StaffQueue({
    super.key,
    required this.calls,
    required this.items,
    required this.onUpdateCall,
    required this.onUpdateItem,
  });

  final List<OpsCall> calls;
  final List<OpsOrderItem> items;
  final Future<void> Function(OpsCall call, String status) onUpdateCall;
  final Future<void> Function(OpsOrderItem item, String status) onUpdateItem;

  @override
  Widget build(BuildContext context) {
    final ready = items.where((item) => item.status == 'READY').toList();
    return LayoutBuilder(
      builder: (context, constraints) {
        // cp-pos .task-grid: 2 cols >=640, 3 cols >=900 (Styles.html:357/379).
        final cols = constraints.maxWidth >= 900 ? 3 : (constraints.maxWidth >= 640 ? 2 : 1);
        final width = cols == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (cols - 1) * 12) / cols;

        Widget card(Widget child) => SizedBox(width: width, child: child);

        return ListView(
          children: [
            const Text('งานเรียกจากโต๊ะ', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (calls.isEmpty)
              const Text('ไม่มีงานเรียก')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: calls
                    .map(
                      (call) => card(Card(
                        child: ListTile(
                          title: Text(call.call.type == 'BILL' ? 'เรียกเก็บเงิน' : 'เรียกพนักงาน'),
                          subtitle: Text(
                            '${call.table['Name'] ?? call.call.tableId}\n${call.status == 'ASSIGNED' ? 'มีพนักงานรับงานแล้ว' : 'กำลังรอพนักงานรับงาน'}',
                          ),
                          trailing: FilledButton(
                            onPressed: () => onUpdateCall(call, call.status == 'OPEN' ? 'ASSIGNED' : 'DONE'),
                            child: Text(call.status == 'OPEN' ? 'รับงานนี้' : 'เสร็จเรียบร้อย'),
                          ),
                        ),
                      )),
                    )
                    .toList(),
              ),
            const SizedBox(height: 28),
            const Text('อาหารพร้อมเสิร์ฟ', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (ready.isEmpty)
              const Text('ยังไม่มีอาหารพร้อมเสิร์ฟ')
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: ready
                    .map(
                      (item) => card(Card(
                        child: ListTile(
                          title: Text('${item.table['Name'] ?? ''} · ${item.order.qty} × ${item.order.itemName}'),
                          trailing: FilledButton.tonal(
                            onPressed: () => onUpdateItem(item, 'SERVED'),
                            child: const Text('ยืนยันว่าเสิร์ฟแล้ว'),
                          ),
                        ),
                      )),
                    )
                    .toList(),
              ),
          ],
        );
      },
    );
  }
}
