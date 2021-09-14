import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart' as Stabill;

class TransferTransactionModal extends StatefulWidget {
  final String currentAccountID, transactionID;
  final Stabill.Transaction transaction;

  const TransferTransactionModal(
      {Key? key,
      required this.currentAccountID,
      required this.transaction,
      required this.transactionID})
      : super(key: key);

  @override
  _TransferFundsModalState createState() => _TransferFundsModalState();

  static void show(
    BuildContext context,
    Stabill.Transaction transaction,
    String transactionID,
    String currentAccountID,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (_) => TransferTransactionModal(
        transaction: transaction,
        transactionID: transactionID,
        currentAccountID: currentAccountID,
      ),
    );
  }
}

class _TransferFundsModalState extends State<TransferTransactionModal> {
  // Firebase Variables
  late CollectionReference<Account> _accountsCollection;
  late Future<QuerySnapshot<Account>> _accountsFuture;

  // Form Variables
  late GlobalKey<FormState> _formKey;
  late String _selectedAccountID;

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

    _selectedAccountID = "";

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
          List<QueryDocumentSnapshot<Account>> accounts = snapshot.data!.docs
              .where((element) => element.id != widget.currentAccountID)
              .toList();

          // Set the default account IDs if they are not initialized
          if (_selectedAccountID == "") {
            _selectedAccountID = accounts.first.id;
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
                    "Transfer Transaction",
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Select an account to transfer the transaction to",
                    ),
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Transfer to",
                      border: InputBorder.none,
                    ),
                    child: DropdownButton(
                      value: _selectedAccountID,
                      items: dropdownItems,
                      menuMaxHeight: 200,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedAccountID = newValue ?? "";
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            child: Text("Cancel"),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            child: Text("Confirm"),
                            onPressed: () async {
                              await transferTransaction(
                                _selectedAccountID,
                                widget.transaction,
                              );
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> transferTransaction(
      String toAccountID, Stabill.Transaction transaction) async {
    // Get the Transaction collections for both accounts

    var fromAccountTransactionRef = _accountsCollection
        .doc(widget.currentAccountID)
        .collection("transactions")
        .doc(widget.transactionID);

    var toAccountTransactions = _accountsCollection
        .doc(toAccountID)
        .collection("transactions")
        .withConverter<Stabill.Transaction>(
          fromFirestore: (snapshot, _) =>
              Stabill.Transaction.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

    // Create a WriteBatch
    WriteBatch batch = FirebaseFirestore.instance.batch();

    batch.set<Stabill.Transaction>(toAccountTransactions.doc(), transaction);

    // Create and write the toTransaction
    batch.delete(fromAccountTransactionRef);

    // Commit the cahnges
    return batch.commit();
  }
}
