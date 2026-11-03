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

    test('parses signed target balances into cents', () {
      expect(CurrencyFormat.parseSignedCents('123.45'), 12345);
      expect(CurrencyFormat.parseSignedCents('-123.45'), -12345);
      expect(CurrencyFormat.parseSignedCents('-'), isNull);
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

    test('preserves a negative sign while entering a negative balance', () {
      const formatter = CurrencyInputFormatter(
        includeCurrencySymbol: false,
        allowNegative: true,
      );
      const oldValue = TextEditingValue.empty;
      const signValue = TextEditingValue(
        text: '-',
        selection: TextSelection.collapsed(offset: 1),
      );
      const zeroValue = TextEditingValue(
        text: '-0',
        selection: TextSelection.collapsed(offset: 2),
      );
      const oneValue = TextEditingValue(
        text: '-01',
        selection: TextSelection.collapsed(offset: 3),
      );

      final signResult = formatter.formatEditUpdate(oldValue, signValue);
      final zeroResult = formatter.formatEditUpdate(signResult, zeroValue);
      final oneResult = formatter.formatEditUpdate(zeroResult, oneValue);

      expect(signResult.text, '-');
      expect(zeroResult.text, '-');
      expect(oneResult.text, '-0.01');
    });
  });
}
