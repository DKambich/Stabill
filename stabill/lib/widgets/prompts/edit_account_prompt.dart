import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';

class EditAccountPrompt extends StatefulWidget {
  final String accountID;

  const EditAccountPrompt({Key? key, required this.accountID})
      : super(key: key);

  @override
  _EditAccountPromptState createState() => _EditAccountPromptState();

  static void show(BuildContext context, String accountID) {
    showDialog(
      context: context,
      builder: (_) => EditAccountPrompt(accountID: accountID),
    );
  }
}

class _EditAccountPromptState extends State<EditAccountPrompt> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _accountController;

  @override
  void initState() {
    super.initState();

    // Initialize Form variables
    _formKey = GlobalKey<FormState>();
    _accountController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: dialogShape,
      title: const Text("Edit Account"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: submitForm,
          child: const Text("Confirm"),
        ),
      ],
      content: Form(
        key: _formKey,
        child: TextFormField(
          autofocus: true,
          controller: _accountController,
          decoration: const InputDecoration(
            labelText: "Account Name",
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          onFieldSubmitted: (_) => submitForm(),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Account name is too short';
            }
            return null;
          },
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final DataProvider dataProvider = context.read<DataProvider>();

      // Get the associated Account
      final Account account = await dataProvider.getAccount(widget.accountID);
      // Set the new name
      account.name = _accountController.text;

      // Update the Account
      await dataProvider.updateAccount(account);

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _accountController.dispose();
    super.dispose();
  }
}
