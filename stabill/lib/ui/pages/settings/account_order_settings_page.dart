import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class AccountOrderSettingsPage extends StatefulWidget {
  const AccountOrderSettingsPage({super.key});

  @override
  State<AccountOrderSettingsPage> createState() =>
      _AccountOrderSettingsPageState();
}

class _AccountOrderSettingsPageState extends State<AccountOrderSettingsPage> {
  List<Account> _accounts = [];
  bool _isLoading = true;
  bool _isSaving = false;
  Object? _loadError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reorder accounts'),
        leading: AdaptiveBackButton(fallbackRoute: Routes.settings),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Unable to load accounts: $_loadError'),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _loadAccounts,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_accounts.isEmpty) {
      return const Center(child: Text('No accounts to order'));
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _accounts.length,
      onReorderItem: _reorderAccounts,
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        final account = _accounts[index];
        return Card(
          key: ValueKey(account.id ?? '${account.name}-$index'),
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: ReorderableDragStartListener(
              index: index,
              child: const Tooltip(
                message: 'Drag to reorder',
                child: Icon(Icons.drag_handle),
              ),
            ),
            title: Text(account.name),
            subtitle: account.isArchived ? const Text('Archived') : null,
            trailing: Text('${index + 1}'),
          ),
        );
      },
    );
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    final result = await context.read<AccountService>().getAccounts();
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isFailure) {
        _loadError = result.error;
      } else {
        _accounts = result.data!;
      }
    });
  }

  Future<void> _reorderAccounts(int oldIndex, int newIndex) async {
    if (_isSaving || oldIndex == newIndex) return;

    final previousOrder = List<Account>.of(_accounts);
    final reorderedAccounts = List<Account>.of(_accounts);
    final account = reorderedAccounts.removeAt(oldIndex);
    reorderedAccounts.insert(newIndex, account);
    final accountIds = reorderedAccounts
        .map((account) => account.id)
        .whereType<String>()
        .toList();
    if (accountIds.length != reorderedAccounts.length) return;

    setState(() {
      _accounts = reorderedAccounts;
      _isSaving = true;
    });

    final result =
        await context.read<AccountService>().reorderAccounts(accountIds);
    if (!mounted) return;

    setState(() {
      _isSaving = false;
      if (result.isFailure) _accounts = previousOrder;
    });

    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to save account order: ${result.error}')),
      );
    }
  }
}
