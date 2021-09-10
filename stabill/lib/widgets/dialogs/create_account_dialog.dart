import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';

class CreateAccountModal extends StatefulWidget {
  const CreateAccountModal({Key? key}) : super(key: key);

  @override
  _CreateAccountModalState createState() => _CreateAccountModalState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
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
    return AlertDialog(
      title: Text('Add Account'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
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
            ),
            TextFormField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Starting Balance",
                floatingLabelBehavior: FloatingLabelBehavior.auto,
              ),
              enableInteractiveSelection: false,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel')),
        TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                String accountName = _accountController.text;
                String balanceStr =
                    _balanceController.text.replaceAll(r"$", "");
                double currentBalance = double.parse(balanceStr);
                setState(() {
                  String uid = FirebaseAuth.instance.currentUser!.uid;

                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .collection("accounts")
                      .add({
                        "name": accountName,
                        "currentBalance": currentBalance,
                        "availableBalance": currentBalance,
                      })
                      .then((value) => Navigator.pop(context))
                      .onError((error, stackTrace) => print(error));
                });
              }
            },
            child: Text('Confirm')),
      ],
    );
  }

  @override
  void dispose() {
    _accountController.dispose();
    _balanceController.dispose();
    super.dispose();
  }
}
