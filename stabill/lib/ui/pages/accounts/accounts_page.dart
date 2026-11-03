import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/core/services/navigation/navigation_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/ui/dialogs/create_account_dialog.dart';
import 'package:stabill/ui/dialogs/edit_account_name_dialog.dart';
import 'package:stabill/ui/dialogs/transfer_funds_dialog.dart';
import 'package:stabill/ui/widgets/balance_text.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class AccountsPage extends StatefulWidget {
  final bool showArchivedAccounts;

  const AccountsPage({super.key, this.showArchivedAccounts = false});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  late Stream<Balance> balanceStream;
  late Stream<List<Account>> accountStream;
  late AutoSizeGroup textGroup = AutoSizeGroup();

  final ScrollController _controller = ScrollController();

  bool showActions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        slivers: [
          SliverAppBar(
            title: Text(
              widget.showArchivedAccounts ? 'Archived accounts' : 'Accounts',
            ),
            leading: AdaptiveBackButton(
              fallbackRoute: widget.showArchivedAccounts
                  ? Routes.accounts
                  : Routes.home,
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    context.read<NavigationService>().navigateToSettings(),
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_outlined),
              ),
              if (!widget.showArchivedAccounts)
                IconButton(
                  onPressed: () => context
                      .read<NavigationService>()
                      .navigateToArchivedAccounts(),
                  tooltip: 'Archived accounts',
                  icon: const Icon(Icons.archive_outlined),
                ),
            ],
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            floating: true,
            snap: true,
            pinned: true,
            bottom: widget.showArchivedAccounts
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(64),
                    child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StreamBuilder<Balance>(
                  stream: balanceStream,
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
          // SliverList for the body
          StreamBuilder<List<Account>>(
              stream: accountStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                var accounts = snapshot.data ?? [];
                if (accounts.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        widget.showArchivedAccounts
                            ? 'No archived accounts'
                            : 'No accounts yet',
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var account = accounts[index];
                      return _buildAccountTile(context, account);
                    },
                    childCount: accounts.length,
                  ),
                );
              }),
        ],
      ),
        floatingActionButton: !widget.showArchivedAccounts && showActions
          ? FloatingActionButton(
              onPressed: _addAccount,
              elevation: 1,
              child: Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        bottomNavigationBar: widget.showArchivedAccounts
          ? null
          : AnimatedContainer(
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
                onPressed: () => showTransferFundsDialog(context),
                icon: const Icon(Icons.swap_horiz),
                tooltip: "Transfer Funds",
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(_onScroll);
    _controller.dispose();
  }

  @override
  void initState() {
    super.initState();
    var accountService = context.read<AccountService>();
    balanceStream = accountService.watchTotalBalance();
    accountStream = accountService.watchAccounts().map(
      (accounts) => accounts
        .where((account) =>
          account.isArchived == widget.showArchivedAccounts)
        .toList(),
    );

    _controller.addListener(_onScroll);
  }

  Future<void> _addAccount() async {
    final accountDetails = await showCreateAccountDialog(context);
    if (accountDetails == null || !mounted) return;

    final result = await context.read<AccountService>().createAccount(
          accountDetails.name,
          accountDetails.startingBalanceInCents,
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Account created'
              : 'Failed to create account: ${result.error}',
        ),
      ),
    );
  }

  Widget _buildAccountTile(
    BuildContext context,
    Account account,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onLongPressStart: (details) => _showAccountMenu(
        context,
        account,
        details.globalPosition,
      ),
      onSecondaryTapDown: (details) => _showAccountMenu(
        context,
        account,
        details.globalPosition,
      ),
      child: Card(
        margin: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _goToAccount(account.id ?? ''),
          child: ListTile(
            minVerticalPadding: 20,
            leading: CircleAvatar(
              backgroundColor: colorScheme.surfaceContainerHighest,
              child: Icon(
                Icons.account_balance,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            title: AutoSizeText(
              account.name,
              maxLines: 1,
              minFontSize: 14,
              maxFontSize: 20,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 20,
                    color: colorScheme.onSurface,
                  ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildBalanceSummary(
                      context,
                      label: 'Current',
                      balance: (account.balance?.current ?? 0) / 100,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    _buildBalanceSummary(
                      context,
                      label: 'Available',
                      balance: (account.balance?.available ?? 0) / 100,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  tooltip: 'Account actions',
                  padding: EdgeInsets.zero,
                  onSelected: (action) => _handleAccountAction(
                    action,
                    account,
                  ),
                    itemBuilder: (context) =>
                      _buildAccountMenuItems(context, account),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSummary(
    BuildContext context, {
    required String label,
    required double balance,
    required Color color,
  }) =>
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                ),
          ),
          const SizedBox(width: 4),
          BalanceText(
            balance: balance,
            minFontSize: 12,
            maxFontSize: 16,
          ),
        ],
      );

  List<PopupMenuEntry<String>> _buildAccountMenuItems(
    BuildContext context,
    Account account,
  ) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined),
              SizedBox(width: 8),
              Text('Edit name'),
            ],
          ),
        ),
        PopupMenuItem(
          value: account.isArchived ? 'unarchive' : 'archive',
          child: Row(
            children: [
              Icon(
                account.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              const SizedBox(width: 8),
              Text(account.isArchived ? 'Unarchive' : 'Archive'),
            ],
          ),
        ),
        if (account.isArchived)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline),
                SizedBox(width: 8),
                Text('Delete permanently'),
              ],
            ),
          ),
      ];

  Future<void> _handleAccountAction(String action, Account account) async {
    switch (action) {
      case 'edit':
        await _editAccountName(account);
      case 'archive':
        await _setAccountArchived(account, isArchived: true);
      case 'unarchive':
        await _setAccountArchived(account, isArchived: false);
      case 'delete':
        await _confirmDeleteAccount(account);
    }
  }

  Future<void> _confirmDeleteAccount(Account account) async {
    final accountId = account.id;
    if (accountId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete account permanently?'),
        content: Text(
          'Delete "${account.name}" and all of its transactions and scheduled transactions? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete permanently'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await context.read<AccountService>().deleteAccount(accountId);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Account deleted'
              : 'Failed to delete account: ${result.error}',
        ),
      ),
    );
  }

  Future<void> _setAccountArchived(
    Account account, {
    required bool isArchived,
  }) async {
    final accountId = account.id;
    if (accountId == null) return;

    final result = await context.read<AccountService>().setAccountArchived(
          accountId: accountId,
          isArchived: isArchived,
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? isArchived
                  ? 'Account archived'
                  : 'Account unarchived'
              : 'Failed to ${isArchived ? 'archive' : 'unarchive'} account: ${result.error}',
        ),
      ),
    );
  }

  Future<void> _editAccountName(Account account) async {
    final accountId = account.id;
    if (accountId == null) return;

    final name = await showEditAccountNameDialog(
      context,
      accountName: account.name,
    );
    if (name == null || !mounted) return;

    final result = await context.read<AccountService>().updateAccountName(
          accountId: accountId,
          name: name,
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.isSuccess
              ? 'Account name updated'
              : 'Failed to update account name: ${result.error}',
        ),
      ),
    );
  }

  Future<void> _showAccountMenu(
    BuildContext menuContext,
    Account account,
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
      items: _buildAccountMenuItems(menuContext, account),
    );

    if (action != null && mounted) {
      await _handleAccountAction(action, account);
    }
  }

  void _goToAccount(String accountId) {
    context.read<NavigationService>().navigateToAccount(accountId);
  }

  void _onScroll() {
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
}
