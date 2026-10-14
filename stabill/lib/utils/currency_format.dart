import 'package:intl/intl.dart';

class CurrencyFormat {
  static final NumberFormat _currency = NumberFormat.simpleCurrency();

  static String formatAmount(num amount) => _currency.format(amount);

  static String formatCents(int cents) => formatAmount(cents / 100.0);

  static int? parseCents(String? value) {
    if (value == null || value.isEmpty || value.contains('-')) return null;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }
}
