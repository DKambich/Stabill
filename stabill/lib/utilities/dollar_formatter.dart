import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class DollarTextInputFormatter extends TextInputFormatter {
  final bool allowNegative;
  final int maxDigits;
  final NumberFormat format = NumberFormat.currency(symbol: r"$");

  DollarTextInputFormatter({this.allowNegative = false, this.maxDigits = -1});

  String _formatDollarStr(String input) {
    // Keep all numeric and hyphen characters
    String text = input.replaceAll(RegExp(r"[^\d-]"), "");

    // If the next input character is a hyphen
    if (text.endsWith("-")) {
      // If the text is already negative
      if (text.startsWith("-")) {
        // Remove the new hyphen
        text = text.substring(0, text.length - 1);
      } else {
        // Add the hyphen to the start and remove the new hyphen from the end
        text = "-" + text.substring(0, text.length - 1);
      }
    }

    // Insert the decimal point
    text = text.substring(0, text.length - 2) +
        "." +
        text.substring(text.length - 2);

    // Format as a currency
    return format.format(double.parse(text));
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Form the new input a decimal
    String currencyStr = _formatDollarStr(newValue.text);

    // If there is a digit constraint, and the new input exceeds it, return the old vallue
    if (maxDigits > 0 &&
        currencyStr.replaceAll(RegExp(r"[^\d]"), "").length > maxDigits) {
      return oldValue;
    }

    // If there is a negative constraint
    if (!allowNegative) {
      // Remove the negative from the string
      if (currencyStr.startsWith("-")) {
        currencyStr = currencyStr.substring(1);
      }
    } else {
      // Don't allow negative zero
      if (currencyStr == r"-$0.00") {
        currencyStr = currencyStr.substring(1);
      }
    }

    // Return the formatted value
    return TextEditingValue(
      text: currencyStr,
      selection: TextSelection(
        baseOffset: currencyStr.length,
        extentOffset: currencyStr.length,
      ),
      composing: TextRange.empty,
    );
  }
}
