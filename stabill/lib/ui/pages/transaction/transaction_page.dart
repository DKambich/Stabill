import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/data/models/transaction_type.dart';
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
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
              GestureDetector(
                onTap: () => _pickDateTime(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date & Time',
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    readOnly: true,
                    controller: TextEditingController(text: _formattedDateTime),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Transaction Type',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              SegmentedButton<TransactionType>(
                segments: TransactionType.values
                    .map((type) => ButtonSegment<TransactionType>(
                          value: type,
                          label: Text(type.toString().split('.').last),
                          icon: Icon(Icons.add),
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _transactionType == null
                    ? Text(
                        'Select a transaction type',
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      )
                    : SizedBox.shrink(),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Check Number',
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
                  prefixIcon: Icon(Icons.sticky_note_2),
                ),
                initialValue: _memo ?? '',
                onSaved: (value) => _memo = value,
                minLines: 2,
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
                onPressed: () {
                  if (_formKey.currentState?.validate() ??
                      false && _transactionType != null) {
                    _formKey.currentState?.save();
                    if (isVoidType) _amount = 0;
                    // TODO: Save transaction using your service/provider
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Transaction saved!')),
                    );
                  } else if (_transactionType == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Please select a transaction type')),
                    );
                  }
                },
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
}
