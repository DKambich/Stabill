import 'package:flutter/material.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/pages/transactions_page.dart';
import 'package:stabill/widgets/balance_text.dart';
import 'package:intl/intl.dart';

enum TransactionAction { Clear, Hide, Move, Edit, Delete }

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final GestureTapDownCallback? onMorePress;
  final List<PopupMenuEntry<TransactionAction>> actions;
  final void Function(TransactionAction)? onSelected;

  const TransactionCard(
      {Key? key,
      required this.transaction,
      this.onMorePress,
      required this.actions,
      this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double amount = transaction.method == TransactionType.Withdrawal
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: transaction.cleared ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    "Check Number: ${transaction.checkNumber == -1 ? "None" : transaction.checkNumber}",
                    style: TextStyle(
                      color: transaction.cleared ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    "Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(transaction.timestamp)}",
                    style: TextStyle(
                      color: transaction.cleared ? Colors.black : Colors.grey,
                    ),
                  ),
                  Text(
                    "Memo: ${transaction.memo}",
                    style: TextStyle(
                      color: transaction.cleared ? Colors.black : Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            BalanceText(text: "", balance: amount),
            PopupMenuButton<TransactionAction>(
              itemBuilder: (_) => actions,
              onSelected: onSelected,
              padding: EdgeInsets.zero,
              tooltip: "Show Actions",
              child: Icon(Icons.more_vert),
            )
          ],
        ),
      ),
    );
  }
}
