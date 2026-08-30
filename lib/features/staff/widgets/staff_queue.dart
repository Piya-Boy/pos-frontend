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
    return ListView(
      children: [
        const Text(
          'งานเรียกจากโต๊ะ',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        if (calls.isEmpty)
          const Text('ไม่มีงานเรียก')
        else
          ...calls.map(
            (call) => Card(
              child: ListTile(
                title: Text(
                  call.call.type == 'BILL' ? 'เรียกเก็บเงิน' : 'เรียกพนักงาน',
                ),
                subtitle: Text(
                  '${call.table['Name'] ?? call.call.tableId}\n${call.status == 'ASSIGNED' ? 'มีพนักงานรับงานแล้ว' : 'กำลังรอพนักงานรับงาน'}',
                ),
                trailing: FilledButton(
                  onPressed: () => onUpdateCall(
                    call,
                    call.status == 'OPEN' ? 'ASSIGNED' : 'DONE',
                  ),
                  child: Text(
                    call.status == 'OPEN' ? 'รับงานนี้' : 'เสร็จเรียบร้อย',
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 28),
        const Text(
          'อาหารพร้อมเสิร์ฟ',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        if (ready.isEmpty)
          const Text('ยังไม่มีอาหารพร้อมเสิร์ฟ')
        else
          ...ready.map(
            (item) => Card(
              child: ListTile(
                title: Text(
                  '${item.table['Name'] ?? ''} · ${item.order.qty} × ${item.order.itemName}',
                ),
                trailing: FilledButton.tonal(
                  onPressed: () => onUpdateItem(item, 'SERVED'),
                  child: const Text('ยืนยันว่าเสิร์ฟแล้ว'),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
