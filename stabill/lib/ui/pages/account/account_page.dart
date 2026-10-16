import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/core/services/transaction/transaction_service.dart';
import 'package:stabill/data/enums/transaction_type.dart';
import 'package:stabill/data/misc/transaction_change.dart';
import 'package:stabill/data/misc/transaction_filter.dart';
import 'package:stabill/data/misc/transaction_pager.dart';
import 'package:stabill/data/misc/transaction_query.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/ui/widgets/balance_text.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class AccountPage extends StatefulWidget {
  final String accountId;
  const AccountPage({super.key, required, required this.accountId});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late TransactionPager _transactionPager;

  late Stream<Balance> accountBalanceStream;
  late AutoSizeGroup textGroup = AutoSizeGroup();

  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool showActions = true;
  bool showArchivedTransactions = false;

  String accountName = "";
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            title: Text(accountName),
            leading: AdaptiveBackButton(
              fallbackRoute: Routes.accounts,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(64), // Adjusted height
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<Balance>(
                  stream: accountBalanceStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Loading");
                    }

                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          Text(snapshot.connectionState.toString()),
                          Text("Error: ${snapshot.error}"),
                        ],
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.active &&
                        !snapshot.hasData) {
                      return Text("Oops no data!");
                    }

                    Balance balance = snapshot.data!;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BalanceText(
                                    balance: balance.availableInDollars,
                                    maxFontSize: 18,
                                    group: textGroup,
                                  ),
                                  const Text("Available")
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BalanceText(
                                    balance: balance.currentInDollars,
                                    maxFontSize: 18,
                                    group: textGroup,
                                  ),
                                  const Text("Current")
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search transactions',
                leading: const Icon(Icons.search),
                trailing: [
                  if (_searchQuery.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                    ),
                ],
                onChanged: _onSearchChanged,
              ),
            ),
          ),
          StreamBuilder<List<Transaction>>(
              stream: _transactionPager.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(snapshot.error.toString()),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  if (_transactionPager.loadError != null) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: TextButton.icon(
                          onPressed: _loadNextPage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry loading transactions'),
                        ),
                      ),
                    );
                  }
                  return SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final transactions = snapshot.data ?? [];

                if (transactions.isEmpty) {
                  if (_transactionPager.loadError != null) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: TextButton.icon(
                          onPressed: _loadNextPage,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry loading transactions'),
                        ),
                      ),
                    );
                  }

                  if (_transactionPager.isLoading ||
                      (_searchDebounce?.isActive ?? false)) {
                    return const SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        _searchQuery.trim().isEmpty
                            ? 'No transactions yet'
                            : 'No transactions found',
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == transactions.length) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: _transactionPager.loadError != null
                                ? TextButton.icon(
                                    onPressed: _loadNextPage,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry loading more'),
                                  )
                                : const CircularProgressIndicator(),
                          ),
                        );
                      }

                      return _buildTransactionCard(
                        context,
                        transactions[index],
                      );
                    },
                    childCount: transactions.length +
                        (_transactionPager.hasMore &&
                                (_transactionPager.isLoading ||
                                    _transactionPager.loadError != null)
                            ? 1
                            : 0),
                  ),
                );
              }),
        ],
      ),
      floatingActionButton: showActions
          ? FloatingActionButton(
              onPressed: () => {
                context
                    .read<NavigationService>()
                    .navigateToAddTransaction(widget.accountId)
              },
              elevation: 1,
              child: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: showActions
            ? kBottomNavigationBarHeight +
                kFloatingActionButtonMargin // TODO: Decide if this is the correct height
            : 0,
        child: BottomAppBar(
          color: Theme.of(context).colorScheme.secondaryContainer,
          elevation: 45,
          child: Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.schedule),
                tooltip: "Schedule Transactions",
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.swap_horiz),
                tooltip: "Transfer Funds",
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    showArchivedTransactions = !showArchivedTransactions;
                  });
                  _searchDebounce?.cancel();
                  unawaited(
                    _transactionPager.reset(
                      newQuery: _transactionPager.query.copyWith(
                        filter: TransactionFilter(
                          searchText: _searchQuery.trim(),
                          includeArchived: showArchivedTransactions,
                        ),
                        offset: 0,
                      ),
                    ),
                  );
                },
                icon: Icon(
                  showArchivedTransactions
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                tooltip: showArchivedTransactions
                    ? "Hide archived transactions"
                    : "Show all transactions",
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _transactionPager.dispose();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    var accountService = context.read<AccountService>();
    accountBalanceStream =
        accountService.watchAccount(widget.accountId).doOnData((account) {
      setState(() {
        accountName = account.name;
      });
    }).map((account) => account.balance ?? Balance(current: 0, available: 0));

    var transactionService = context.read<TransactionService>();
    _transactionPager = transactionService.createPager(
      widget.accountId,
      query: TransactionQuery(
        filter: TransactionFilter(
          searchText: _searchQuery,
          includeArchived: showArchivedTransactions,
        ),
        pageSize: 5,
      ),
      onStateChanged: _onPagerStateChanged,
    );
    unawaited(_transactionPager.loadNextPage());

    _controller.addListener(_onScroll);
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction transaction,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPressStart: (details) => _showTransactionMenu(
        context,
        transaction,
        details.globalPosition,
      ),
      child: Card(
        margin: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context
              .read<NavigationService>()
              .navigateToTransaction(widget.accountId, transaction.id ?? ''),
          child: ListTile(
            minVerticalPadding: 16,
            leading: CircleAvatar(
              backgroundColor: transaction.isCleared
                  ? null
                  : colorScheme.surfaceContainerHighest,
              child: Tooltip(
                message: transaction.category.label,
                child: Icon(
                  transaction.category.icon,
                  color: transaction.isCleared
                      ? null
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            title: Text(
              transaction.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    color: colorScheme.onSurface,
                  ),
            ),
            subtitle: Row(
              children: [
                if (transaction.isArchived) ...[
                  Tooltip(
                    message: 'Hidden transaction',
                    child: Icon(
                      Icons.visibility_off_outlined,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                if (!transaction.isCleared) ...[
                  Tooltip(
                    message: 'Uncleared transaction',
                    child: Icon(
                      Icons.schedule,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    DateFormat.yMMMd()
                        .add_jm()
                        .format(transaction.transactionDate),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: transaction.isCleared
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.8),
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                BalanceText(
                  balance: switch (transaction.transactionType) {
                    TransactionType.deposit => transaction.amount / 100,
                    TransactionType.withdrawal => -transaction.amount / 100,
                    TransactionType.voided => 0,
                  },
                  minFontSize: 12,
                  maxFontSize: 16,
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Transaction actions',
                  padding: EdgeInsets.zero,
                  onSelected: (action) =>
                      _handleTransactionAction(action, transaction),
                  itemBuilder: (context) =>
                      _buildTransactionMenuItems(context, transaction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildTransactionMenuItems(
    BuildContext context,
    Transaction transaction,
  ) =>
      [
        if (transaction.isArchived)
          const PopupMenuItem(
            value: 'unhide',
            child: Row(
              children: [
                Icon(Icons.visibility_outlined),
                SizedBox(width: 8),
                Text('Unhide'),
              ],
            ),
          )
        else if (transaction.isCleared)
          const PopupMenuItem(
            value: 'hide',
            child: Row(
              children: [
                Icon(Icons.visibility_off_outlined),
                SizedBox(width: 8),
                Text('Hide'),
              ],
            ),
          ),
        if (!transaction.isCleared)
          const PopupMenuItem(
            value: 'clear',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline),
                SizedBox(width: 8),
                Text('Mark as cleared'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'move',
          child: Row(
            children: [
              Icon(Icons.swap_horiz),
              SizedBox(width: 8),
              Text('Move'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline),
              SizedBox(width: 8),
              Text('Delete'),
            ],
          ),
        ),
      ];

  Future<void> _confirmDeleteTransaction(Transaction transaction) async {
    final transactionId = transaction.id;
    if (transactionId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete transaction?'),
        content: Text('Delete "${transaction.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || !mounted) return;

    final result = await context
        .read<TransactionService>()
        .deleteTransaction(transactionId);
    if (!mounted) return;

    if (result.isSuccess) {
      _transactionPager.applyLocalChange(
        TransactionChange(type: ChangeType.delete, transaction: transaction),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction deleted')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete transaction: ${result.error}')),
      );
    }
  }

  Future<void> _handleTransactionAction(
    String action,
    Transaction transaction,
  ) async {
    switch (action) {
      case 'hide':
        await _setTransactionArchived(transaction, isArchived: true);
      case 'unhide':
        await _setTransactionArchived(transaction, isArchived: false);
      case 'clear':
        await _markTransactionCleared(transaction);
      case 'move':
        await _showMoveTransactionDialog(transaction);
      case 'edit':
        final transactionId = transaction.id;
        if (transactionId != null) {
          await context
              .read<NavigationService>()
              .navigateToTransaction(widget.accountId, transactionId);
        }
      case 'delete':
        await _confirmDeleteTransaction(transaction);
    }
  }

  void _loadNextPage() {
    if (_transactionPager.isLoading || !_transactionPager.hasMore) return;
    unawaited(_transactionPager.loadNextPage());
  }

  Future<void> _markTransactionCleared(Transaction transaction) async {
    if (transaction.id == null) return;

    final updatedTransaction = transaction.copyWith(isCleared: true);
    final result = await context
        .read<TransactionService>()
        .updateTransaction(updatedTransaction);
    if (!mounted) return;

    if (result.isSuccess) {
      _transactionPager.applyLocalChange(
        TransactionChange(
          type: ChangeType.update,
          transaction: updatedTransaction,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction marked as cleared')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to mark transaction as cleared: ${result.error}'),
        ),
      );
    }
  }

  void _onPagerStateChanged() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_controller.hasClients ||
          !_transactionPager.hasMore ||
          _transactionPager.isLoading ||
          _transactionPager.loadError != null) {
        return;
      }
      if (_controller.position.extentAfter < 400) _loadNextPage();
    });
  }

  void _onScroll() {
    if (_controller.hasClients && _controller.position.extentAfter < 400) {
      _loadNextPage();
    }

    var showActions = switch (_controller.position.userScrollDirection) {
      == ScrollDirection.forward => true,
      == ScrollDirection.reverse => false,
      _ => null
    };

    if (showActions != null) {
      setState(() {
        this.showActions = showActions;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      unawaited(
        _transactionPager.reset(
          newQuery: _transactionPager.query.copyWith(
            filter: TransactionFilter(
              searchText: query.trim(),
              includeArchived: showArchivedTransactions,
            ),
            offset: 0,
          ),
        ),
      );
    });
  }

  Future<void> _setTransactionArchived(
    Transaction transaction, {
    required bool isArchived,
  }) async {
    final transactionId = transaction.id;
    if (transactionId == null) return;

    final result = await context
        .read<TransactionService>()
        .updateTransaction(transaction.copyWith(isArchived: isArchived));
    if (!mounted) return;

    if (result.isSuccess) {
      _transactionPager.applyLocalChange(
        TransactionChange(
          type: ChangeType.update,
          transaction: transaction.copyWith(isArchived: isArchived),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArchived ? 'Transaction hidden' : 'Transaction unhidden',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to ${isArchived ? 'hide' : 'unhide'} transaction: ${result.error}',
          ),
        ),
      );
    }
  }

  Future<void> _showMoveTransactionDialog(Transaction transaction) async {
    final accountService = context.read<AccountService>();
    final destination = await showDialog<Account>(
      context: context,
      builder: (dialogContext) {
        Account? selectedAccount;
        final accountsStream = accountService.watchAccounts();

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Move "${transaction.name}" to'),
            content: SizedBox(
              width: 360,
              child: StreamBuilder<List<Account>>(
                stream: accountsStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Unable to load accounts: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final accounts = snapshot.data!;
                  final destinations = accounts
                      .where((account) => account.id != widget.accountId)
                      .toList();
                  if (destinations.isEmpty) {
                    return const Text('No other accounts available.');
                  }

                  final nameCounts = <String, int>{};
                  for (final account in accounts) {
                    nameCounts.update(
                      account.name,
                      (count) => count + 1,
                      ifAbsent: () => 1,
                    );
                  }

                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 360),
                    child: RadioGroup<Account>(
                      groupValue: selectedAccount,
                      onChanged: (account) => setDialogState(
                        () => selectedAccount = account,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: destinations.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final account = destinations[index];
                          final accountId = account.id ?? 'Unknown ID';
                          final idSuffix = accountId.length > 8
                              ? accountId.substring(accountId.length - 8)
                              : accountId;

                          return RadioListTile<Account>(
                            value: account,
                            title: Text(account.name),
                            subtitle: nameCounts[account.name]! > 1
                                ? Text('ID: $idSuffix')
                                : null,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: selectedAccount == null
                    ? null
                    : () => Navigator.of(dialogContext).pop(selectedAccount),
                child: const Text('Move'),
              ),
            ],
          ),
        );
      },
    );
    if (destination == null || !mounted) return;

    // TODO: Persist the move and refresh the transaction pager.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moving transactions to ${destination.name} is not implemented yet',
        ),
      ),
    );
  }

  Future<void> _showTransactionMenu(
    BuildContext menuContext,
    Transaction transaction,
    Offset globalPosition,
  ) async {
    final overlay =
        Overlay.of(menuContext).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      overlay.localToGlobal(Offset.zero) & overlay.size,
    );
    final action = await showMenu<String>(
      context: menuContext,
      position: position,
      items: _buildTransactionMenuItems(menuContext, transaction),
    );

    if (action != null && mounted) {
      await _handleTransactionAction(action, transaction);
    }
  }
}
