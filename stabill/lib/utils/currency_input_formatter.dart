import 'package:flutter/services.dart';
import 'package:stabill/utils/currency_format.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final bool includeCurrencySymbol;
  final bool allowNegative;

  const CurrencyInputFormatter({
    this.includeCurrencySymbol = true,
    this.allowNegative = false,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final isNegative = newValue.text.contains('-');
    if (isNegative &&
        (!allowNegative || !newValue.text.trimLeft().startsWith('-'))) {
      return oldValue;
    }
    if (allowNegative && newValue.text == '-') return newValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return oldValue;

    final cents = int.tryParse(digits);
    if (cents == null) return oldValue;
    if (isNegative && cents == 0) {
      return const TextEditingValue(
        text: '-',
        selection: TextSelection.collapsed(offset: 1),
      );
    }

    final text = CurrencyFormat.formatCents(
      isNegative ? -cents : cents,
      includeCurrencySymbol: includeCurrencySymbol,
    );
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
