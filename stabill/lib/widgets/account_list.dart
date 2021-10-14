import 'package:cloud_firestore/cloud_firestore.dart'
    show CollectionReference, QuerySnapshot, QueryDocumentSnapshot;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/pages/transactions_page.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/utilities/header_list.dart';
import 'package:stabill/widgets/cards/account_card.dart';
import 'package:stabill/widgets/cards/account_summary_card.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';
import 'package:stabill/widgets/prompts/edit_account_prompt.dart';

class AccountList extends StatefulWidget {
  final Function(bool) shouldHideFAB;

  const AccountList({Key? key, required this.shouldHideFAB}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

enum AccountAction { edit, delete }

class _AccountListState extends State<AccountList> {
  final ScrollController _scrollController = ScrollController();
  late CollectionReference<Account> _accountsCollection;
  late Stream<QuerySnapshot<Account>> _accountsStream;

  @override
  void initState() {
    // Get a stream for the accounts list to listen to
    _accountsCollection = context.read<DataProvider>().getAccountsCollection();

    _accountsStream = _accountsCollection.snapshots();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        widget.shouldHideFAB(true);
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        widget.shouldHideFAB(false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Account>>(
      stream: _accountsStream,
      builder: (context, snapshot) {
        List<QueryDocumentSnapshot<Account>> accountData = [];
        if (snapshot.data != null) accountData = snapshot.data!.docs;

        int totalCurrentBalance = 0;
        int totalAvailableBalance = 0;

        void totalBalances(QueryDocumentSnapshot<Account> element) {
          final Account account = element.data();
          totalCurrentBalance += account.currentBalance;
          totalAvailableBalance += account.availableBalance;
        }

        accountData.forEach(totalBalances);

        return HeaderList(
          header: AccountSummaryCard(
            totalCurrentBalance: totalCurrentBalance,
            totalAvailableBalance: totalAvailableBalance,
          ),
          controller: _scrollController,
          error: snapshot.hasError,
          onError: const Text('Something went wrong'),
          isLoading: snapshot.connectionState == ConnectionState.waiting,
          onLoading: const Center(child: CircularProgressIndicator()),
          onEmpty: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.savings_rounded,
                  size: 64,
                ),
                Text("Get started by adding a new account!"),
              ],
            ),
          ),
          itemCount: accountData.length,
          itemBuilder: (ctx, index) {
            final Account account = accountData[index].data();
            final String accountID = accountData[index].id;
            return AccountCard(
              key: Key(accountID),
              account: account,
              onTap: () {
                widget.shouldHideFAB(false);
                Navigator.of(context).pushNamed(
                  TransactionsPage.routeName,
                  arguments: account,
                );
              },
              actions: getAccountActions(),
              onSelected: (AccountAction selectedAction) async {
                switch (selectedAction) {
                  case AccountAction.edit:
                    EditAccountPrompt.show(context, accountID);
                    break;
                  case AccountAction.delete:
                    final bool confirm = await ConfirmDialog.show(
                      context,
                      "Delete Account",
                      "Are you sure you want to delete the account '${account.name}'?",
                    );
                    if (confirm) {
                      if (!mounted) return;
                      this.context.read<DataProvider>().deleteAccount(account);
                    }
                    break;
                }
              },
            );
          },
        );
      },
    );
  }

  Future<void> deleteAccount(String accountID) {
    return _accountsCollection.doc(accountID).delete();
  }

  List<PopupMenuItem<AccountAction>> getAccountActions() {
    // Create the account actions
    return const [
      PopupMenuItem<AccountAction>(
        value: AccountAction.edit,
        child: ListTile(
          leading: Icon(Icons.edit_rounded),
          title: Text("Edit"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      PopupMenuItem<AccountAction>(
        value: AccountAction.delete,
        child: ListTile(
          leading: Icon(Icons.delete_rounded),
          title: Text("Delete"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    ];
  }
}
