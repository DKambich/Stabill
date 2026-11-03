import 'package:intl/intl.dart';

class CurrencyFormat {
  static final NumberFormat _currency = NumberFormat.simpleCurrency();
  static final NumberFormat _decimal = NumberFormat.decimalPattern()
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  static String formatAmount(num amount) => _currency.format(amount);

  static String formatCents(
    int cents, {
    bool includeCurrencySymbol = true,
  }) =>
      includeCurrencySymbol
          ? formatAmount(cents / 100.0)
          : _decimal.format(cents / 100.0);

  static int? parseCents(String? value) {
    if (value == null || value.isEmpty || value.contains('-')) return null;
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.isEmpty ? null : int.tryParse(digits);
  }

  static int? parseSignedCents(String? value) {
    if (value == null || value.isEmpty) return null;
    final trimmed = value.trim();
    final isNegative = trimmed.startsWith('-');
    if (trimmed.contains('-') && !isNegative) return null;

    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    final cents = int.tryParse(digits);
    if (cents == null) return null;
    return isNegative ? -cents : cents;
  }
}
