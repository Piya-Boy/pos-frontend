import 'package:intl/intl.dart';

// Ports App.html:1288 — Intl.NumberFormat('th-TH', {style:'currency',
// currency:'THB', maximumFractionDigits:2}). Intl currency defaults
// minimumFractionDigits to 2, so amounts ALWAYS show 2 decimals: ฿85.00.
final _money = NumberFormat.currency(
  locale: 'th_TH',
  symbol: '฿',
  decimalDigits: 2,
);

String formatMoney(num value) => _money.format(value);

String placeholderImage(String label) {
  final text = Uri.encodeComponent(label.isEmpty ? 'Menu' : label);
  return 'https://placehold.co/900x700/F4EEE5/706A63?text=$text';
}

// Ports App.html:1289 formatTime — th-TH HH:mm; '—' when null/invalid.
final _time = DateFormat('HH:mm');

String formatTime(DateTime? value) => value == null ? '—' : _time.format(value);
