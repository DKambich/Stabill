import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart' as Stabill;
import 'package:stabill/widgets/cards/account_summary_card.dart';
import 'package:stabill/widgets/cards/transaction_card.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';
import 'package:stabill/widgets/modals/balance_correction_modal.dart';
import 'package:stabill/widgets/modals/transaction_form_modal.dart';
import 'package:stabill/widgets/modals/transfer_funds_modal.dart';
import 'package:stabill/widgets/modals/transfer_transaction_modal.dart';

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

enum TransactionPageAction { Correction, Transfer, Reveal, Recurring }

class _TransactionsPageState extends State<TransactionsPage> {
  late DocumentReference<Account> _accountDocument;
  late Stream<DocumentSnapshot<Account>> _accountStream;

  late CollectionReference<Stabill.Transaction> _transactionsCollection;
  late Stream<QuerySnapshot<Stabill.Transaction>> _transactionsStream;

  late TextEditingController searchController;
  late FocusNode searchNode;
  late bool isSearching;

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

    searchController = TextEditingController();
    searchNode = FocusNode();
    isSearching = false;
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          transitionBuilder: (child, val) => SizeTransition(
            child: child,
            sizeFactor: val,
          ),
          duration: Duration(milliseconds: 250),
          child: isSearching
              ? TextField(
                  controller: searchController,
                  focusNode: searchNode,
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    hintText: "Search for...",
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  onSubmitted: (_) {
                    if (searchController.text.isEmpty) {
                      searchNode.unfocus();
                      setState(() => isSearching = !isSearching);
                    }
                  },
                  onChanged: (text) {
                    setState(() {});
                  },
                )
              : Text(widget.account.name),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              if (isSearching) {
                searchController.clear();
                searchNode.unfocus();
              } else {
                searchNode.requestFocus();
              }
              isSearching = !isSearching;
            }),
            icon: AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              transitionBuilder: (child, val) => ScaleTransition(
                child: RotationTransition(child: child, turns: val),
                scale: val,
              ),
              child: isSearching
                  ? Icon(
                      Icons.close,
                      key: ValueKey<IconData>(Icons.close),
                    )
                  : Icon(
                      Icons.search,
                      key: ValueKey<IconData>(Icons.search),
                    ),
            ),
          ),
          PopupMenuButton(
              onSelected: (TransactionPageAction selected) async {
                switch (selected) {
                  case TransactionPageAction.Correction:
                    BalanceCorrectionModal.show(context, widget.accountID);
                    break;
                  case TransactionPageAction.Transfer:
                    TransferFundsModal.show(
                      context,
                      defaultAccountID: widget.accountID,
                    );
                    break;
                  case TransactionPageAction.Reveal:
                    // Get all hiddent transactions
                    final transactionUpdates = await _transactionsCollection
                        .where("hidden", isEqualTo: true)
                        .get();
                    // Update each hiddent transaction
                    transactionUpdates.docs.forEach(
                      (transaction) => transaction.reference.update(
                        {"hidden": false},
                      ),
                    );
                    break;
                  case TransactionPageAction.Recurring:
                    // TODO: Handle this case.
                    break;
                }
              },
              itemBuilder: (_) => buildPageActions())
        ],
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
                      Icon(Icons.payment, size: 64),
                      Text("Add a new transaction!"),
                    ],
                  );
                }

                transactionData = transactionData
                    .where((element) => !element.data().hidden)
                    .toList();
                if (isSearching) {
                  String query = searchController.text.toLowerCase();
                  transactionData = transactionData
                      .where(
                        (element) =>
                            element.data().name.toLowerCase().contains(query),
                      )
                      .toList();
                }

                transactionData.sort(
                  (a, b) => b.data().timestamp.compareTo(a.data().timestamp),
                );

                return ListView.builder(
                  itemCount: transactionData.length,
                  itemBuilder: (context, index) {
                    Stabill.Transaction transaction =
                        transactionData[index].data();
                    String transactionID = transactionData[index].id;

                    return TransactionCard(
                      transaction: transaction,
                      query: searchController.text,
                      actions: buildTransactionActions(transaction),
                      onSelected: (selectedAction) async {
                        switch (selectedAction) {
                          case TransactionAction.Hide:
                            await hideTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Clear:
                            await clearTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Move:
                            moveTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Edit:
                            await editTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.Delete:
                            bool confirm = await ConfirmDialog.show(
                              context,
                              "Delete Transaction",
                              "Are you sure you want to delete the transaction '${transaction.name}'?",
                              confirmColor: Colors.red,
                            );
                            if (confirm) {
                              await deleteTransaction(transactionID);
                            }
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
    transaction.hidden = true;
    return _transactionsCollection.doc(transactionID).set(transaction);
  }

  void moveTransaction(String transactionID, Stabill.Transaction transaction) {
    TransferTransactionModal.show(
      context,
      transaction,
      transactionID,
      widget.accountID,
    );
  }

  List<PopupMenuItem<TransactionAction>> buildTransactionActions(
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

  List<PopupMenuEntry<TransactionPageAction>> buildPageActions() {
    return <PopupMenuEntry<TransactionPageAction>>[
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.Correction,
        child: ListTile(
          leading: Icon(Icons.price_change),
          title: Text("Balance Correction"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.Reveal,
        child: ListTile(
          leading: Icon(Icons.visibility),
          title: Text("Reveal Transactions"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.Transfer,
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text("Transfer Funds"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.Recurring,
        child: ListTile(
          leading: Icon(Icons.repeat),
          title: Text("Recurring Transactions"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    ];
  }
}
