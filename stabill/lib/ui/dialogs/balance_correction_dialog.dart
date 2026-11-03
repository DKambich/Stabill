import 'package:flutter/material.dart';
import 'package:stabill/utils/currency_format.dart';
import 'package:stabill/utils/currency_input_formatter.dart';

Future<int?> showBalanceCorrectionDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (_) => const _BalanceCorrectionDialog(),
  );
}

class _BalanceCorrectionDialog extends StatefulWidget {
  const _BalanceCorrectionDialog();

  @override
  State<_BalanceCorrectionDialog> createState() =>
      _BalanceCorrectionDialogState();
}

class _BalanceCorrectionDialogState extends State<_BalanceCorrectionDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _targetBalanceInCents;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Correct account balance'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the correct current balance. A deposit or withdrawal '
                'will be recorded for the difference.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                autofocus: true,
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
                  labelText: 'New current balance',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) =>
                    CurrencyFormat.parseSignedCents(value) == null
                        ? 'Enter a valid balance'
                        : null,
                onSaved: (value) => _targetBalanceInCents =
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
          child: const Text('Correct balance'),
        ),
      ],
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    form!.save();

    final targetBalance = _targetBalanceInCents;
    if (targetBalance != null) Navigator.of(context).pop(targetBalance);
  }
}
