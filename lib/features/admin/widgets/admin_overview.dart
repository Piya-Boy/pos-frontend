import 'package:flutter/material.dart';

import '../../../core/theme/tokens.dart';
import '../../../models/staff_models.dart';

class AdminOverview extends StatelessWidget {
  const AdminOverview({super.key, required this.data});

  final AdminData data;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;
    final metrics = [
      ('โต๊ะทั้งหมด', '${summary['tables'] ?? 0}'),
      ('รอบโต๊ะที่เปิด', '${summary['activeSessions'] ?? 0}'),
      ('รายการเมนู', '${summary['menuItems'] ?? 0}'),
      (
        'ยอดขายวันนี้',
        '${_number(summary['todaySales']).toStringAsFixed(2)} บาท',
      ),
    ];
    return ListView(
      children: [
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: metrics
              .map(
                (metric) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          metric.$1,
                          style: const TextStyle(color: PhiusTokens.muted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric.$2,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 28),
        Text(
          'ทางลัดหน้าปฏิบัติงาน',
          style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'ตรวจ QR ของแต่ละโต๊ะ อัปเดตสถานะเมนู และทดสอบการทำงานด้วย PIN ของแต่ละบทบาทก่อนเปิดใช้งานจริง',
          style: TextStyle(color: PhiusTokens.muted),
        ),
      ],
    );
  }
}

num _number(Object? value) =>
    value is num ? value : num.tryParse('$value') ?? 0;
