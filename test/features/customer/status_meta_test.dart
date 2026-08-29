import 'package:flutter_test/flutter_test.dart';
import 'package:pos_frontend/features/customer/widgets/status_meta.dart';

void main() {
  test('statusMeta ports App.html customer states', () {
    expect(statusMeta('NEW').label, 'ออเดอร์ใหม่');
    expect(statusMeta('PREPARING').label, 'กำลังปรุง');
    expect(statusMeta('READY').label, 'พร้อมเสิร์ฟ');
    expect(statusMeta('SERVED').label, 'เสิร์ฟแล้ว');
  });
}
