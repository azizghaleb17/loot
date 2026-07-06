import 'package:flutter_test/flutter_test.dart';
import 'package:loot/core/utils/money.dart';

void main() {
  group('Money (KWD, 3 decimal places)', () {
    test('formats fils with exactly three decimals', () {
      expect(const Money(7500).amountText, '7.500');
      expect(const Money(500).amountText, '0.500');
      expect(const Money(5).amountText, '0.005');
      expect(const Money(0).amountText, '0.000');
      expect(const Money(21000).amountText, '21.000');
    });

    test('adds thousands separators to whole dinars', () {
      expect(const Money(1250750).amountText, '1,250.750');
      expect(const Money(1000000).amountText, '1,000.000');
      expect(const Money(999999999).amountText, '999,999.999');
    });

    test('locale formatting: KD prefix in English, د.ك in Arabic, Western numerals in both', () {
      expect(const Money(7500).format('en'), 'KD 7.500');
      expect(const Money(7500).format('ar'), 'د.ك 7.500');
    });

    test('parses KWD strings', () {
      expect(Money.fromKwd('7.500'), const Money(7500));
      expect(Money.fromKwd('7.5'), const Money(7500));
      expect(Money.fromKwd('7'), const Money(7000));
      expect(Money.fromKwd('0.005'), const Money(5));
      expect(Money.fromKwd('1,250.750'), const Money(1250750));
      expect(() => Money.fromKwd('7.5000'), throwsFormatException);
      expect(() => Money.fromKwd('abc'), throwsFormatException);
    });

    test('arithmetic stays in integer fils', () {
      expect(const Money(1500) + const Money(2500), const Money(4000));
      expect(const Money(5000) - const Money(1250), const Money(3750));
      expect(const Money(3500) * 3, const Money(10500));
    });

    test('percent discount truncates to whole fils (matches place_order SQL)', () {
      expect(const Money(9999).percent(10), const Money(999));
      expect(const Money(10000).percent(10), const Money(1000));
      expect(const Money(1).percent(50), const Money(0));
    });

    test('comparisons', () {
      expect(const Money(1000) < const Money(2000), isTrue);
      expect(const Money(2000) >= const Money(2000), isTrue);
      expect(const Money(1500).compareTo(const Money(1500)), 0);
    });

    test('never negative', () {
      expect(() => Money(-1), throwsAssertionError);
    });
  });
}
