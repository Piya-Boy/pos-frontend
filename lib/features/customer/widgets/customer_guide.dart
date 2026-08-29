import 'package:flutter/material.dart';
import 'package:pos_frontend/core/theme/tokens.dart';

class CustomerGuide extends StatelessWidget {
  const CustomerGuide({super.key});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 16),
    decoration: BoxDecoration(color: PhiusTokens.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: PhiusTokens.border)),
    child: Material(
      color: Colors.transparent,
      child: ExpansionTile(
      title: const Text('วิธีสั่งอาหาร', style: TextStyle(fontWeight: FontWeight.w700)),
      subtitle: const Text('ⓘ แตะเพื่อดูขั้นตอน'),
      children: const [
        _Step(1, 'เลือกเมนู', 'เลือกตัวเลือกและส่วนเพิ่มที่ต้องการ'),
        _Step(2, 'ตรวจตะกร้าและส่งออเดอร์', 'ราคาแต่ละรายการและยอดรวมจะแสดงก่อนยืนยัน'),
        _Step(3, 'ติดตามสถานะและเรียกเก็บเงิน', 'ดูรายการของโต๊ะได้ตลอดจนชำระเสร็จ'),
      ],
      ),
    ),
  );
}
class _Step extends StatelessWidget { const _Step(this.number, this.title, this.subtitle); final int number; final String title; final String subtitle; @override Widget build(BuildContext context) => ListTile(leading: CircleAvatar(radius: 13, backgroundColor: PhiusTokens.primary, child: Text('$number', style: const TextStyle(color: Colors.white))), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text(subtitle)); }
