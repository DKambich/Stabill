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

  @override
  void initState() {
    super.initState();
    _balanceController.addListener(() {
      final String text =
          "\$" + _balanceController.text.replaceAll(RegExp(r"[^\d]"), "");
      print(text);
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _accountController,
            decoration: InputDecoration(hintText: "Account Name"),
          ),
          TextFormField(
            controller: _balanceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Starting Balance"),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(onPressed: () {}, child: Text('Cancel')),
        TextButton(
            onPressed: () {
              print(_accountController.text);
              print(_balanceController.text.replaceAll("\$", ""));
              setState(() {
                widget.onCreateAccount(new Account());
                Navigator.pop(context);
              });
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
