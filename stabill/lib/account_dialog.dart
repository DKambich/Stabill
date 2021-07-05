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

  @override
  void initState() {
    super.initState();
    _balanceController.addListener(() {
      final String text =
          "\$" + _balanceController.text.replaceAll(RegExp(r"[^\d]"), "");
      _balanceController.value = _balanceController.value.copyWith(
        text: text,
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
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
                  Navigator.pop(context);
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
