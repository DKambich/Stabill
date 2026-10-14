import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:stabill/utils/currency_format.dart';
import 'package:stabill/utils/currency_input_formatter.dart';

void main() {
  group('CurrencyInputFormatter', () {
    test('formats cents with two decimal places and grouping', () {
      final currency = NumberFormat.simpleCurrency();
      expect(CurrencyFormat.formatCents(0), currency.format(0));
      expect(CurrencyFormat.formatCents(5), currency.format(0.05));
      expect(CurrencyFormat.formatCents(123), currency.format(1.23));
      expect(CurrencyFormat.formatCents(123456), currency.format(1234.56));
      expect(CurrencyFormat.formatCents(-123), currency.format(-1.23));
    });

    test('parses formatted amounts into cents', () {
      expect(CurrencyFormat.parseCents(CurrencyFormat.formatCents(123456)),
          123456);
      expect(CurrencyFormat.parseCents(CurrencyFormat.formatCents(5)), 5);
      expect(CurrencyFormat.parseCents(''), isNull);
      expect(CurrencyFormat.parseCents('-1.23'), isNull);
    });

    test('formats typed digits and moves the caret to the end', () {
      const oldValue = TextEditingValue(
        text: '1.23',
        selection: TextSelection.collapsed(offset: 4),
      );
      const newValue = TextEditingValue(
        text: '1.234',
        selection: TextSelection.collapsed(offset: 5),
      );

      final result =
          const CurrencyInputFormatter().formatEditUpdate(oldValue, newValue);
      expect(result.text, CurrencyFormat.formatCents(1234));
      expect(result.selection,
          TextSelection.collapsed(offset: result.text.length));
    });
  });
}
