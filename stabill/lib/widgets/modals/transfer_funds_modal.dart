import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart' as Stabill;

class TransferFundsModal extends StatefulWidget {
  final String? defaultAccountID;

  const TransferFundsModal({Key? key, this.defaultAccountID}) : super(key: key);

  @override
  _TransferFundsModalState createState() => _TransferFundsModalState();

  static void show(BuildContext context, {String? defaultAccountID}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (_) => TransferFundsModal(defaultAccountID: defaultAccountID),
    );
  }
}

class _TransferFundsModalState extends State<TransferFundsModal> {
  // Firebase Variables
  late CollectionReference<Account> _accountsCollection;
  late Future<QuerySnapshot<Account>> _accountsFuture;

  // Form Variables
  late GlobalKey<FormState> _formKey;
  late String _fromAccountID, _toAccountID;
  late String? _dropdownErrorText;
  late TextEditingController _balanceController;

  @override
  void initState() {
    // Initialize Firebase variables
    String uid = FirebaseAuth.instance.currentUser!.uid;
    _accountsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

    _accountsFuture = _accountsCollection.get();

    // Initialize Form variables
    _formKey = GlobalKey<FormState>();

    _fromAccountID = _toAccountID = "";
    _dropdownErrorText = null;

    _balanceController = TextEditingController(text: r"$0.00");
    _balanceController.addListener(() {
      // Format the TextField text to be a dollar string
      String formatStr = Account.formatDollarStr(_balanceController.text);

      // Replace the TextField text with the format string
      _balanceController.value = _balanceController.value.copyWith(
        text: formatStr,
        selection: TextSelection(
          baseOffset: formatStr.length,
          extentOffset: formatStr.length,
        ),
        composing: TextRange.empty,
      );
    });

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
            return SizedBox.shrink();
          }

          // If it is loading, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 164.0),
                  child: CircularProgressIndicator(),
                ),
              ],
            );
          }

          // If there is no data or there are not enough accounts, notify the user and pop the prompt
          if (!snapshot.hasData || snapshot.data!.docs.length < 2) {
            // TODO: Notify user there are not enough accounts to transfer between
            Navigator.pop(context);
            return SizedBox.shrink();
          }

          // Retrieve the accounts from the collection
          List<QueryDocumentSnapshot<Account>> accounts = snapshot.data!.docs;

          // Set the default account IDs if they are not initialized
          if (_fromAccountID == "" || _toAccountID == "") {
            if (widget.defaultAccountID != null) {
              _fromAccountID = widget.defaultAccountID!;
              _toAccountID = widget.defaultAccountID!;
            } else {
              _fromAccountID = accounts[0].id;
              _toAccountID = accounts[0].id;
            }
          }

          // Map each account to a DropdownMenuItem
          List<DropdownMenuItem<String>> dropdownItems = accounts
              .map(
                (value) => DropdownMenuItem(
                  value: value.id,
                  child: Text(value.data().name),
                ),
              )
              .toList();

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 48.0,
                right: 48.0,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Transfer Funds",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Transfer from",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: DropdownButton(
                      value: _fromAccountID,
                      items: dropdownItems,
                      menuMaxHeight: 200,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _fromAccountID = newValue ?? "";
                        });
                      },
                    ),
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      errorText: _dropdownErrorText,
                      labelText: "Transfer to",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: DropdownButton(
                      value: _toAccountID,
                      items: dropdownItems,
                      menuMaxHeight: 200,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _toAccountID = newValue ?? "";
                        });
                      },
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _balanceController,
                      decoration: InputDecoration(labelText: "Amount"),
                      enableInteractiveSelection: false,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.go,
                      validator: (value) {
                        if (value == null || value == "" || value == "\$0.00") {
                          return 'Transfer amount cannot be zero';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => initiateTransfer(accounts),
                      child: Text("Complete Transfer"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future<void> initiateTransfer(
      List<QueryDocumentSnapshot<Account>> accounts) async {
    // Validate the form
    bool validForm = _fromAccountID != _toAccountID;
    validForm &= _formKey.currentState!.validate();

    // If the form is valid, transfer the funds
    if (validForm) {
      // Get the amount to transfer
      String amountText = _balanceController.text.substring(1);
      int amount = int.parse(amountText.replaceAll(".", ""));

      // Get the accounts selected
      QueryDocumentSnapshot<Account> fromAccount =
          accounts.firstWhere((e) => e.id == _fromAccountID);
      QueryDocumentSnapshot<Account> toAccount =
          accounts.firstWhere((e) => e.id == _toAccountID);

      // Transfer the funds between the account then pop the prompt
      await transferFunds(
        fromAccount,
        toAccount,
        amount,
      );

      Navigator.pop(context);
    } else {
      // Set error text manually for the DropDown if the accounts are the same
      setState(() {
        _dropdownErrorText = _fromAccountID == _toAccountID
            ? "Transfer accounts cannot be the same"
            : null;
      });
    }
  }

  Future<void> transferFunds(QueryDocumentSnapshot<Account> fromAccount,
      QueryDocumentSnapshot<Account> toAccount, int amount) async {
    // Get the Transaction collections for both accounts

    var fromAccountTransactions = _accountsCollection
        .doc(fromAccount.id)
        .collection("transactions")
        .withConverter<Stabill.Transaction>(
          fromFirestore: (snapshot, _) =>
              Stabill.Transaction.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

    var toAccountTransactions = _accountsCollection
        .doc(toAccount.id)
        .collection("transactions")
        .withConverter<Stabill.Transaction>(
          fromFirestore: (snapshot, _) =>
              Stabill.Transaction.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

    // Create a WriteBatch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Create and write the fromTransaction
    Stabill.Transaction transaction = Stabill.Transaction(
      name: "Transfer To ${toAccount.data().name}",
      timestamp: DateTime.now(),
      amount: amount,
      cleared: true,
      memo: "SYSTEM GENERATED",
      method: Stabill.TransactionType.Withdrawal,
    );
    batch.set<Stabill.Transaction>(fromAccountTransactions.doc(), transaction);

    // Create and write the toTransaction
    transaction.name = "Transfer From ${fromAccount.data().name}";
    transaction.method = Stabill.TransactionType.Deposit;
    batch.set<Stabill.Transaction>(toAccountTransactions.doc(), transaction);

    // Commit the cahnges
    return batch.commit();
  }
}
