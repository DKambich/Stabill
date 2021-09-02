import 'package:flutter/material.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/widgets/balance_text.dart';
import 'package:intl/intl.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final GestureLongPressStartCallback? onLongPress;

  const TransactionCard({Key? key, required this.transaction, this.onLongPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double amount = transaction.method == TransactionType.Withdrawal
        ? -transaction.amount
        : transaction.amount;
    return Card(
      child: GestureDetector(
        onLongPressStart: onLongPress,
        child: InkWell(
          onTap: onLongPress != null ? () {} : null,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
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
                          color:
                              transaction.cleared ? Colors.black : Colors.grey,
                        ),
                      ),
                      Text(
                        "Check Number: ${transaction.checkNumber == -1 ? "None" : transaction.checkNumber}",
                        style: TextStyle(
                          color:
                              transaction.cleared ? Colors.black : Colors.grey,
                        ),
                      ),
                      Text(
                        "Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(transaction.timestamp)}",
                        style: TextStyle(
                          color:
                              transaction.cleared ? Colors.black : Colors.grey,
                        ),
                      ),
                      Text(
                        "Memo: ${transaction.memo}",
                        style: TextStyle(
                          color:
                              transaction.cleared ? Colors.black : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                BalanceText(text: "", balance: amount)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
