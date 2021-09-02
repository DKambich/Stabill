import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/pages/transactions_page.dart';
import 'package:stabill/widgets/cards/account_card.dart';
import 'package:stabill/widgets/cards/account_summary_card.dart';

class AccountList extends StatefulWidget {
  final Function(bool) shouldHideFAB;

  const AccountList({Key? key, required this.shouldHideFAB}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  final ScrollController _scrollController = ScrollController();
  late CollectionReference<Account> _accountsCollection;
  late Stream<QuerySnapshot<Account>> _accountsStream;

  @override
  void initState() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Get a stream for the accounts list to listen to
    _accountsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

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
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                AccountSummaryCard(
                  totalCurrentBalance: 0,
                  totalAvailableBalance: 0,
                ),
                Expanded(child: Center(child: CircularProgressIndicator())),
              ],
            );
          }

          var accountData = snapshot.data!.docs;

          double totalCurrentBalance = 0;
          double totalAvailableBalance = 0;

          accountData.forEach((element) {
            Account account = element.data();
            totalCurrentBalance += account.currentBalance;
            totalAvailableBalance += account.availableBalance;
          });

          return Column(
            children: [
              AccountSummaryCard(
                totalCurrentBalance: totalCurrentBalance,
                totalAvailableBalance: totalAvailableBalance,
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
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
                          arguments: TransactionArguments(
                            accountData[index].id,
                            account,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}
