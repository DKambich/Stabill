import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceText extends StatelessWidget {
  final bool showPositivePrefix;
  final bool showNegativePrefix;
  final String prefixText;
  final int balance;
  final double fontSize;
  static final NumberFormat format = NumberFormat.currency(symbol: r"$");

  const BalanceText({
    Key? key,
    this.fontSize = 18,
    this.prefixText = "",
    required this.balance,
    this.showPositivePrefix = false,
    this.showNegativePrefix = true,
  }) : super(key: key);

  Color? getBalanceColor(BuildContext context, int balance) {
    if (balance > 0) {
      return Colors.green;
    } else if (balance < 0) {
      return Colors.red;
    } else {
      return Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    String balanceText = format.format(balance.toDouble() / 100);
    if (!showNegativePrefix) {
      balanceText = balanceText.substring(1);
    } else if (balance > 0 && showPositivePrefix) {
      balanceText = "+$balanceText";
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize),
        children: <TextSpan>[
          TextSpan(
            text: prefixText,
            style: const TextStyle(color: Colors.grey),
          ),
          TextSpan(
            text: balanceText,
            style: TextStyle(
              color: getBalanceColor(context, balance),
            ),
          ),
        ],
      ),
    );
  }
}
