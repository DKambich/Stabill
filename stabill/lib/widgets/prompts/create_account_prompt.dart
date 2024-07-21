import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/dollar_formatter.dart';

class CreateAccountPrompt extends StatefulWidget {
  const CreateAccountPrompt({Key? key}) : super(key: key);
  @override
  _CreateAccountPromptState createState() => _CreateAccountPromptState();

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const CreateAccountPrompt(),
    );
  }
}

class _CreateAccountPromptState extends State<CreateAccountPrompt> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _accountController;
  late TextEditingController _balanceController;

  @override
  void initState() {
    super.initState();

    // Initialize Form variables
    _formKey = GlobalKey<FormState>();
    _accountController = TextEditingController();
    _balanceController = TextEditingController(text: "\$0.00");
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Account"),
      shape: dialogShape,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              autofocus: true,
              controller: _accountController,
              decoration: textInputDecoration(
                labelText: "Account Name",
                prefixIcon: Icons.account_balance_rounded,
              ),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: (name) => (name == null || name.isEmpty)
                  ? 'Account name is too short'
                  : null,
            ),
            dialogFieldSpace,
            TextFormField(
              controller: _balanceController,
              decoration: textInputDecoration(
                labelText: "Starting Balance",
                prefixIcon: Icons.attach_money_rounded,
              ),
              enableInteractiveSelection: false,
              inputFormatters: [DollarTextInputFormatter(maxDigits: 8)],
              keyboardType: TextInputType.number,
              onFieldSubmitted: (_) => submitForm(),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Setup the new account
      final Account account = Account(
        name: _accountController.text,
      );

      // Get the starting balance
      final int startingBalance = int.parse(
        _balanceController.text.replaceAll(RegExp(r"[^\d]"), ""),
      );

      // Create the new Account
      await context.read<DataProvider>().createAccount(
            account,
            startingBalance,
          );

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _accountController.dispose();
    _balanceController.dispose();
  }
}
