import 'package:cloud_firestore/cloud_firestore.dart'
    show QuerySnapshot, QueryDocumentSnapshot;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/widgets/prompts/prompt.dart';

class TransferTransactionPrompt extends StatefulWidget {
  final String currentAccountID;
  final String transactionID;
  final Transaction transaction;

  const TransferTransactionPrompt({
    Key? key,
    required this.currentAccountID,
    required this.transaction,
    required this.transactionID,
  }) : super(key: key);

  @override
  _TransferFundsModalState createState() => _TransferFundsModalState();

  static void show(
    BuildContext context,
    Transaction transaction,
    String transactionID,
    String currentAccountID,
  ) {
    Prompt.show(
      context,
      TransferTransactionPrompt(
        transaction: transaction,
        transactionID: transactionID,
        currentAccountID: currentAccountID,
      ),
    );
  }
}

class _TransferFundsModalState extends State<TransferTransactionPrompt> {
  // Firebase Variables
  late Future<QuerySnapshot<Account>> _accountsFuture;

  // Form Variables
  late Account _selectedAccount;

  @override
  void initState() {
    super.initState();

    // Get the list of accounts
    _accountsFuture =
        context.read<DataProvider>().getAccountsCollection().get();

    // Default the selected account
    _selectedAccount = Account();
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
        final List<QueryDocumentSnapshot<Account>> accounts = snapshot
            .data!.docs
            .where((element) => element.id != widget.currentAccountID)
            .toList();

        // Set the default account IDs if they are not initialized
        if (_selectedAccount.id == "") {
          _selectedAccount = accounts.first.data();
        }

        // Map each account to a DropdownMenuItem
        final List<DropdownMenuItem<Account>> dropdownItems = accounts
            .map(
              (value) => DropdownMenuItem<Account>(
                value: value.data(),
                child: Text(value.data().name),
              ),
            )
            .toList();

        return Prompt(
          title: "Transfer Transaction",
          onCancel: () => Navigator.pop(context),
          onConfirm: submitForm,
          formBody: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "Select an account to transfer the transaction to",
                ),
              ),
              DropdownButtonFormField<Account>(
                decoration: const InputDecoration(
                  labelText: "Transfer to",
                ),
                items: dropdownItems,
                value: _selectedAccount,
                onChanged: (Account? newValue) => setState(
                  () => _selectedAccount = newValue ?? _selectedAccount,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> submitForm() async {
    // Get the from and to Accounts
    final DataProvider dataProvider = context.read<DataProvider>();
    final Account fromAccount =
        await dataProvider.getAccount(widget.currentAccountID);
    final Account toAccount = _selectedAccount;

    // Transfer the transaction
    await dataProvider.transferTransaction(
      fromAccount,
      toAccount,
      widget.transaction,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
