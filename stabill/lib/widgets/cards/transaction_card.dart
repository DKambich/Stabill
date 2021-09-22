import 'package:flutter/material.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/widgets/balance_text.dart';
import 'package:intl/intl.dart';
import 'package:substring_highlight/substring_highlight.dart';

enum TransactionAction { Clear, Hide, Move, Edit, Delete }

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final GestureTapDownCallback? onMorePress;
  final List<PopupMenuEntry<TransactionAction>> actions;
  final void Function(TransactionAction)? onSelected;
  final String? query;

  const TransactionCard({
    Key? key,
    required this.transaction,
    this.onMorePress,
    required this.actions,
    this.onSelected,
    this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int amount = transaction.method == TransactionType.Withdrawal
        ? -transaction.amount
        : transaction.amount;

    Color? fontColor = transaction.cleared ? null : Colors.grey;
    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubstringHighlight(
                    term: query ?? "",
                    text: transaction.name,
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: transaction.cleared
                          ? Theme.of(context).brightness == Brightness.light
                              ? Colors.black
                              : Colors.white
                          : Colors.grey,
                    ),
                    textStyleHighlight: TextStyle(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.light
                              ? Colors.yellow
                              : Colors.blue,
                    ),
                  ),
                  Text(
                    "Check Number: ${transaction.checkNumber == -1 ? "None" : transaction.checkNumber}",
                    style: TextStyle(
                      color: fontColor,
                    ),
                  ),
                  Text(
                    "Date: ${DateFormat('MM/dd/yyyy hh:mm a').format(transaction.timestamp)}",
                    style: TextStyle(
                      color: fontColor,
                    ),
                  ),
                  Text(
                    "Memo: ${transaction.memo}",
                    style: TextStyle(
                      color: fontColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            BalanceText(
              balance: amount,
              showPositivePrefix: true,
            ),
            PopupMenuButton<TransactionAction>(
              itemBuilder: (_) => actions,
              onSelected: onSelected,
              padding: EdgeInsets.zero,
              tooltip: "Show Actions",
            )
          ],
        ),
      ),
    );
  }
}
