import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/dollar_formatter.dart';
import 'package:stabill/widgets/prompts/prompt.dart';

class BalanceCorrectionPrompt extends StatefulWidget {
  final String accountID;

  const BalanceCorrectionPrompt({
    Key? key,
    required this.accountID,
  }) : super(key: key);

  @override
  _BalanceCorrectionPromptState createState() =>
      _BalanceCorrectionPromptState();

  static void show(BuildContext context, String accountID) {
    Prompt.show(context, BalanceCorrectionPrompt(accountID: accountID));
  }
}

class _BalanceCorrectionPromptState extends State<BalanceCorrectionPrompt> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _balanceController;

  String? errorText;

  @override
  void initState() {
    super.initState();

    // Initialize Form variables
    _formKey = GlobalKey<FormState>();
    _balanceController = TextEditingController(text: r"$0.00");
  }

  @override
  Widget build(BuildContext context) {
    return Prompt(
      title: "Balance Correction",
      onCancel: () => Navigator.pop(context),
      onConfirm: submitForm,
      formBody: Form(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Enter the new balance for this account. This will mark all transactions as cleared and set the account balance to the sepecified value",
              ),
            ),
            Form(
              key: _formKey,
              child: TextFormField(
                autofocus: true,
                controller: _balanceController,
                decoration: const InputDecoration(
                  labelText: "New Balance",
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                enableInteractiveSelection: false,
                inputFormatters: [
                  DollarTextInputFormatter(allowNegative: true, maxDigits: 8)
                ],
                keyboardType: TextInputType.number,
                onFieldSubmitted: (_) => submitForm(),
                textInputAction: TextInputAction.done,
                validator: (_) {
                  return errorText;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submitForm() async {
    // Get the updated balance
    final int newBalance = int.parse(
      _balanceController.text.replaceAll(RegExp(r"[^\d]"), ""),
    );

    // Get the old balance
    final DataProvider dataProvider = context.read<DataProvider>();
    final Account account = await dataProvider.getAccount(widget.accountID);
    final int oldBalance = account.currentBalance;

    // If the balances are different, update the balance
    if (newBalance != oldBalance) {
      await dataProvider.updateBalance(account, newBalance);
      if (!mounted) return;
      Navigator.pop(context);
    } else {
      errorText = "New balance cannot equal old balance";
      _formKey.currentState!.validate();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _balanceController.dispose();
  }
}
