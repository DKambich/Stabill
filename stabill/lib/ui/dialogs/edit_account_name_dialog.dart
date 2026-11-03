import 'package:flutter/material.dart';

Future<String?> showEditAccountNameDialog(
  BuildContext context, {
  required String accountName,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _EditAccountNameDialog(accountName: accountName),
  );
}

class _EditAccountNameDialog extends StatefulWidget {
  final String accountName;

  const _EditAccountNameDialog({required this.accountName});

  @override
  State<_EditAccountNameDialog> createState() => _EditAccountNameDialogState();
}

class _EditAccountNameDialogState extends State<_EditAccountNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.accountName);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit account name'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Form(
          key: _formKey,
          child: TextFormField(
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
            onFieldSubmitted: (_) => _submit(),
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
          child: const Text('Save'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(_nameController.text.trim());
  }
}
