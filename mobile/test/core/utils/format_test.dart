import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:duitkita/core/utils/format.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('fmtRp', () {
    test('formats zero', () {
      expect(fmtRp(0), 'Rp0');
    });

    test('formats thousands with dot separator', () {
      expect(fmtRp(1500000), 'Rp1.500.000');
    });

    test('formats small amount', () {
      expect(fmtRp(500), 'Rp500');
    });

    test('formats negative with minus sign U+2212', () {
      expect(fmtRp(-1500000), '−Rp1.500.000');
    });

    test('formats large amount', () {
      expect(fmtRp(10000000), 'Rp10.000.000');
    });
  });

  group('fmtShort', () {
    test('under 1000 uses fmtRp', () {
      expect(fmtShort(250), 'Rp250');
    });

    test('250_000 → Rp250rb', () {
      expect(fmtShort(250000), 'Rp250rb');
    });

    test('1_500_000 → Rp1,5jt', () {
      expect(fmtShort(1500000), 'Rp1,5jt');
    });

    test('1_000_000 → Rp1jt (no decimal)', () {
      expect(fmtShort(1000000), 'Rp1jt');
    });

    test('1_000_000_000 → Rp1M', () {
      expect(fmtShort(1000000000), 'Rp1M');
    });

    test('1_500_000_000 → Rp1,5M', () {
      expect(fmtShort(1500000000), 'Rp1,5M');
    });

    test('negative 1_500_000 → −Rp1,5jt', () {
      expect(fmtShort(-1500000), '−Rp1,5jt');
    });
  });

  group('fmtRpSigned', () {
    test('income gets + prefix', () {
      expect(fmtRpSigned(500000, 'income'), '+Rp500.000');
    });

    test('expense gets − prefix', () {
      expect(fmtRpSigned(500000, 'expense'), '−Rp500.000');
    });

    test('transfer no prefix', () {
      expect(fmtRpSigned(500000, 'transfer'), 'Rp500.000');
    });
  });

  group('relDay', () {
    test('today returns Hari ini', () {
      final now = DateTime.now();
      expect(relDay(now), 'Hari ini');
    });

    test('yesterday returns Kemarin', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(relDay(yesterday), 'Kemarin');
    });

    test('2 days ago returns day name', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final result = relDay(twoDaysAgo);
      // Should not be 'Hari ini' or 'Kemarin'
      expect(result, isNot('Hari ini'));
      expect(result, isNot('Kemarin'));
      // Should be non-empty
      expect(result.isNotEmpty, isTrue);
    });

    test('specific date formats correctly', () {
      // Wednesday 11 Jun 2026
      final date = DateTime(2026, 6, 11);
      // If not today/yesterday it should have day name
      final result = relDay(date);
      expect(result, isNotEmpty);
    });
  });

  group('dayLabel', () {
    test('formats date with day name', () {
      final date = DateTime(2026, 6, 11);
      final result = dayLabel(date);
      expect(result, isNotEmpty);
      // Should contain the year
      expect(result, contains('2026'));
    });
  });

  group('monthLabel', () {
    test('formats June 2026', () {
      final date = DateTime(2026, 6, 1);
      final result = monthLabel(date);
      expect(result, contains('2026'));
      expect(result.toLowerCase(), contains('juni'));
    });
  });

  group('timeLabel', () {
    test('formats time as HH:mm', () {
      final date = DateTime(2026, 6, 11, 8, 15);
      expect(timeLabel(date), '08:15');
    });

    test('formats midnight', () {
      final date = DateTime(2026, 6, 11, 0, 0);
      expect(timeLabel(date), '00:00');
    });
  });
}
