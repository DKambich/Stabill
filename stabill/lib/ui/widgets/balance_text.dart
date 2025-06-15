import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceText extends StatelessWidget {
  static final NumberFormat _formatCurrency = NumberFormat.simpleCurrency();
  final double balance;
  final double minFontSize;
  final double maxFontSize;
  final bool showNegative;

  final AutoSizeGroup? group;

  const BalanceText({
    super.key,
    required this.balance,
    this.showNegative = true,
    this.minFontSize = 12,
    this.maxFontSize = 24,
    this.group,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle =
        TextStyle(fontWeight: FontWeight.bold, fontSize: maxFontSize);

    final textStyle = switch (balance) {
      > 0 => baseStyle.copyWith(color: Colors.green),
      < 0 => baseStyle.copyWith(color: Colors.red),
      _ => baseStyle
    };

    return AutoSizeText(
      _formatCurrency.format(showNegative ? balance : balance.abs()),
      style: textStyle,
      minFontSize: minFontSize,
      maxFontSize: maxFontSize,
      wrapWords: false,
      group: group,
    );
  }
}
