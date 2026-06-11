import 'package:intl/intl.dart';

// Call initializeDateFormatting('id_ID') before using date helpers.

final _rpFmt = NumberFormat('#,##0', 'id_ID');
final _dayFmt = DateFormat('EEEE, d MMM yyyy', 'id_ID');
final _relDayFmt = DateFormat('EEEE, d MMM', 'id_ID');
final _monthFmt = DateFormat('MMMM yyyy', 'id_ID');
final _timeFmt = DateFormat('HH:mm', 'id_ID');

// U+2212 MINUS SIGN for negative amounts
const _minus = '−';

/// Formats a compact decimal using comma as decimal separator (Indonesian style)
String _compactStr(double val) {
  if (val == val.truncateToDouble()) {
    return val.toInt().toString();
  }
  // Use one decimal place, replace dot with comma
  return val.toStringAsFixed(1).replaceAll('.', ',');
}

/// "Rp1.500.000" — negative uses U+2212
String fmtRp(int amount) {
  if (amount < 0) {
    return '${_minus}Rp${_rpFmt.format(-amount)}';
  }
  return 'Rp${_rpFmt.format(amount)}';
}

/// Signed format: income → "+Rp1.500.000", expense → "−Rp1.500.000"
/// [type] one of 'income' | 'expense' | 'transfer' | 'adjust'
String fmtRpSigned(int amount, String type) {
  final abs = amount.abs();
  final formatted = 'Rp${_rpFmt.format(abs)}';
  switch (type) {
    case 'income':
      return '+$formatted';
    case 'expense':
      return '$_minus$formatted';
    default:
      return formatted;
  }
}

/// Compact: ≥1_000_000 → "Rp1,5jt", ≥1_000 → "Rp250rb", else fmtRp
String fmtShort(int amount) {
  final abs = amount.abs();
  final sign = amount < 0 ? _minus : '';
  if (abs >= 1_000_000_000) {
    final val = abs / 1_000_000_000;
    final str = _compactStr(val);
    return '${sign}Rp${str}M';
  }
  if (abs >= 1_000_000) {
    final val = abs / 1_000_000;
    final str = _compactStr(val);
    return '${sign}Rp${str}jt';
  }
  if (abs >= 1_000) {
    final val = abs / 1_000;
    final str = _compactStr(val);
    return '${sign}Rp${str}rb';
  }
  return fmtRp(amount);
}

/// "Kamis, 11 Jun 2026"
String dayLabel(DateTime date) => _dayFmt.format(date);

/// "Hari ini" / "Kemarin" / "Rabu, 10 Jun"
String relDay(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(date.year, date.month, date.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Hari ini';
  if (diff == 1) return 'Kemarin';
  return _relDayFmt.format(date);
}

/// "Juni 2026"
String monthLabel(DateTime date) => _monthFmt.format(date);

/// "08:15"
String timeLabel(DateTime date) => _timeFmt.format(date);
