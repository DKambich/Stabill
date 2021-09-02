import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/widgets/balance_text.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final GestureLongPressStartCallback? onLongPress;

  const AccountCard({
    Key? key,
    required this.account,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String name = account.name;
    double currentBalance = account.currentBalance,
        availableBalance = account.availableBalance;

    return Card(
      child: GestureDetector(
        onTap: onTap,
        onLongPressStart: onLongPress,
        child: InkWell(
          onTap: onTap != null || onLongPress != null ? () {} : null,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                Column(
                  children: [
                    BalanceText(
                      text: "Current: ",
                      balance: currentBalance,
                    ),
                    BalanceText(
                      text: "Available: ",
                      balance: availableBalance,
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
