import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/utilities/menu_card.dart';
import 'package:stabill/widgets/account_list.dart';
import 'package:stabill/widgets/balance_text.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback? onTap;
  final void Function(AccountAction)? onSelected;
  final List<PopupMenuItem<AccountAction>> actions;

  static const List<PopupMenuItem<AccountAction>> menuActions = [
    PopupMenuItem<AccountAction>(
      value: AccountAction.edit,
      child: ListTile(
        leading: Icon(Icons.edit_rounded),
        title: Text("Edit"),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    ),
    PopupMenuItem<AccountAction>(
      value: AccountAction.delete,
      child: ListTile(
        leading: Icon(Icons.delete_rounded),
        title: Text("Delete"),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    ),
  ];

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

    return MenuCard<AccountAction>(
      actions: actions,
      onTap: onTap,
      onSelect: (action) {
        if (action != null) onSelected?.call(action);
      },
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: AutoSizeText(
              name,
              style: const TextStyle(fontSize: 24),
              maxLines: 1,
            ),
          ),
          Expanded(
            child: Column(
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
          ),
        ],
      ),
    );
  }
}
