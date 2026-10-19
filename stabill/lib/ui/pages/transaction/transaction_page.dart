import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/core/services/transaction/transaction_service.dart';
import 'package:stabill/data/enums/transaction_category.dart';
import 'package:stabill/data/enums/transaction_type.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/utils/currency_format.dart';
import 'package:stabill/utils/currency_input_formatter.dart';

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
  final TextEditingController _nameController = TextEditingController();
  Transaction? _originalTransaction;
  String _name = '';

  int _amount = 0;
  DateTime _dateTime = DateTime.now();
  TransactionType? _transactionType =
      TransactionType.deposit; // Default to deposit
  TransactionCategory? _transactionCategory = TransactionCategory.none;
  int? _checkNumber;
  String? _memo;
  bool _isCleared = false;
  bool _isArchived = false;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _loadFailed = false;
  bool _hasUnsavedChanges = false;
  bool _discardApproved = false;
  bool _isConfirmingDiscard = false;
  bool get isEditable => isNewTransaction || _isEditing;

  bool get isNewTransaction => widget.transactionId == null;
  bool get isVoidType => _transactionType == TransactionType.voided;

  String get _formattedDateTime => DateFormat.yMd().add_jm().format(_dateTime);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.38);

    // Keep the route mounted until the user confirms discarding edits.
    return PopScope(
      canPop: !_hasUnsavedChanges || _discardApproved,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasUnsavedChanges) {
          _confirmDiscardAndNavigate();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNewTransaction
                ? 'Add Transaction'
                : _isEditing
                    ? 'Edit Transaction'
                    : 'Transaction Details',
          ),
          leading: BackButton(onPressed: _handleBack),
          actions: [
            if (_isArchived)
              IconButton(
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'Unhide transaction',
                onPressed: _unhideTransaction,
              ),
            if (!isNewTransaction && !_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit transaction',
                onPressed: () => setState(() {
                  _isEditing = true;
                  _hasUnsavedChanges = false;
                }),
              ),
            if (!isNewTransaction && _isEditing)
              IconButton(
                icon: const Icon(Icons.edit_off),
                tooltip: 'Stop editing and discard changes',
                onPressed: _requestCancelEditing,
              ),
          ],
        ),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _loadFailed
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Unable to load transaction.'),
                          TextButton.icon(
                            onPressed: _loadTransaction,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try again'),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 640),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Form(
                            key: _formKey,
                            onChanged: _markUnsavedChanges,
                            child: ListView(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Name',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.label),
                                  ),
                                  controller: _nameController,
                                  autofocus: isNewTransaction,
                                  enabled: isEditable,
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter a name'
                                          : null,
                                  onSaved: (value) => _name = value ?? '',
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Amount',
                                    border: OutlineInputBorder(),
                                  ),
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: const [
                                    CurrencyInputFormatter()
                                  ],
                                  enabled: isEditable && !isVoidType,
                                  validator: (value) {
                                    if (isVoidType) return null;
                                    if (value == null || value.isEmpty) {
                                      return 'Enter an amount';
                                    }
                                    if (CurrencyFormat.parseCents(value) ==
                                        null) {
                                      return 'Enter a valid amount';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => _amount = isVoidType
                                      ? 0
                                      : CurrencyFormat.parseCents(value) ?? 0,
                                ),
                                const SizedBox(height: 16),
                                InkWell(
                                  mouseCursor: isEditable
                                      ? SystemMouseCursors.click
                                      : SystemMouseCursors.basic,
                                  borderRadius: BorderRadius.circular(4),
                                  onTap: isEditable
                                      ? () => _pickDateTime(context)
                                      : null,
                                  child: InputDecorator(
                                    decoration: InputDecoration(
                                      enabled: isEditable,
                                      labelText: 'Date & Time',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.calendar_month),
                                    ),
                                    child: Text(
                                      _formattedDateTime,
                                      style:
                                          theme.textTheme.bodyLarge?.copyWith(
                                        color: isEditable
                                            ? theme.colorScheme.onSurface
                                            : disabledColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: ValueKey('check-number-$_isEditing'),
                                  decoration: const InputDecoration(
                                    labelText: 'Check Number',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.numbers),
                                  ),
                                  initialValue: _checkNumber?.toString() ?? '',
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  enabled: isEditable,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }
                                    if (int.tryParse(value) == null) {
                                      return 'Enter a valid check number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) => _checkNumber =
                                      value != null && value.isNotEmpty
                                          ? int.tryParse(value)
                                          : null,
                                ),
                                const SizedBox(height: 16),
                                InputDecorator(
                                  decoration: InputDecoration(
                                    enabled: isEditable,
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  child: CheckboxListTile(
                                    contentPadding: EdgeInsets.zero,
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                    title: const Text('Cleared'),
                                    value: _isCleared,
                                    onChanged: isEditable
                                        ? (val) => _updateDraft(
                                              () => _isCleared = val ?? false,
                                            )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTransactionTypeField(
                                    theme, disabledColor),
                                const SizedBox(height: 16),
                                _buildCategoryField(),
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: ValueKey('memo-$_isEditing'),
                                  decoration: const InputDecoration(
                                    labelText: 'Memo',
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.sticky_note_2),
                                  ),
                                  initialValue: _memo ?? '',
                                  enabled: isEditable,
                                  onSaved: (value) => _memo = value,
                                  minLines: 1,
                                  maxLines: 5,
                                ),
                                if (isEditable) ...[
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _submitTransaction,
                                      child: Text(isNewTransaction
                                          ? 'Add Transaction'
                                          : 'Update Transaction'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!isNewTransaction) {
      _isLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransaction();
      });
    } else {
      _amountController.text = CurrencyFormat.formatCents(_amount);
      _nameController.text = _name;
    }
  }

  void _applyTransaction(Transaction transaction) {
    _name = transaction.name;
    _nameController.text = transaction.name;
    _amount = transaction.amount;
    _amountController.text = CurrencyFormat.formatCents(transaction.amount);
    _dateTime = transaction.transactionDate;
    _transactionType = transaction.transactionType;
    _transactionCategory = transaction.category;
    _checkNumber = transaction.checkNumber;
    _memo = transaction.memo;
    _isCleared = transaction.isCleared;
    _isArchived = transaction.isArchived;
  }

  Widget _buildCategoryField() {
    return Row(
      children: [
        Expanded(
          child: FormField<TransactionCategory>(
            key: ValueKey('category-$_isEditing-$_transactionCategory'),
            initialValue: _transactionCategory,
            validator: (value) => value == null ? 'Select a category' : null,
            onSaved: (value) => _transactionCategory = value,
            // DropdownMenu isn't a FormField, so this wrapper keeps it in the form.
            builder: (field) => DropdownMenu<TransactionCategory>(
              enabled: isEditable,
              label: const Text('Category'),
              leadingIcon: Icon(field.value?.icon ?? Icons.category),
              expandedInsets: EdgeInsets.zero,
              menuHeight: 240,
              initialSelection: field.value,
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              dropdownMenuEntries: TransactionCategory.values
                  .map((category) => DropdownMenuEntry<TransactionCategory>(
                        value: category,
                        label: category.label,
                        leadingIcon: Icon(category.icon),
                      ))
                  .toList(),
              onSelected: isEditable
                  ? (category) {
                      if (category == null) return;
                      field.didChange(category);
                      setState(() => _transactionCategory = category);
                    }
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 4),
        MouseRegion(
          cursor:
              isEditable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: IconButton(
            tooltip: isEditable ? 'Pick a random category' : null,
            onPressed: isEditable ? _pickRandomCategory : null,
            icon: const Icon(Icons.auto_fix_high),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTypeField(ThemeData theme, Color disabledColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction type',
          style: theme.textTheme.bodySmall?.copyWith(
            color:
                isEditable ? theme.colorScheme.onSurfaceVariant : disabledColor,
          ),
        ),
        const SizedBox(height: 4),
        SegmentedButton<TransactionType>(
          segments: TransactionType.values
              .map((type) => ButtonSegment<TransactionType>(
                    value: type,
                    label: Text(type.label),
                    icon: Icon(type.icon),
                  ))
              .toList(),
          expandedInsets: EdgeInsets.zero,
          selected: {_transactionType ?? TransactionType.deposit},
          onSelectionChanged: isEditable
              ? (newSelection) => _updateDraft(() {
                    _transactionType = newSelection.isNotEmpty
                        ? newSelection.first
                        : TransactionType.deposit;
                    if (isVoidType) _amount = 0;
                    _amountController.text =
                        CurrencyFormat.formatCents(_amount);
                  })
              : null,
          showSelectedIcon: false,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? theme.colorScheme.secondaryContainer
                  : null;
            }),
            visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
            ),
          ),
        ),
      ],
    );
  }

  void _cancelEditing() {
    final transaction = _originalTransaction;
    if (transaction == null) return;

    setState(() {
      _applyTransaction(transaction);
      _isEditing = false;
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _confirmDiscardAndNavigate() async {
    if (_isConfirmingDiscard) return;
    _isConfirmingDiscard = true;
    final shouldDiscard = await _showDiscardDialog();
    _isConfirmingDiscard = false;
    if (!mounted || !shouldDiscard) return;

    setState(() => _discardApproved = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navigateBack();
    });
  }

  Future<void> _handleBack() async {
    if (_hasUnsavedChanges) {
      await _confirmDiscardAndNavigate();
      return;
    }

    _navigateBack();
  }

  Future<void> _loadTransaction() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    try {
      final result = await context
          .read<TransactionService>()
          .getTransaction(widget.transactionId!);
      if (!mounted) return;

      final transaction = result.data;
      setState(() {
        _isLoading = false;
        if (result.isSuccess && transaction != null) {
          _originalTransaction = transaction;
          _applyTransaction(transaction);
        } else {
          _loadFailed = true;
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
    }
  }

  void _markUnsavedChanges() {
    if (_hasUnsavedChanges) return;
    setState(() => _hasUnsavedChanges = true);
  }

  void _navigateBack() {
    context
        .read<NavigationService>()
        .navigateBack(fallbackRoute: Routes.account(widget.accountId));
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (!context.mounted) return;

    _updateDraft(() {
      _dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      );
    });
  }

  void _pickRandomCategory() {
    final categories = TransactionCategory.values
        .where((category) =>
            category != TransactionCategory.none &&
            category != _transactionCategory)
        .toList();
    if (categories.isEmpty) return;

    _updateDraft(() {
      _transactionCategory = categories[Random().nextInt(categories.length)];
    });
  }

  Future<void> _requestCancelEditing() async {
    if (_hasUnsavedChanges && !await _showDiscardDialog()) return;
    _cancelEditing();
  }

  Future<bool> _showDiscardDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('Your unsaved changes will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep editing'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _submitTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (isVoidType) _amount = 0;
      final transaction = Transaction(
        id: isNewTransaction ? null : widget.transactionId,
        accountId: widget.accountId,
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
        isArchived: _isArchived,
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
          setState(() {
            _hasUnsavedChanges = false;
            _discardApproved = true;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _navigateBack();
          });
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

  Future<void> _unhideTransaction() async {
    final transaction = _originalTransaction;
    if (transaction == null || !_isArchived) return;

    final unhiddenTransaction = transaction.copyWith(isArchived: false);
    final result = await context
        .read<TransactionService>()
        .updateTransaction(unhiddenTransaction);
    if (!mounted) return;

    if (result.isSuccess) {
      setState(() {
        _originalTransaction = unhiddenTransaction;
        _isArchived = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction unhidden')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to unhide transaction: ${result.error}'),
        ),
      );
    }
  }

  void _updateDraft(VoidCallback update) {
    setState(() {
      update();
      _hasUnsavedChanges = true;
    });
  }
}
