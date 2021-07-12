import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/widgets/balance_text.dart';

// TODO: Implement user preferred order from https://pub.dev/packages/streaming_shared_preferences
class AccountList extends StatefulWidget {
  const AccountList({Key? key}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  late CollectionReference<Account> _accountsCollection;

  Color getBalanceColor(double balance) {
    return balance > 0
        ? Colors.green
        : balance < 0
            ? Colors.red
            : Colors.black;
  }

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Account>>(
        stream: _accountsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 2,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BalanceText(
                          text: "Current: ",
                          balance: 0,
                        ),
                        BalanceText(
                          text: "Available: ",
                          balance: 0,
                        ),
                      ],
                    ),
                  ),
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
              Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      BalanceText(
                        text: "Current: ",
                        balance: totalCurrentBalance,
                      ),
                      BalanceText(
                        text: "Available: ",
                        balance: totalAvailableBalance,
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  onReorder: (int oldIndex, int newIndex) async {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = accountData.removeAt(oldIndex);
                    accountData.insert(newIndex, item);
                  },
                  buildDefaultDragHandles: false,
                  itemCount: accountData.length,
                  itemBuilder: (ctx, index) {
                    final Account account = accountData[index].data();

                    String accountName = account.name;
                    double availableBalance = account.availableBalance;
                    double currentBalance = account.currentBalance;

                    return ReorderableDelayedDragStartListener(
                      key: Key(accountData[index].id),
                      index: index,
                      child: Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  accountName,
                                  style: TextStyle(fontSize: 24),
                                ),
                              ),
                              Column(
                                children: [
                                  BalanceText(
                                    text: "Available: ",
                                    balance: availableBalance,
                                  ),
                                  BalanceText(
                                    text: "Current: ",
                                    balance: currentBalance,
                                  ),
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.end,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        });
  }
}
