import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';

class TransactionModal extends StatefulWidget {
  static final String routeName = "/transaction";
  final Transaction? transaction;
  TransactionModal({
    Key? key,
    // ignore: avoid_init_to_null
    this.transaction = null,
  }) : super(key: key);

  @override
  _TransactionModalState createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late bool isCleared;
  late TransactionType method = TransactionType.Withdrawal;
  late TextEditingController nameController,
      amountController,
      dateController,
      checkNumberController,
      memoController;
  late DateTime timestamp;

  @override
  void initState() {
    if (widget.transaction != null) {
      isCleared = widget.transaction!.cleared;
      method = widget.transaction!.method;
      nameController = TextEditingController(text: widget.transaction!.name);
      timestamp = widget.transaction!.timestamp;
      String transactionDate =
          DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
      dateController = TextEditingController(text: transactionDate);
      amountController = TextEditingController(
          text: "\$${(widget.transaction!.amount / 100).toStringAsFixed(2)}");
      checkNumberController = TextEditingController(
          text:
              "${widget.transaction!.checkNumber != -1 ? widget.transaction!.checkNumber : ""}");
      memoController =
          TextEditingController(text: "${widget.transaction!.memo}");
    } else {
      isCleared = false;
      method = TransactionType.Withdrawal;
      nameController = TextEditingController(text: "");
      timestamp = DateTime.now();
      String transactionDate =
          DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
      dateController = TextEditingController(text: transactionDate);
      amountController = TextEditingController(text: "\$0.00");
      checkNumberController = TextEditingController(text: "");
      memoController = TextEditingController(text: "");
    }

    amountController.addListener(() {
      String dollarStr = Account.formatDollarStr(amountController.text
          .substring(0, min(amountController.text.length, 10)));

      amountController.value = amountController.value.copyWith(
        text: dollarStr,
        selection: TextSelection(
          baseOffset: dollarStr.length,
          extentOffset: dollarStr.length,
        ),
        composing: TextRange.empty,
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String action = widget.transaction != null ? "Edit" : "Add";
    return Scaffold(
      appBar: AppBar(
        title: Text('$action Transaction'),
        actions: [
          IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (widget.transaction != null) {
                    bool confirm = await ConfirmDialog.show(
                      context,
                      "Update Transaction",
                      "Are you sure you want to update the transaction '${widget.transaction!.name}'?",
                    );
                    if (!confirm) {
                      return;
                    }
                  }
                  int checkNumber = checkNumberController.text.length > 0
                      ? int.parse(checkNumberController.text)
                      : -1;
                  Transaction savedTransaction = Transaction(
                    amount: int.parse(
                      amountController.text.substring(1).replaceAll(".", ""),
                    ),
                    checkNumber: checkNumber,
                    cleared: isCleared,
                    memo: memoController.text,
                    name: nameController.text,
                    method: method,
                    timestamp: timestamp,
                  );
                  Navigator.of(context).pop<Transaction>(savedTransaction);
                }
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Name"),
                    keyboardType: TextInputType.text,
                    validator: (String? text) {
                      if (text != null && text.length > 0) {
                        return null;
                      }
                      return "Name must be at least one character";
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: amountController,
                    decoration: InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                    validator: (String? text) {
                      if (text != null && double.parse(text.substring(1)) > 0) {
                        return null;
                      }
                      return "Amount must be greater than 0";
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: dateController,
                    decoration: InputDecoration(labelText: "Date"),
                    readOnly: true,
                    onTap: showDateTime,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: checkNumberController,
                    decoration: InputDecoration(labelText: "Check Number"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                CheckboxListTile(
                  value: isCleared,
                  onChanged: (_) {
                    setState(() {
                      isCleared = !isCleared;
                    });
                  },
                  title: Text("Mark as cleared"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Row(
                  children: [
                    Flexible(
                      child: RadioListTile<TransactionType>(
                        title: Text("Withdrawal"),
                        value: TransactionType.Withdrawal,
                        groupValue: method,
                        onChanged: (TransactionType? value) => setState(
                          () => method = TransactionType.Withdrawal,
                        ),
                      ),
                    ),
                    Flexible(
                      child: RadioListTile<TransactionType>(
                        title: Text("Deposit"),
                        value: TransactionType.Deposit,
                        groupValue: method,
                        onChanged: (TransactionType? value) => setState(
                          () => method = TransactionType.Deposit,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: memoController,
                    decoration: InputDecoration(labelText: "Memo"),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDateTime() async {
    // Get the current DateTime
    DateTime now = DateTime.now();

    // Get the selected date or use the current date if canceled
    DateTime selectedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(0),
          lastDate: now.add(Duration(days: 365)),
        ) ??
        now;

    // Get the selected time or use the current time if canceled
    TimeOfDay selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ) ??
        TimeOfDay.fromDateTime(now);

    // Create a new date from the selected date and time
    timestamp = DateTime(selectedDate.year, selectedDate.month,
        selectedDate.day, selectedTime.hour, selectedTime.minute);

    // Update the date form field
    dateController.text = DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
  }
}
