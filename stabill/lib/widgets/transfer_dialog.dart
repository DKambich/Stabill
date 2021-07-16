import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'dart:async';

class TransferDialog extends StatefulWidget {
  const TransferDialog({Key? key}) : super(key: key);

  @override
  _TransferDialogState createState() => _TransferDialogState();
}

class _TransferDialogState extends State<TransferDialog> {
  late Future<QuerySnapshot<Account>> _accountsFuture;
  late CollectionReference<Account> _accountsCollection;
  String fromAccount = "", toAccount = "";
  String errorText = "";

  void transferFunds(String fromID, String toID, double amount) async {
    var fromAccountRef = _accountsCollection.doc(fromID);
    var fromAccount = (await fromAccountRef.get()).data();

    var toAccountRef = _accountsCollection.doc(toID);
    var toAccount = (await toAccountRef.get()).data();

    if (fromAccount != null && toAccount != null) {
      fromAccount.availableBalance -= amount;
      fromAccount.currentBalance -= amount;

      toAccount.availableBalance += amount;
      toAccount.currentBalance += amount;

      fromAccountRef.set(fromAccount);
      toAccountRef.set(toAccount);
    }

    // TODO: Create transactions for the transfer
  }

  @override
  void initState() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Get a stream for the accounts list to listen to
    _accountsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

    _accountsFuture = _accountsCollection.get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

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

          if (!snapshot.hasData) {
            Navigator.pop(context);
            // TODO: Show message that no accounts exist
          }

          List<QueryDocumentSnapshot<Account>> accounts = snapshot.data!.docs;
          if (fromAccount == "" || toAccount == "") {
            fromAccount = accounts[0].id;
            toAccount = accounts[0].id;
          }

          List<DropdownMenuItem<String>> dropdownItems = accounts.map(
            (value) {
              return DropdownMenuItem(
                value: value.id,
                child: Text(value.data().name),
              );
            },
          ).toList();

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
                    style: TextStyle(
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Transfer from",
                      border: InputBorder.none,
                    ),
                    child: DropdownButton(
                      value: fromAccount,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          fromAccount = newValue ?? "";
                          print(fromAccount);
                        });
                      },
                      items: dropdownItems,
                    ),
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Transfer to",
                      border: InputBorder.none,
                    ),
                    child: DropdownButton<String>(
                      value: toAccount,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          toAccount = newValue ?? "";
                        });
                      },
                      items: dropdownItems,
                    ),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Amount",
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: (errorText != "")
                        ? Text(
                            errorText,
                            style: TextStyle(color: Colors.red),
                          )
                        : null,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (fromAccount != toAccount) {
                        transferFunds(fromAccount, toAccount, 100);
                        Navigator.pop(context);
                        setState(() {
                          errorText = "";
                        });
                      } else {
                        setState(() {
                          errorText = "Accounts must be different";
                        });
                      }
                    },
                    child: Text("Complete Transfer"),
                  )
                ],
              ),
            ),
          );
        });
  }
}
