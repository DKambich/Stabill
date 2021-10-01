import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stabill/models/scheduled_transaction.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/widgets/balance_text.dart';

// enum TransactionAction { clear, hide, move, edit, delete }

class ScheduledTransactionCard extends StatelessWidget {
  final ScheduledTransaction scheduledTransaction;
  // final GestureTapDownCallback? onMorePress;
  // final List<PopupMenuEntry<TransactionAction>> actions;
  // final void Function(TransactionAction)? onSelected;
  // final String? query;

  const ScheduledTransactionCard({
    Key? key,
    required this.scheduledTransaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Transaction transaction = scheduledTransaction.transaction;
    final int amount = transaction.method == TransactionType.withdrawal
        ? -transaction.amount
        : transaction.amount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
        child: Row(
          children: [
            Expanded(
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
            BalanceText(
              balance: amount,
              showPositivePrefix: true,
            ),
          ],
        ),
      ),
    );
  }
}
