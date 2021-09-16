import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart' as Stabill;

class CreateAccountModal extends StatefulWidget {
  const CreateAccountModal({Key? key}) : super(key: key);

  @override
  _CreateAccountModalState createState() => _CreateAccountModalState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      builder: (_) => CreateAccountModal(),
    );
  }
}

class _CreateAccountModalState extends State<CreateAccountModal> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _balanceController =
      TextEditingController(text: r"$0.00");
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: 48.0,
          right: 48.0,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Create Account",
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  autofocus: true,
                  controller: _accountController,
                  decoration: InputDecoration(
                    labelText: "Account Name",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Account name too short';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _balanceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Starting Balance",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  enableInteractiveSelection: false,
                  textInputAction: TextInputAction.done,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel'),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Setup the new account
                              String accountName = _accountController.text;
                              String balanceStr = _balanceController.text
                                  .replaceAll(r"$", "")
                                  .replaceAll(".", "");
                              int accountBalance = int.parse(balanceStr);
                              print(accountBalance);
                              Account newAccount = Account(name: accountName);

                              // Create the new Account
                              await createAccount(newAccount, accountBalance);
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Confirm')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createAccount(Account newAccount, int balance) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    CollectionReference<Account> _accountsCollection = FirebaseFirestore
        .instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(snapshot.data()!),
          toFirestore: (account, _) => account.toJson(),
        );
    try {
      var doc = await _accountsCollection.add(newAccount);
      if (balance == 0) return;
      Stabill.Transaction transaction = Stabill.Transaction(
        name: "Starting Balance",
        amount: balance,
        timestamp: DateTime.now(),
        cleared: true,
        memo: "System Generated",
        method: Stabill.TransactionType.Deposit,
      );

      print(balance);

      doc
          .collection("transactions")
          .withConverter<Stabill.Transaction>(
            fromFirestore: (snapshot, _) =>
                Stabill.Transaction.fromJson(snapshot.data()!),
            toFirestore: (transaction, _) => transaction.toJson(),
          )
          .add(transaction);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
