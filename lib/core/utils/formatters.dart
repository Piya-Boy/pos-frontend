import 'package:intl/intl.dart';

final _moneyInt = NumberFormat.currency(
  locale: 'th_TH',
  symbol: '฿',
  decimalDigits: 0,
);
final _moneyDec = NumberFormat.currency(
  locale: 'th_TH',
  symbol: '฿',
  decimalDigits: 2,
);

String formatMoney(num value) =>
    value == value.roundToDouble() ? _moneyInt.format(value) : _moneyDec.format(value);

String placeholderImage(String label) {
  final text = Uri.encodeComponent(label.isEmpty ? 'Menu' : label);
  return 'https://placehold.co/900x700/F4EEE5/706A63?text=$text';
}
