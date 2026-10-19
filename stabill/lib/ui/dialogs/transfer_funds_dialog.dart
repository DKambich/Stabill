import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/transaction/transaction_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/utils/currency_format.dart';
import 'package:stabill/utils/currency_input_formatter.dart';

Future<void> showTransferFundsDialog(
  BuildContext context, {
  String? initialFromAccountId,
}) async {
  final accountsFuture = context.read<AccountService>().getAccounts();
  final transfer = await showDialog<
      ({
        String fromAccountId,
        String toAccountId,
        int amountInCents,
      })>(
    context: context,
    builder: (_) => _TransferFundsDialog(
      accountsFuture: accountsFuture,
      initialFromAccountId: initialFromAccountId,
    ),
  );
  if (transfer == null || !context.mounted) return;

  final result = await context.read<TransactionService>().transferFunds(
        fromAccountId: transfer.fromAccountId,
        toAccountId: transfer.toAccountId,
        amountInCents: transfer.amountInCents,
      );
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        result.isSuccess
            ? 'Transfer completed'
            : 'Failed to transfer funds: ${result.error}',
      ),
    ),
  );
}

class _TransferFundsDialog extends StatefulWidget {
  final Future<Result<List<Account>>> accountsFuture;
  final String? initialFromAccountId;

  const _TransferFundsDialog({
    required this.accountsFuture,
    required this.initialFromAccountId,
  });

  @override
  State<_TransferFundsDialog> createState() => _TransferFundsDialogState();
}

class _TransferFundsDialogState extends State<_TransferFundsDialog> {
  final _formKey = GlobalKey<FormState>();

  late String? _fromAccountId = widget.initialFromAccountId;
  String? _toAccountId;
  int? _amountInCents;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<List<Account>>>(
      future: widget.accountsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return AlertDialog(
            title: const Text('Transfer funds'),
            content: Text('Unable to load accounts: ${snapshot.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }
        if (!snapshot.hasData) {
          return const AlertDialog(
            title: Text('Transfer funds'),
            content: SizedBox(
              width: 40,
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final accountResult = snapshot.data!;
        if (accountResult.isFailure) {
          return AlertDialog(
            title: const Text('Transfer funds'),
            content: Text('Unable to load accounts: ${accountResult.error}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final accounts = accountResult.data!
            .where((account) =>
                account.id != null &&
                (!account.isArchived ||
                    account.id == widget.initialFromAccountId))
            .toList();
        if (accounts.length < 2) {
          return AlertDialog(
            title: const Text('Transfer funds'),
            content: const Text('Two active accounts are required.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final accountIds = accounts.map((account) => account.id!).toSet();
        if (!accountIds.contains(_fromAccountId)) _fromAccountId = null;
        if (!accountIds.contains(_toAccountId) ||
            _toAccountId == _fromAccountId) {
          _toAccountId = null;
        }

        String accountLabel(Account account) {
          final hasDuplicateName =
              accounts.where((item) => item.name == account.name).length > 1;
          if (!hasDuplicateName) return account.name;
          final id = account.id!;
          final suffix = id.length > 8 ? id.substring(id.length - 8) : id;
          return '${account.name} ($suffix)';
        }

        return AlertDialog(
          title: const Text('Transfer funds'),
          scrollable: true,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _fromAccountId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'From account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts
                        .map(
                          (account) => DropdownMenuItem(
                            value: account.id!,
                            child: Text(
                              accountLabel(account),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) =>
                        value == null ? 'Choose a source account' : null,
                    onChanged: (value) => setState(() {
                      _fromAccountId = value;
                      if (_toAccountId == value) _toAccountId = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey(_fromAccountId),
                    initialValue: _toAccountId,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'To account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts
                        .where((account) => account.id != _fromAccountId)
                        .map(
                          (account) => DropdownMenuItem(
                            value: account.id!,
                            child: Text(
                              accountLabel(account),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    validator: (value) => value == null
                        ? 'Choose a destination account'
                        : value == _fromAccountId
                            ? 'Choose a different account'
                            : null,
                    onChanged: (value) => setState(() => _toAccountId = value),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: const [CurrencyInputFormatter()],
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      final amount = CurrencyFormat.parseCents(value);
                      if (amount == null || amount <= 0) {
                        return 'Enter an amount greater than zero';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        _amountInCents = CurrencyFormat.parseCents(value),
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
              child: const Text('Transfer'),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    final form = _formKey.currentState;
    if (form?.validate() != true) return;
    form!.save();

    final fromAccountId = _fromAccountId;
    final toAccountId = _toAccountId;
    final amountInCents = _amountInCents;
    if (fromAccountId == null || toAccountId == null || amountInCents == null) {
      return;
    }

    Navigator.of(context).pop((
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      amountInCents: amountInCents,
    ));
  }
}
