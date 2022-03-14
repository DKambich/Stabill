import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:oktoast/oktoast.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/widgets/balance_text.dart';

class TransactionDetailsDialog extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailsDialog({Key? key, required this.transaction})
      : super(key: key);

  static Future<void> show(
    BuildContext context,
    Transaction transaction,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return TransactionDetailsDialog(
            transaction: transaction,
          );
        },
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String name = transaction.name;
    final String amount =
        BalanceText.formatAmount(transaction.amount.toDouble());
    final String timestamp =
        DateFormat('MM/dd/yyyy hh:mm a').format(transaction.timestamp);
    final String checkNumber = transaction.checkNumber == -1
        ? "None"
        : transaction.checkNumber.toString();
    final String memo = transaction.memo;

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Details")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: name));
                  showToast("Transaction Name Copied");
                },
                child: TextField(
                  controller: TextEditingController(text: name),
                  decoration: textInputDecoration(
                    labelText: "Name",
                    prefixIcon: Icons.label_rounded,
                  ),
                  enabled: false,
                ),
              ),
              formFieldSpace,
              formFieldSpace,
              GestureDetector(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: amount));
                  showToast("Transaction Amount Copied");
                },
                child: TextField(
                  controller: TextEditingController(
                    text: amount,
                  ),
                  decoration: textInputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  enabled: false,
                ),
              ),
              formFieldSpace,
              formFieldSpace,
              GestureDetector(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: timestamp));
                  showToast("Transaction Date Copied");
                },
                child: TextField(
                  controller: TextEditingController(
                    text: timestamp,
                  ),
                  decoration: textInputDecoration(
                    labelText: "Date",
                    prefixIcon: Icons.event_rounded,
                  ),
                  enabled: false,
                ),
              ),
              formFieldSpace,
              formFieldSpace,
              GestureDetector(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: checkNumber));
                  showToast(
                    "Transaction Check Number Copied",
                  );
                },
                child: TextField(
                  controller: TextEditingController(
                    text: checkNumber,
                  ),
                  decoration: textInputDecoration(
                    labelText: "Check Number",
                    prefixIcon: Icons.pin,
                  ),
                  enabled: false,
                ),
              ),
              formFieldSpace,
              formFieldSpace,
              CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                shape: checkboxFieldShape,
                tileColor: formFieldFill(Theme.of(context).brightness),
                title: const Text("Transaction Cleared"),
                onChanged: null,
                value: transaction.cleared,
              ),
              formFieldSpace,
              formFieldSpace,
              Container(
                decoration: BoxDecoration(
                  color: formFieldFill(Theme.of(context).brightness),
                  borderRadius: const BorderRadius.all(fieldRadius),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: RadioListTile<TransactionType>(
                        title: const Text("Withdrawal"),
                        value: TransactionType.withdrawal,
                        groupValue: transaction.method,
                        onChanged: null,
                      ),
                    ),
                    Flexible(
                      child: RadioListTile<TransactionType>(
                        title: const Text("Deposit"),
                        value: TransactionType.deposit,
                        groupValue: transaction.method,
                        onChanged: null,
                      ),
                    ),
                  ],
                ),
              ),
              formFieldSpace,
              formFieldSpace,
              GestureDetector(
                onLongPress: () async {
                  await Clipboard.setData(ClipboardData(text: memo));
                  showToast("Transaction Memo Copied");
                },
                child: TextField(
                  controller: TextEditingController(text: memo),
                  decoration: textInputDecoration(
                    labelText: "Memo",
                    prefixIcon: Icons.sticky_note_2_rounded,
                  ),
                  maxLines: null,
                  enabled: false,
                ),
              ),
              formFieldSpace,
            ],
          ),
        ),
      ),
    );
  }
}
