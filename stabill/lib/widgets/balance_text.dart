import 'package:flutter/material.dart';

class BalanceText extends StatelessWidget {
  final bool showPositivePrefix, showNegativePrefix;
  final String prefixText;
  final int balance;
  final double fontSize;

  const BalanceText({
    Key? key,
    this.fontSize = 20,
    this.prefixText = "",
    required this.balance,
    this.showPositivePrefix = false,
    this.showNegativePrefix = true,
  }) : super(key: key);

  Color? getBalanceColor(BuildContext context, int balance) {
    if (balance > 0)
      return Colors.green;
    else if (balance < 0)
      return Colors.red;
    else
      return Theme.of(context).textTheme.bodyText1!.color;
  }

  @override
  Widget build(BuildContext context) {
    String balanceText = "";
    if (balance < 0 && showNegativePrefix) {
      balanceText = "-";
    } else if (balance > 0 && showPositivePrefix) {
      balanceText = "+";
    }

    balanceText += r"$";
    balanceText += "${(balance.abs() / 100).toStringAsFixed(2)}";

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).textTheme.caption!.color,
        ),
        children: <TextSpan>[
          TextSpan(text: prefixText),
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
