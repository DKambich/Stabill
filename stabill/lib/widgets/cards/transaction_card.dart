import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/utilities/menu_card.dart';
import 'package:stabill/widgets/balance_text.dart';
import 'package:substring_highlight/substring_highlight.dart';

enum TransactionAction { clear, hide, move, edit, delete }

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
    final int amount = transaction.method == TransactionType.withdrawal
        ? -transaction.amount
        : transaction.amount;

    final Color? fontColor = transaction.cleared ? null : Colors.grey;
    return MenuCard<TransactionAction>(
      actions: buildActions(),
      onSelect: (action) {
        if (action != null && onSelected != null) onSelected!(action);
      },
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
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
          Expanded(
            child: BalanceText(
              balance: amount,
              showPositivePrefix: true,
            ),
          ),
        ],
      ),
    );
  }

  List<PopupMenuItem<TransactionAction>> buildActions() {
    return [
      if (transaction.cleared)
        const PopupMenuItem<TransactionAction>(
          value: TransactionAction.hide,
          child: ListTile(
            leading: Icon(Icons.visibility_off),
            title: Text("Hide"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      if (!transaction.cleared)
        const PopupMenuItem<TransactionAction>(
          value: TransactionAction.clear,
          child: ListTile(
            leading: Icon(Icons.check),
            title: Text("Mark Cleared"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      const PopupMenuItem<TransactionAction>(
        value: TransactionAction.move,
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text("Move"),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem<TransactionAction>(
        value: TransactionAction.edit,
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text("Edit"),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem<TransactionAction>(
        value: TransactionAction.delete,
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text("Delete"),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];
  }
}
