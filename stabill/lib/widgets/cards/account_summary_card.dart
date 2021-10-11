import 'package:flutter/material.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/widgets/balance_text.dart';

class AccountSummaryCard extends StatelessWidget {
  final int totalCurrentBalance;
  final int totalAvailableBalance;

  const AccountSummaryCard({
    Key? key,
    required this.totalCurrentBalance,
    required this.totalAvailableBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: topCardShape,
      margin: EdgeInsets.zero,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: BalanceText(
                prefixText: "Current: ",
                balance: totalCurrentBalance,
                fontSize: 20,
              ),
            ),
            Expanded(
              child: BalanceText(
                prefixText: "Available: ",
                balance: totalAvailableBalance,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
