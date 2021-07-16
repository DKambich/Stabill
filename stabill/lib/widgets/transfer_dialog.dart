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
  final TextEditingController _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String fromAccount = "", toAccount = "";
  String? errorText = "";

  Future<void> transferFunds(String fromID, String toID, double amount) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();

    return _accountsCollection.get().then((querySnapshot) {
      querySnapshot.docs.forEach((document) {
        if (document.id == fromID) {
          double availableBalance = document.data().availableBalance - amount;
          double currentBalance = document.data().currentBalance - amount;
          batch.update(document.reference, {
            "availableBalance": availableBalance,
            "currentBalance": currentBalance
          });
        } else if (document.id == toID) {
          double availableBalance = document.data().availableBalance + amount;
          double currentBalance = document.data().currentBalance + amount;
          batch.update(document.reference, {
            "availableBalance": availableBalance,
            "currentBalance": currentBalance
          });
        }
      });

      return batch.commit();
    });

    // var fromAccountRef = _accountsCollection.doc(fromID);
    // var fromAccount = (await fromAccountRef.get()).data();

    // var toAccountRef = _accountsCollection.doc(toID);
    // var toAccount = (await toAccountRef.get()).data();

    // if (fromAccount != null && toAccount != null) {
    //   fromAccount.availableBalance -= amount;
    //   fromAccount.currentBalance -= amount;

    //   toAccount.availableBalance += amount;
    //   toAccount.currentBalance += amount;

    //   fromAccountRef.set(fromAccount);
    //   toAccountRef.set(toAccount);
    // }

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

    _balanceController.addListener(() {
      String dollarStr = Account.formatDollarStr(_balanceController.text);

      _balanceController.value = _balanceController.value.copyWith(
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
    return FutureBuilder<QuerySnapshot<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            // TODO: Notify user there was an error
            Navigator.pop(context);
          } else if (snapshot.connectionState == ConnectionState.waiting) {
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
            // TODO: Notify user there are no accounts
            Navigator.pop(context);
          }

          // Retrieve the accounts from the collection
          List<QueryDocumentSnapshot<Account>> accounts = snapshot.data!.docs;
          if (fromAccount == "" || toAccount == "") {
            fromAccount = accounts[0].id;
            toAccount = accounts[0].id;
          }

          // Create menu items from the accounts
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
                      contentPadding: EdgeInsets.zero,
                    ),
                    child: DropdownButton(
                      value: fromAccount,
                      items: dropdownItems,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          fromAccount = newValue ?? "";
                        });
                      },
                    ),
                  ),
                  InputDecorator(
                    decoration: InputDecoration(
                      errorText: errorText != "" ? errorText : null,
                      labelText: "Transfer to",
                      border: InputBorder.none,
                    ),
                    child: DropdownButton<String>(
                      value: toAccount,
                      items: dropdownItems,
                      menuMaxHeight: 200,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          toAccount = newValue ?? "";
                        });
                      },
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: "Amount",
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      controller: _balanceController,
                      keyboardType: TextInputType.number,
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
                      onPressed: () async {
                        if (fromAccount != toAccount &&
                            _formKey.currentState!.validate()) {
                          double transferAmount = double.parse(
                              _balanceController.text.substring(1));
                          await transferFunds(
                              fromAccount, toAccount, transferAmount);
                          Navigator.pop(context);
                          setState(() {
                            errorText = null;
                          });
                        } else {
                          _formKey.currentState!.validate();
                          setState(() {
                            errorText = "Transfer accounts cannot be the same";
                          });
                        }
                      },
                      child: Text("Complete Transfer"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
