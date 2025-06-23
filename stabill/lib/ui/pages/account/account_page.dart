import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:stabill/config/router.dart';
import 'package:stabill/core/services/account/account_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/ui/widgets/balance_text.dart';
import 'package:stabill/ui/widgets/fallback_back_button.dart';

class AccountPage extends StatefulWidget {
  final String accountId;
  const AccountPage({super.key, required, required this.accountId});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
            title: const Text('Account'),
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
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var account = accounts[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(account.name),
                          subtitle: Text(account.balance.toString()),
                        ),
                      );
                    },
                    childCount: accounts.length,
                  ),
                );
              }),
        ],
      ),
      floatingActionButton: showActions
          ? FloatingActionButton(
              onPressed: _addAccount,
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
    balanceStream = accountService.getTotalBalance();
    accountStream = accountService.getAccounts();

    _controller.addListener(_onScroll);
  }

  void _addAccount() {
    context.read<AccountService>().createAccount(
          "Account #${Random().nextInt(1000)}",
          Random().nextInt(1000000),
        );
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
