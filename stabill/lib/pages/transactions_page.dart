import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart' as Stabill;
import 'package:stabill/widgets/cards/account_summary_card.dart';
import 'package:stabill/widgets/cards/transaction_card.dart';
import 'package:stabill/widgets/modals/transaction_form_modal.dart';

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
  late DocumentReference<Account> _accountDocument;
  late Stream<DocumentSnapshot<Account>> _accountStream;

  late CollectionReference<Stabill.Transaction> _transactionsCollection;
  late Stream<QuerySnapshot<Stabill.Transaction>> _transactionsStream;

  @override
  void initState() {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    // Get a reference to the account document
    _accountDocument = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection("accounts")
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(snapshot.data()!),
          toFirestore: (acc, _) => acc.toJson(),
        )
        .doc(widget.accountID);

    // Get a stream for the account
    _accountStream = _accountDocument.snapshots();

    // Get a stream for the account's transaction list to listen to
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
        actions: [],
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot<Account>>(
              stream: _accountStream,
              builder: (context, snapshot) {
                var accountCard = AccountSummaryCard(
                  totalCurrentBalance: 0,
                  totalAvailableBalance: 0,
                );
                if (snapshot.hasError ||
                    snapshot.connectionState == ConnectionState.waiting) {
                  return accountCard;
                }

                Account? account = snapshot.data!.data();

                if (account != null) {
                  accountCard = AccountSummaryCard(
                    totalCurrentBalance: account.currentBalance,
                    totalAvailableBalance: account.availableBalance,
                  );
                }
                return accountCard;
              }),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Stabill.Transaction>>(
              stream: _transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                var transactionData = snapshot.data!.docs;
                if (transactionData.length == 0) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 64,
                      ),
                      Text("Add a new transaction!"),
                    ],
                  );
                }

                transactionData.sort(
                    (a, b) => b.data().timestamp.compareTo(a.data().timestamp));
                return ListView.builder(
                  itemCount: transactionData.length,
                  itemBuilder: (context, index) {
                    Stabill.Transaction transaction =
                        transactionData[index].data();
                    String transactionID = transactionData[index].id;

                    return TransactionCard(
                      transaction: transaction,
                      actions: getActions(transaction),
                      onSelected: (selectedAction) async {
                        switch (selectedAction) {
                          case TransactionAction.Hide:
                            await hideTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Clear:
                            await clearTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Move:
                            await moveTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Edit:
                            await editTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Delete:
                            await deleteTransaction(transactionID);
                            break;
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Stabill.Transaction? createdTransaction =
              await Navigator.of(context).push(
            MaterialPageRoute<Stabill.Transaction>(
              builder: (BuildContext context) => TransactionModal(),
              fullscreenDialog: true,
            ),
          );

          if (createdTransaction != null) {
            addTransaction(createdTransaction);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> deleteAccount() {
    return _accountDocument
        .delete()
        .onError((error, stackTrace) => print(error.toString()));
  }

  Future<void> addTransaction(Stabill.Transaction transaction) {
    return _transactionsCollection.add(transaction);
  }

  Future<void> editTransaction(
      String transactionID, Stabill.Transaction transaction) async {
    Stabill.Transaction? editedTransaction = await Navigator.of(context).push(
      MaterialPageRoute<Stabill.Transaction>(
        builder: (BuildContext context) =>
            TransactionModal(transaction: transaction),
        fullscreenDialog: true,
      ),
    );

    if (editedTransaction != null) {
      _transactionsCollection.doc(transactionID).set(editedTransaction);
    }
  }

  Future<void> deleteTransaction(String transactionID) {
    return _transactionsCollection.doc(transactionID).delete();
  }

  Future<void> clearTransaction(
      String transactionID, Stabill.Transaction transaction) {
    transaction.cleared = true;
    return _transactionsCollection.doc(transactionID).set(transaction);
  }

  Future<void> hideTransaction(
      String transactionID, Stabill.Transaction transaction) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> moveTransaction(
      String transactionID, Stabill.Transaction transaction) {
    return Future.delayed(Duration(milliseconds: 100));
  }

  List<PopupMenuItem<TransactionAction>> getActions(
      Stabill.Transaction transaction) {
    var conditionalOption;
    if (transaction.cleared) {
      conditionalOption = PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.visibility_off),
          title: Text("Hide"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Hide,
      );
    } else {
      conditionalOption = PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.check),
          title: Text("Mark Cleared"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Clear,
      );
    }
    return [
      conditionalOption,
      PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text("Move"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Move,
      ),
      PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text("Edit"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Edit,
      ),
      PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text("Delete"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Delete,
      ),
    ];
  }

  Future<TransactionAction?> showTransactionActions(
      Stabill.Transaction transaction, RelativeRect tapPoint) {
    // Define the conditional option
    var conditionalOption;
    if (transaction.cleared) {
      conditionalOption = PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.visibility_off),
          title: Text("Hide"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Hide,
      );
    } else {
      conditionalOption = PopupMenuItem<TransactionAction>(
        child: ListTile(
          leading: Icon(Icons.check),
          title: Text("Mark Cleared"),
          contentPadding: EdgeInsets.zero,
        ),
        value: TransactionAction.Clear,
      );
    }

    // Show the transaction actions
    return showMenu<TransactionAction>(
      context: context,
      position: tapPoint,
      items: [
        conditionalOption,
        PopupMenuItem<TransactionAction>(
          child: ListTile(
            leading: Icon(Icons.swap_horiz),
            title: Text("Move"),
            contentPadding: EdgeInsets.zero,
          ),
          value: TransactionAction.Move,
        ),
        PopupMenuItem<TransactionAction>(
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text("Edit"),
            contentPadding: EdgeInsets.zero,
          ),
          value: TransactionAction.Edit,
        ),
        PopupMenuItem<TransactionAction>(
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text("Delete"),
            contentPadding: EdgeInsets.zero,
          ),
          value: TransactionAction.Delete,
        ),
      ],
    );
  }
}
