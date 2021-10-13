import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/dollar_formatter.dart';
import 'package:stabill/widgets/prompts/prompt.dart';

class TransferFundsPrompt extends StatefulWidget {
  final String? defaultAccountID;

  const TransferFundsPrompt({Key? key, this.defaultAccountID})
      : super(key: key);

  @override
  _TransferFundsPromptState createState() => _TransferFundsPromptState();

  static void show(BuildContext context, {String? defaultAccountID}) {
    Prompt.show(
      context,
      TransferFundsPrompt(defaultAccountID: defaultAccountID),
    );
  }
}

class _TransferFundsPromptState extends State<TransferFundsPrompt> {
  // Firebase Variables
  late Future<QuerySnapshot<Account>> _accountsFuture;

  // Form Variables
  late GlobalKey<FormState> _formKey;
  late Account _fromAccount;
  late Account _toAccount;
  late TextEditingController _balanceController;

  @override
  void initState() {
    // Initialize Firebase variables
    _accountsFuture =
        context.read<DataProvider>().getAccountsCollection().get();

    // Initialize Form variables
    _formKey = GlobalKey<FormState>();

    _fromAccount = Account();
    _toAccount = Account();
    _balanceController = TextEditingController(text: r"$0.00");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Account>>(
      future: _accountsFuture,
      builder: (ctx, snapshot) {
        // If there is an error, notify the user and pop the prompt
        if (snapshot.hasError) {
          // TODO: Notify user there was an error
          Navigator.pop(context);
          return const SizedBox.shrink();
        }

        // If it is loading, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 164.0),
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        // If there is no data or there are not enough accounts, notify the user and pop the prompt
        if (!snapshot.hasData || snapshot.data!.docs.length < 2) {
          // TODO: Notify user there are not enough accounts to transfer between
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

        return Prompt(
          title: "Transfer Funds",
          onCancel: () => Navigator.pop(context),
          onConfirm: () async {
            // Validate the form
            if (_formKey.currentState!.validate()) {
              // Get the amount to transfer
              final int transferAmount = int.parse(
                _balanceController.text.replaceAll(RegExp(r"[^\d]"), ""),
              );

              // Initiate the transfer
              await context.read<DataProvider>().transferFunds(
                    _fromAccount,
                    _toAccount,
                    transferAmount,
                  );

              if (!mounted) return;
              Navigator.pop(context);
            }
          },
          formBody: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<Account>(
                  decoration: const InputDecoration(labelText: "Transfer from"),
                  items: dropdownItems,
                  value: _fromAccount,
                  onChanged: (Account? newValue) =>
                      setState(() => _fromAccount = newValue ?? _fromAccount),
                ),
                DropdownButtonFormField<Account>(
                  decoration: const InputDecoration(labelText: "Transfer to"),
                  items: dropdownItems,
                  value: _toAccount,
                  onChanged: (Account? newValue) =>
                      setState(() => _toAccount = newValue ?? _toAccount),
                  validator: (account) => account == _fromAccount
                      ? 'Transfer accounts cannot be the same'
                      : null,
                ),
                TextFormField(
                  controller: _balanceController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  enableInteractiveSelection: false,
                  inputFormatters: [DollarTextInputFormatter(maxDigits: 7)],
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.go,
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
}
