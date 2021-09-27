import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/widgets/account_list.dart';
import 'package:stabill/widgets/balance_text.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final void Function(AccountAction)? onSelected;
  final List<PopupMenuEntry<AccountAction>> actions;

  const AccountCard({
    Key? key,
    required this.account,
    this.onTap,
    this.onSelected,
    required this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = account.name;
    final int currentBalance = account.currentBalance;
    final int availableBalance = account.availableBalance;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.only(left: 24, top: 24, bottom: 24, right: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  BalanceText(
                    prefixText: "Current: ",
                    balance: currentBalance,
                  ),
                  BalanceText(
                    prefixText: "Available: ",
                    balance: availableBalance,
                  ),
                ],
              ),
              PopupMenuButton<AccountAction>(
                itemBuilder: (_) => actions,
                onSelected: onSelected,
                padding: EdgeInsets.zero,
                tooltip: "Show Actions",
              )
            ],
          ),
        ),
      ),
    );
  }
}
