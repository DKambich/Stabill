import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' show QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/utilities/dollar_formatter.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';

class TransactionModal extends StatefulWidget {
  static const String routeName = "/transaction";
  final Transaction? transaction;
  final String accountID;

  const TransactionModal({
    Key? key,
    // ignore: avoid_init_to_null
    this.transaction = null,
    required this.accountID,
  }) : super(key: key);

  @override
  _TransactionModalState createState() => _TransactionModalState();
}

class _TransactionModalState extends State<TransactionModal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late bool isCleared;
  late TransactionType method = TransactionType.withdrawal;
  late String transactionName;
  late TextEditingController amountController;
  late TextEditingController dateController;
  late TextEditingController checkNumberController;
  late TextEditingController memoController;
  late DateTime timestamp;

  late List<String> autocompleteNameOptions;

  @override
  void initState() {
    autocompleteNameOptions = [];

    // Get a reference to the transaction collection for the account
    final transactionCollection =
        context.read<DataProvider>().getTransactionCollection(widget.accountID);
    final PreferenceProvider preferenceProvider =
        context.read<PreferenceProvider>();
    final int historyLimit = preferenceProvider.autocompleteHistoryLimit;
    // Get the 100 most recent transactions
    transactionCollection
        .orderBy("timestamp", descending: true)
        .limit(historyLimit)
        .get()
        .then(onLoadAutocompleteOptions);

    // If the transaction exists, update data fields to use it's initial data
    if (widget.transaction != null) {
      isCleared = widget.transaction!.cleared;
      method = widget.transaction!.method;
      transactionName = widget.transaction!.name;
      timestamp = widget.transaction!.timestamp;
      final String transactionDate =
          DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
      dateController = TextEditingController(text: transactionDate);
      amountController = TextEditingController(
        text: "\$${(widget.transaction!.amount / 100).toStringAsFixed(2)}",
      );
      checkNumberController = TextEditingController(
        text:
            "${widget.transaction!.checkNumber != -1 ? widget.transaction!.checkNumber : ""}",
      );
      memoController = TextEditingController(
        text: widget.transaction!.memo,
      );
    } else {
      isCleared = false;
      method = TransactionType.withdrawal;
      transactionName = "";
      timestamp = DateTime.now();
      final String transactionDate =
          DateFormat('MM/dd/yyyy hh:mm a').format(timestamp);
      dateController = TextEditingController(text: transactionDate);
      amountController = TextEditingController(text: "\$0.00");
      checkNumberController = TextEditingController(text: "");
      memoController = TextEditingController(text: "");
    }
    super.initState();
  }

  void onLoadAutocompleteOptions(
    QuerySnapshot<Transaction> recentTransactions,
  ) {
    setState(() {
      final List<String> recentTransactionNames = recentTransactions.docs
          .map<String>((transaction) => transaction.data().name)
          .toList();

      final Map<String, int> frequencyMap = <String, int>{};
      for (final String transactionName in recentTransactionNames) {
        frequencyMap.update(
          transactionName,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
      }
      final List<String> sortedOptions =
          frequencyMap.keys.toList(growable: false);
      sortedOptions.sort((String a, String b) {
        final int order = frequencyMap[a]!.compareTo(frequencyMap[b]!);
        return order == 0 ? a.compareTo(b) : order * -1;
      });
      autocompleteNameOptions = sortedOptions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String action = widget.transaction != null ? "Edit" : "Add";
    return Scaffold(
      appBar: AppBar(
        title: Text('$action Transaction'),
        actions: [
          IconButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (widget.transaction != null) {
                  final bool confirm = await ConfirmDialog.show(
                    context,
                    "Update Transaction",
                    "Are you sure you want to update the transaction '${widget.transaction!.name}'?",
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
                  name: transactionName,
                  method: method,
                  timestamp: timestamp,
                );
                if (!mounted) return;
                Navigator.of(context).pop<Transaction>(savedTransaction);
              }
            },
            icon: const Icon(Icons.check_rounded),
          ),
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
                formFieldSpace,
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Autocomplete(
                        initialValue: TextEditingValue(text: transactionName),
                        onSelected: (String selection) => setState(() {
                          transactionName = selection;
                        }),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          return autocompleteNameOptions.where(
                            (String option) => option
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()),
                          );
                        },
                        fieldViewBuilder: (
                          BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted,
                        ) {
                          return TextFormField(
                            autofocus: true,
                            controller: textEditingController,
                            focusNode: focusNode,
                            decoration: textInputDecoration(
                              labelText: "Name",
                              prefixIcon: Icons.label_rounded,
                            ),
                            keyboardType: TextInputType.text,
                            onChanged: (String value) {
                              setState(() {
                                transactionName = value;
                              });
                            },
                            onFieldSubmitted: (String value) {
                              onFieldSubmitted();
                            },
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            validator: (String? text) {
                              if (text != null && text.isNotEmpty) {
                                return null;
                              }
                              return "Name must be at least one character";
                            },
                          );
                        },
                        optionsViewBuilder: (
                          BuildContext context,
                          AutocompleteOnSelected<String> onSelected,
                          Iterable<String> options,
                        ) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              elevation: 4.0,
                              borderRadius: const BorderRadius.all(cardRadius),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: min(options.length, 3) * 56 + 16,
                                  maxWidth: constraints.biggest.width,
                                ),
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  itemCount: options.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    final String option =
                                        options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextFormField(
                    controller: amountController,
                    decoration: textInputDecoration(
                      labelText: "Amount",
                      prefixIcon: Icons.attach_money_rounded,
                    ),
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
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextFormField(
                    controller: dateController,
                    decoration: textInputDecoration(
                      labelText: "Date",
                      prefixIcon: Icons.event_rounded,
                    ),
                    readOnly: true,
                    onTap: () => showDateTime(timestamp),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextFormField(
                    controller: checkNumberController,
                    decoration: textInputDecoration(
                      labelText: "Check Number",
                      prefixIcon: Icons.pin,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: CheckboxListTile(
                    shape: checkboxFieldShape,
                    tileColor: formFieldFill(Theme.of(context).brightness),
                    value: isCleared,
                    onChanged: (_) {
                      setState(() {
                        isCleared = !isCleared;
                      });
                    },
                    title: const Text("Mark as cleared"),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: DecoratedBox(
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
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextFormField(
                    controller: memoController,
                    decoration: textInputDecoration(
                      labelText: "Memo",
                      prefixIcon: Icons.sticky_note_2_rounded,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                formFieldSpace,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showDateTime(DateTime? initialDateTime) async {
    // Get the current DateTime
    final DateTime now = initialDateTime ?? DateTime.now();

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
          initialTime: TimeOfDay.fromDateTime(now),
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
