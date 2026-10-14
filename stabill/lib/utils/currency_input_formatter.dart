import 'package:flutter/services.dart';
import 'package:stabill/utils/currency_format.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  const CurrencyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    if (newValue.text.contains('-')) return oldValue;

    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return oldValue;

    final cents = int.tryParse(digits);
    if (cents == null) return oldValue;

    final text = CurrencyFormat.formatCents(cents);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
