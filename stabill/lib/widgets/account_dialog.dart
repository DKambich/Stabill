import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';

class NewAccountDialog extends StatefulWidget {
  final Function(Account) onCreateAccount;

  const NewAccountDialog({Key? key, required this.onCreateAccount})
      : super(key: key);

  @override
  _NewAccountDialogState createState() => _NewAccountDialogState();
}

// TODO: https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
class _NewAccountDialogState extends State<NewAccountDialog> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String formatDollarStr(String input) {
    // Remove all non-numeric characters
    String text = input.replaceAll(RegExp(r"[^\d]"), "");

    // Pad front of text with 0 until it is 3 characters
    if (text.length < 3) {
      text = text.padLeft(3, "0");
    }

    // Remove a zero from the front of the text if the length is 4
    if (text.startsWith("0") && text.length == 4) {
      text = text.substring(1);
    }

    // Insert the dollar sign
    text = "\$" + text;

    // Insert the decimal point
    text = text.substring(0, text.length - 2) +
        "." +
        text.substring(text.length - 2);

    return text;
  }

  @override
  void initState() {
    super.initState();
    _balanceController.addListener(() {
      String dollarStr = formatDollarStr(_balanceController.text);

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
                  widget.onCreateAccount(new Account(
                    name: accountName,
                    currentBalance: currentBalance,
                    availableBalance: currentBalance,
                  ));
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
