import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/widgets/balance_text.dart';

class AccountList extends StatefulWidget {
  final List<Account> accounts;

  const AccountList({Key? key, required this.accounts}) : super(key: key);

  @override
  _AccountListState createState() => _AccountListState();
}

class _AccountListState extends State<AccountList> {
  late Stream<QuerySnapshot> _accountsStream;

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
    _accountsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _accountsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          var data = snapshot.data!.docs;
          double totalCurrentBalance = 0;
          double totalAvailableBalance = 0;

          widget.accounts.forEach((element) {
            totalCurrentBalance += element.currentBalance;
            totalAvailableBalance += element.availableBalance;
          });
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(blurRadius: 0.25),
                  ],
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
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
              Expanded(
                child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (ctx, index) {
                      final Account account = Account.fromJson(
                          data[index].data() as Map<String, dynamic>);

                      String accountName = account.name;
                      double availableBalance = account.availableBalance;
                      double currentBalance = account.currentBalance;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Card(
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
                    }),
              ),
            ],
          );
        });
  }
}
