import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../models/staff_models.dart';

/// Builds + prints a receipt PDF from a paid session (ports cp-pos PdfService
/// receipt: restaurant, table, payment meta, items, totals).
/// Thai text needs an embedded font — use the Prompt Google font for both
/// regular + bold so Thai glyphs render (the built-in PDF fonts have no Thai).
Future<void> printReceipt(Receipt receipt) async {
  final regular = await PdfGoogleFonts.promptRegular();
  final bold = await PdfGoogleFonts.promptBold();
  final theme = pw.ThemeData.withFont(base: regular, bold: bold);
  final money = NumberFormat('#,##0.00', 'en_US');
  String baht(num v) => '${money.format(v)} บาท';

  final doc = pw.Document(theme: theme);
  final payment = receipt.payment ?? const {};
  final s = receipt.session;

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.roll80, // 80mm thermal receipt width
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(
            child: pw.Text(
              receipt.restaurantName,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('${receipt.table} · ${s.sessionId}', style: const pw.TextStyle(fontSize: 8))),
          pw.SizedBox(height: 2),
          pw.Center(child: pw.Text('ชำระโดย ${_method(payment['Method'])}', style: const pw.TextStyle(fontSize: 8))),
          if ('${payment['Reference'] ?? ''}'.isNotEmpty)
            pw.Center(child: pw.Text('อ้างอิง ${payment['Reference']}', style: const pw.TextStyle(fontSize: 8))),
          pw.SizedBox(height: 8),
          pw.Divider(height: 6),
          ...receipt.items.map(
            (item) => pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 2),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(child: pw.Text('${item.itemName} × ${item.qty}', style: const pw.TextStyle(fontSize: 9))),
                  pw.Text(baht(item.lineTotal), style: const pw.TextStyle(fontSize: 9)),
                ],
              ),
            ),
          ),
          pw.Divider(height: 6),
          _row('ยอดอาหาร', baht(s.subtotal)),
          if (s.discount != 0) _row('ส่วนลด', '-${baht(s.discount)}'),
          if (s.serviceCharge != 0) _row('ค่าบริการ', baht(s.serviceCharge)),
          if (s.vat != 0) _row('ภาษีมูลค่าเพิ่ม', baht(s.vat)),
          pw.SizedBox(height: 2),
          _row('ยอดรวม', baht(s.total), bold: true),
          pw.SizedBox(height: 10),
          pw.Center(child: pw.Text('ขอบคุณที่ใช้บริการ', style: const pw.TextStyle(fontSize: 9))),
        ],
      ),
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => doc.save());
}

pw.Widget _row(String label, String value, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 1),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(label, style: pw.TextStyle(fontSize: bold ? 11 : 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      pw.Text(value, style: pw.TextStyle(fontSize: bold ? 11 : 9, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
    ],
  ),
);

String _method(Object? m) => switch ('$m'.toUpperCase()) {
  'CASH' => 'เงินสด',
  'TRANSFER' => 'โอนเงิน',
  'CARD' => 'บัตร',
  'OTHER' => 'อื่น ๆ',
  _ => 'ไม่ระบุ',
};
