import 'package:flutter/material.dart';
import 'package:stabill/utils/currency_format.dart';
import 'package:stabill/utils/currency_input_formatter.dart';

Future<({String name, int startingBalanceInCents})?> showCreateAccountDialog(
    BuildContext context) {
  return showDialog<({String name, int startingBalanceInCents})>(
    context: context,
    builder: (_) => const _CreateAccountDialog(),
  );
}

class _CreateAccountDialog extends StatefulWidget {
  const _CreateAccountDialog();

  @override
  State<_CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<_CreateAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController(text: '0.00');

  int? _startingBalanceInCents;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create account'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Account name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter an account name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: true,
                ),
                inputFormatters: const [
                  CurrencyInputFormatter(
                    includeCurrencySymbol: false,
                    allowNegative: true,
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'Initial balance',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) =>
                    CurrencyFormat.parseSignedCents(value) == null
                        ? 'Enter a valid balance'
                        : null,
                onSaved: (value) => _startingBalanceInCents =
                    CurrencyFormat.parseSignedCents(value),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    form!.save();

    final startingBalance = _startingBalanceInCents;
    if (startingBalance != null) {
      Navigator.of(context).pop((
        name: _nameController.text.trim(),
        startingBalanceInCents: startingBalance,
      ));
    }
  }
}
