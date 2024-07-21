import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/dollar_formatter.dart';

class TransferFundsPrompt extends StatefulWidget {
  final String? defaultAccountID;

  const TransferFundsPrompt({Key? key, this.defaultAccountID})
      : super(key: key);

  @override
  _TransferFundsPromptState createState() => _TransferFundsPromptState();

  static void show(BuildContext context, {String? defaultAccountID}) {
    showDialog(
      context: context,
      builder: (_) => TransferFundsPrompt(defaultAccountID: defaultAccountID),
    );
  }
}

class _TransferFundsPromptState extends State<TransferFundsPrompt> {
  // Firebase Variables
  late Future<QuerySnapshot<Account>> _accountsFuture;

  // Form Variables
  late GlobalKey<FormState> _formKey;
  late TextEditingController _balanceController;

  late Account _fromAccount;
  late Account _toAccount;

  @override
  void initState() {
    super.initState();

    // Initialize Firebase variables
    _accountsFuture =
        context.read<DataProvider>().getAccountsCollection().get();

    // Initialize Form variables
    _formKey = GlobalKey<FormState>();
    _balanceController = TextEditingController(text: "\$0.00");

    _fromAccount = Account();
    _toAccount = Account();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Account>>(
      future: _accountsFuture,
      builder: (ctx, snapshot) {
        // If there is an error, notify the user and pop the prompt
        if (snapshot.hasError) {
          showToast(
            "An error occured, please try again",
          );
          Navigator.pop(context);
          return const SizedBox.shrink();
        }

        // If it is loading, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 164.0),
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        // If there is no data or there are not enough accounts, notify the user and pop the prompt
        if (!snapshot.hasData || snapshot.data!.docs.length < 2) {
          showToast(
            "Create at least two accounts to transfer funds",
          );
          Navigator.pop(context);
          return const SizedBox.shrink();
        }

        // Retrieve the accounts from the collection
        final List<QueryDocumentSnapshot<Account>> accounts =
            snapshot.data!.docs;

        // Set the default account IDs if they are not initialized
        if (_fromAccount.id == "" || _toAccount.id == "") {
          // Use the provided default account if specified
          if (widget.defaultAccountID != null) {
            _fromAccount = accounts
                .firstWhere((account) => account.id == widget.defaultAccountID)
                .data();

            _toAccount = _fromAccount;
          } else {
            _fromAccount = accounts[0].data();
            _toAccount = accounts[1].data();
          }
        }

        // Map each account to a DropdownMenuItem
        final List<DropdownMenuItem<Account>> dropdownItems = accounts
            .map(
              (value) => DropdownMenuItem(
                value: value.data(),
                child: Text(value.data().name),
              ),
            )
            .toList();

        return AlertDialog(
          shape: dialogShape,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: submitForm,
              child: const Text("Confirm"),
            ),
          ],
          title: const Text("Transfer Funds"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Account>(
                  decoration: textInputDecoration(labelText: "Transfer From"),
                  items: dropdownItems,
                  value: _fromAccount,
                  onChanged: (Account? newValue) =>
                      setState(() => _fromAccount = newValue ?? _fromAccount),
                ),
                dialogFieldSpace,
                DropdownButtonFormField<Account>(
                  decoration: textInputDecoration(labelText: "Transfer To"),
                  items: dropdownItems,
                  value: _toAccount,
                  onChanged: (Account? newValue) =>
                      setState(() => _toAccount = newValue ?? _toAccount),
                  validator: (account) => account == _fromAccount
                      ? 'Transfer accounts cannot be the same'
                      : null,
                ),
                dialogFieldSpace,
                TextFormField(
                  controller: _balanceController,
                  decoration: textInputDecoration(
                    labelText: "Amount",
                    prefixIcon: Icons.attach_money_rounded,
                  ),
                  enableInteractiveSelection: false,
                  inputFormatters: [DollarTextInputFormatter(maxDigits: 7)],
                  keyboardType: TextInputType.number,
                  onFieldSubmitted: (_) => submitForm(),
                  textInputAction: TextInputAction.done,
                  validator: (amount) =>
                      (amount == null || amount == "" || amount == "\$0.00")
                          ? 'Transfer amount cannot be zero'
                          : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> submitForm() async {
    // Validate the form
    if (_formKey.currentState!.validate()) {
      // Get the amount to transfer
      final int transferAmount = int.parse(
        _balanceController.text.replaceAll(RegExp(r"[^\d]"), ""),
      );

      // Transfer the amount
      if (await context.read<DataProvider>().transferFunds(
                _fromAccount,
                _toAccount,
                transferAmount,
              ) ==
          false) {
        showToast("Failed to transfer funds, try again");
      }

      if (mounted) Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _balanceController.dispose();
  }
}
