import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Details")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: TextEditingController(text: transaction.name),
                decoration: textInputDecoration(
                  labelText: "Name",
                  prefixIcon: Icons.label_rounded,
                ),
                readOnly: true,
              ),
              formFieldSpace,
              formFieldSpace,
              TextField(
                controller: TextEditingController(
                  text: BalanceText.formatAmount(transaction.amount.toDouble()),
                ),
                decoration: textInputDecoration(
                  labelText: "Amount",
                  prefixIcon: Icons.attach_money_rounded,
                ),
                readOnly: true,
              ),
              formFieldSpace,
              formFieldSpace,
              TextField(
                controller: TextEditingController(
                  text: DateFormat('MM/dd/yyyy hh:mm a')
                      .format(transaction.timestamp),
                ),
                decoration: textInputDecoration(
                  labelText: "Date",
                  prefixIcon: Icons.event_rounded,
                ),
                readOnly: true,
              ),
              formFieldSpace,
              formFieldSpace,
              TextField(
                controller: TextEditingController(
                  text: transaction.checkNumber == -1
                      ? "None"
                      : transaction.checkNumber.toString(),
                ),
                decoration: textInputDecoration(
                  labelText: "Check Number",
                  prefixIcon: Icons.pin,
                ),
                readOnly: true,
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
              TextField(
                controller: TextEditingController(text: transaction.memo),
                decoration: textInputDecoration(
                  labelText: "Memo",
                  prefixIcon: Icons.sticky_note_2_rounded,
                ),
                maxLines: null,
                readOnly: true,
              ),
              formFieldSpace,
            ],
          ),
        ),
      ),
    );
  }
}
