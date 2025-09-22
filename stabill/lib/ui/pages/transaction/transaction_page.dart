import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/core/services/transaction/transaction_service.dart';
import 'package:stabill/data/enums/transaction_category.dart';
import 'package:stabill/data/enums/transaction_type.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class TransactionPage extends StatefulWidget {
  final String accountId;
  final String? transactionId;
  const TransactionPage(
      {super.key, required this.accountId, this.transactionId});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  String _name = '';

  int _amount = 0;
  DateTime _dateTime = DateTime.now();
  TransactionType? _transactionType =
      TransactionType.deposit; // Default to deposit
  TransactionCategory? _transactionCategory = TransactionCategory.none;
  int? _checkNumber;
  String? _memo;
  bool _isCleared = false;
  // bool _isArchived = false; // Remove editable archived field

  get isNewTransaction => widget.transactionId == null;
  bool get isVoidType => _transactionType == TransactionType.voided;

  String get _formattedDateTime => DateFormat.yMd().add_jm().format(_dateTime);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(isNewTransaction ? 'Add Transaction' : 'Transaction Details'),
        leading: AdaptiveBackButton(
          fallbackRoute: Routes.account(widget.accountId),
        ),
        actions: [
          if (!isNewTransaction)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label),
                ),
                initialValue: _name,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Amount (cents)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (isVoidType) return null;
                  if (value == null || value.isEmpty) return 'Enter an amount';
                  final intValue = int.tryParse(value);
                  if (intValue == null) return 'Enter a valid number';
                  return null;
                },
                onSaved: (value) =>
                    _amount = isVoidType ? 0 : int.tryParse(value ?? '') ?? 0,
                enabled: !isVoidType,
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _pickDateTime(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Date & Time',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_month),
                      ),
                      readOnly: true,
                      controller:
                          TextEditingController(text: _formattedDateTime),
                    ),
                  ),
                ),
              ),
              SegmentedButton<TransactionType>(
                segments: TransactionType.values
                    .map((type) => ButtonSegment<TransactionType>(
                          value: type,
                          label: Text(type.label),
                          icon: Icon(type.icon),
                        ))
                    .toList(),
                selected: {_transactionType ?? TransactionType.deposit},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _transactionType = newSelection.isNotEmpty
                        ? newSelection.first
                        : TransactionType.deposit;
                    if (isVoidType) {
                      _amount = 0;
                      _amountController.text = '0';
                    } else {
                      _amountController.text = _amount.toString();
                    }
                  });
                },
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity(horizontal: 0, vertical: 0),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<TransactionCategory>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(_transactionCategory?.icon ?? Icons.category),
                ),
                initialValue: _transactionCategory,
                items: TransactionCategory.values
                    .map((cat) => DropdownMenuItem<TransactionCategory>(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(cat.icon, size: 20),
                              SizedBox(width: 8),
                              Text(cat.label),
                            ],
                          ),
                        ))
                    .toList(),
                selectedItemBuilder: (context) => TransactionCategory.values
                    .map((cat) => Text(cat.label))
                    .toList(),
                onChanged: (cat) => setState(() => _transactionCategory = cat),
                validator: (value) =>
                    value == null ? 'Select a category' : null,
                onSaved: (value) => _transactionCategory = value,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Check Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                initialValue: _checkNumber?.toString() ?? '',
                keyboardType: TextInputType.number,
                onSaved: (value) => _checkNumber =
                    value != null && value.isNotEmpty
                        ? int.tryParse(value)
                        : null,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Memo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.sticky_note_2),
                ),
                initialValue: _memo ?? '',
                onSaved: (value) => _memo = value,
                minLines: 1,
                maxLines: 5,
              ),
              SwitchListTile(
                title: const Text('Cleared'),
                secondary: const Icon(Icons.check_circle),
                value: _isCleared,
                onChanged: (val) => setState(() => _isCleared = val),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTransaction,
                child: Text(isNewTransaction
                    ? 'Add Transaction'
                    : 'Update Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = _amount.toString();
  }

  Future<void> _deleteTransaction() async {
    var result = await context
        .read<TransactionService>()
        .deleteTransaction(widget.transactionId ?? '');

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaction deleted')),
      );
      context
          .read<NavigationService>()
          .navigateBack(fallbackRoute: Routes.account(widget.accountId));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete transaction: ${result.error}')),
      );
    }
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateTime),
      );
      if (time != null) {
        setState(() {
          _dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else {
        setState(() {
          _dateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _dateTime.hour,
            _dateTime.minute,
          );
        });
      }
    }
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (isVoidType) _amount = 0;
      final transaction = Transaction(
        id: isNewTransaction ? null : widget.transactionId,
        name: _name,
        createdAt:
            _dateTime, // TODO: use existing transaction createdAt if editing
        amount: _amount,
        transactionDate: _dateTime,
        transactionType: _transactionType!,
        category: _transactionCategory!,
        checkNumber: _checkNumber,
        memo: _memo,
        isCleared: _isCleared,
        isArchived: false,
      );
      final transactionService = context.read<TransactionService>();
      final result = isNewTransaction
          ? await transactionService.createTransaction(
              transaction, widget.accountId)
          : await transactionService.updateTransaction(transaction);

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(isNewTransaction
                    ? 'Transaction saved!'
                    : 'Transaction updated!')),
          );
          context
              .read<NavigationService>()
              .navigateBack(fallbackRoute: Routes.account(widget.accountId));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to save transaction: ${result.error}')),
          );
        }
      }
    } else if (_transactionType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a transaction type')),
      );
    } else if (_transactionCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a category')),
      );
    }
  }
}
