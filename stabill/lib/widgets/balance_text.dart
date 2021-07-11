import 'package:flutter/material.dart';

class BalanceText extends StatelessWidget {
  final String text;
  final double balance;
  final double fontSize;

  const BalanceText(
      {Key? key, this.fontSize = 20, required this.text, required this.balance})
      : super(key: key);

  Color getBalanceColor(double balance) {
    if (balance > 0)
      return Colors.green;
    else if (balance < 0)
      return Colors.red;
    else
      return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: fontSize),
        children: <TextSpan>[
          TextSpan(text: text),
          TextSpan(
            text: '\$${balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: getBalanceColor(balance),
            ),
          ),
        ],
      ),
    );
  }
}
