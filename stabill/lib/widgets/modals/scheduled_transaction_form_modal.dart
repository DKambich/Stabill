import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stabill/models/scheduled_transaction.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/utilities/dollar_formatter.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';

class ScheduledTransactionModal extends StatefulWidget {
  static const String routeName = "/scheduledTransaction";
  final ScheduledTransaction? transaction;
  const ScheduledTransactionModal({
    Key? key,
    // ignore: avoid_init_to_null
    this.transaction = null,
  }) : super(key: key);

  @override
  _ScheduledTransactionModalState createState() =>
      _ScheduledTransactionModalState();
}

class _ScheduledTransactionModalState extends State<ScheduledTransactionModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late bool isCleared;
  late TransactionType method = TransactionType.withdrawal;
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController dateController;
  late TextEditingController checkNumberController;
  late TextEditingController memoController;
  late DateTime timestamp;

  @override
  void initState() {
    // if (widget.transaction != null) {
    // isCleared = widget.transaction!.cleared;
    // method = widget.transaction!.method;
    // nameController = TextEditingController(text: widget.transaction!.name);
    // timestamp = widget.transaction!.timestamp;
    // final String transactionDate =
    //     DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
    // dateController = TextEditingController(text: transactionDate);
    // amountController = TextEditingController(
    //   text: "\$${(widget.transaction!.amount / 100).toStringAsFixed(2)}",
    // );
    // checkNumberController = TextEditingController(
    //   text:
    //       "${widget.transaction!.checkNumber != -1 ? widget.transaction!.checkNumber : ""}",
    // );
    // memoController = TextEditingController(
    //   text: widget.transaction!.memo,
    // );
    // } else {
    isCleared = false;
    method = TransactionType.withdrawal;
    nameController = TextEditingController(text: "");
    timestamp = DateTime.now();
    final String transactionDate =
        DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
    dateController = TextEditingController(text: transactionDate);
    amountController = TextEditingController(text: "\$0.00");
    checkNumberController = TextEditingController(text: "");
    memoController = TextEditingController(text: "");
    // }

    // amountController.addListener(() {
    //   String dollarStr = Account.formatDollarStr(amountController.text
    //       .substring(0, min(amountController.text.length, 10)));

    //   amountController.value = amountController.value.copyWith(
    //     text: dollarStr,
    //     selection: TextSelection(
    //       baseOffset: dollarStr.length,
    //       extentOffset: dollarStr.length,
    //     ),
    //     composing: TextRange.empty,
    //   );
    // });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final String action = widget.transaction != null ? "Edit" : "Add";
    return Scaffold(
      appBar: AppBar(
        title: Text('$action Scheduled Transaction'),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (widget.transaction != null) {
                  final bool confirm = await ConfirmDialog.show(
                    context,
                    "Update Scheduled Transaction",
                    "Are you sure you want to update the scheduled transaction?",
                  );
                  if (!confirm) {
                    return;
                  }
                }
                final int checkNumber = checkNumberController.text.isNotEmpty
                    ? int.parse(checkNumberController.text)
                    : -1;
                final Transaction savedTransaction = Transaction(
                  amount: int.parse(
                    amountController.text.replaceAll(RegExp(r"[^\d]"), ""),
                  ),
                  checkNumber: checkNumber,
                  cleared: isCleared,
                  memo: memoController.text,
                  name: nameController.text,
                  method: method,
                  timestamp: timestamp,
                );
                if (!mounted) return;
                Navigator.of(context).pop<Transaction>(savedTransaction);
              }
            },
            icon: const Icon(Icons.check),
          )
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
                    decoration: const InputDecoration(labelText: "Name"),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    validator: (String? text) {
                      if (text != null && text.isNotEmpty) {
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
                    decoration: const InputDecoration(labelText: "Amount"),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    validator: (String? text) {
                      if (text != null &&
                          int.parse(text.replaceAll(RegExp(r"[^\d]"), "")) >
                              0) {
                        return null;
                      }
                      return "Amount must be greater than 0";
                    },
                    inputFormatters: [DollarTextInputFormatter(maxDigits: 7)],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: checkNumberController,
                    decoration:
                        const InputDecoration(labelText: "Check Number"),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4)
                    ],
                  ),
                ),
                CheckboxListTile(
                  value: isCleared,
                  onChanged: (_) {
                    setState(() {
                      isCleared = !isCleared;
                    });
                  },
                  title: const Text("Mark as cleared"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                Row(
                  children: [
                    Flexible(
                      child: RadioListTile<TransactionType>(
                        title: const Text("Withdrawal"),
                        value: TransactionType.withdrawal,
                        groupValue: method,
                        onChanged: (TransactionType? value) => setState(
                          () => method = TransactionType.withdrawal,
                        ),
                      ),
                    ),
                    Flexible(
                      child: RadioListTile<TransactionType>(
                        title: const Text("Deposit"),
                        value: TransactionType.deposit,
                        groupValue: method,
                        onChanged: (TransactionType? value) => setState(
                          () => method = TransactionType.deposit,
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
                    decoration: const InputDecoration(labelText: "Memo"),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: "Start Date"),
                    readOnly: true,
                    onTap: showDateTime,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Frequency",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: DropdownButton<Frequency>(
                      value: Frequency.once,
                      items: Frequency.values
                          .map(
                            (value) => DropdownMenuItem<Frequency>(
                              value: value,
                              child: Text(value.toString()),
                            ),
                          )
                          .toList(),
                      menuMaxHeight: 200,
                      isExpanded: true,
                      onChanged: (Frequency? newValue) {},
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Account",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: DropdownButton(
                      value: "test",
                      items: const [
                        DropdownMenuItem<String>(
                          value: "test",
                          child: Text("test"),
                        ),
                      ],
                      menuMaxHeight: 200,
                      isExpanded: true,
                      onChanged: (String? newValue) {},
                    ),
                  ),
                ),
                CheckboxListTile(
                  value: isCleared,
                  onChanged: (_) {
                    setState(() {
                      isCleared = !isCleared;
                    });
                  },
                  title:
                      const Text("Show notification when transaction is added"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: isCleared,
                  onChanged: isCleared
                      ? (_) {
                          setState(() {
                            isCleared = !isCleared;
                          });
                        }
                      : null,
                  title: const Text("Hide transaction once created"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  value: isCleared,
                  onChanged: (_) {
                    setState(() {
                      isCleared = !isCleared;
                    });
                  },
                  title: const Text("Enabled"),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showDateTime() async {
    // Get the current DateTime
    final DateTime now = DateTime.now();

    // Get the selected date or use the current date if canceled
    final DateTime selectedDate = await showDatePicker(
          context: context,
          initialDate: now,
          firstDate: DateTime(0),
          lastDate: now.add(const Duration(days: 365)),
        ) ??
        now;

    // Get the selected time or use the current time if canceled
    final TimeOfDay selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ) ??
        TimeOfDay.fromDateTime(now);

    // Create a new date from the selected date and time
    timestamp = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    // Update the date form field
    dateController.text = DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
  }
}
