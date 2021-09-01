import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart' as Stabill;
import 'package:stabill/widgets/account_summary_card.dart';
import 'package:stabill/widgets/balance_text.dart';
import 'package:stabill/widgets/transaction_card.dart';
import 'package:stabill/widgets/transaction_modal.dart';
import 'package:intl/intl.dart';

class TransactionArguments {
  final String accountID;
  final Account account;
  TransactionArguments(this.accountID, this.account);
}

class TransactionsPage extends StatefulWidget {
  static final String routeName = "/transactions";
  final String accountID;
  final Account account;

  const TransactionsPage(
      {Key? key, required this.accountID, required this.account})
      : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  late CollectionReference<Stabill.Transaction> _transactionsCollection;
  late Stream<QuerySnapshot<Stabill.Transaction>> _transactionsStream;

  @override
  void initState() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    // Get a stream for the accounts list to listen to
    _transactionsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .doc(widget.accountID)
        .collection("transactions")
        .withConverter<Stabill.Transaction>(
          fromFirestore: (snapshot, _) =>
              Stabill.Transaction.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        );

    _transactionsStream = _transactionsCollection.snapshots();

    // _scrollController.addListener(() {
    //   if (_scrollController.position.userScrollDirection ==
    //       ScrollDirection.reverse) {
    //     widget.shouldHideFAB(true);
    //   } else if (_scrollController.position.userScrollDirection ==
    //       ScrollDirection.forward) {
    //     widget.shouldHideFAB(false);
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.name),
      ),
      body: StreamBuilder<QuerySnapshot<Stabill.Transaction>>(
        stream: _transactionsStream,
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

          var transactionData = snapshot.data!.docs;

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Stabill.Transaction transaction =
                  snapshot.data!.docs[index].data();
              return GestureDetector(
                child: TransactionCard(transaction: transaction),
                onLongPress: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var newTransaction = await Navigator.of(context).push(
            MaterialPageRoute<Stabill.Transaction>(
              builder: (BuildContext context) => TransactionModal(),
              fullscreenDialog: true,
            ),
          );

          if (newTransaction != null) {
            String uid = FirebaseAuth.instance.currentUser!.uid;

            FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .collection("accounts")
                .doc(widget.accountID)
                .collection("transactions")
                .withConverter<Stabill.Transaction>(
                  fromFirestore: (snapshot, _) =>
                      Stabill.Transaction.fromJson(snapshot.data()!),
                  toFirestore: (acc, _) => acc.toJson(),
                )
                .add(newTransaction)
                .then((_) => print("Sucess"))
                .onError((error, stackTrace) => print(error));
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
