import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stabill/models/scheduled_transaction.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/utilities/menu_card.dart';
import 'package:stabill/widgets/balance_text.dart';

enum ScheduledTransactionAction { edit, delete }

class ScheduledTransactionCard extends StatelessWidget {
  final ScheduledTransaction scheduledTransaction;
  final void Function(ScheduledTransactionAction?)? onSelect;

  static const actions = [
    PopupMenuItem<ScheduledTransactionAction>(
      value: ScheduledTransactionAction.edit,
      child: ListTile(
        leading: Icon(Icons.edit_rounded),
        title: Text("Edit"),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    ),
    PopupMenuItem<ScheduledTransactionAction>(
      value: ScheduledTransactionAction.delete,
      child: ListTile(
        leading: Icon(Icons.delete_rounded),
        title: Text("Delete"),
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    ),
  ];

  const ScheduledTransactionCard({
    Key? key,
    required this.scheduledTransaction,
    this.onSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Transaction transaction = scheduledTransaction.transaction;
    final int amount = transaction.method == TransactionType.withdrawal
        ? -transaction.amount
        : transaction.amount;

    return MenuCard(
      actions: actions,
      onSelect: onSelect,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Occurs ${scheduledTransaction.frequency.toFormattedString()} at ${DateFormat('hh:mm a').format(transaction.timestamp)}",
                  ),
                  Text(
                    "Account: ${scheduledTransaction.accountID}",
                  ),
                  Text(
                    "Mark as cleared: ${transaction.cleared ? "Yes" : "No"}",
                  ),
                  Text(
                    "Show Notifications: ${scheduledTransaction.showNotifications ? "Yes" : "No"}",
                  ),
                  Text(
                    "Next Occurence: ${DateFormat('MM/dd/yy').format(transaction.timestamp)}",
                  ),
                ],
              ),
            ),
            Expanded(
              child: BalanceText(
                balance: amount,
                showPositivePrefix: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
