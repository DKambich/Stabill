import 'package:cloud_firestore/cloud_firestore.dart'
    show
        DocumentReference,
        DocumentSnapshot,
        CollectionReference,
        QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/providers/data_provider.dart';
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
  static const String routeName = "/transactions";
  final Account account;

  const TransactionsPage({Key? key, required this.account}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

enum TransactionPageAction { correction, transfer, reveal, recurring }

class _TransactionsPageState extends State<TransactionsPage> {
  late DocumentReference<Account> _accountDocument;
  late Stream<DocumentSnapshot<Account>> _accountStream;

  late CollectionReference<Transaction> _transactionsCollection;
  late Stream<QuerySnapshot<Transaction>> _transactionsStream;

  late TextEditingController searchController;
  late FocusNode searchNode;
  late bool isSearching;

  @override
  void initState() {
    final DataProvider dataProvider = context.read<DataProvider>();
    // Get a reference to the account document
    _accountDocument = dataProvider.getAccountDocument(widget.account.id);

    // Get a stream for the account
    _accountStream = _accountDocument.snapshots();

    // Get a stream for the account's transaction list to listen to
    _transactionsCollection =
        dataProvider.getTransactionCollection(widget.account.id);

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
            sizeFactor: val,
            child: child,
          ),
          duration: const Duration(milliseconds: 250),
          child: isSearching
              ? TextField(
                  controller: searchController,
                  focusNode: searchNode,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
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
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, val) => ScaleTransition(
                scale: val,
                child: RotationTransition(turns: val, child: child),
              ),
              child: isSearching
                  ? const Icon(
                      Icons.close,
                      key: ValueKey<IconData>(Icons.close),
                    )
                  : const Icon(
                      Icons.search,
                      key: ValueKey<IconData>(Icons.search),
                    ),
            ),
          ),
          PopupMenuButton(
            onSelected: (TransactionPageAction selected) async {
              switch (selected) {
                case TransactionPageAction.correction:
                  BalanceCorrectionModal.show(context, widget.account.id);
                  break;
                case TransactionPageAction.transfer:
                  TransferFundsModal.show(
                    context,
                    defaultAccountID: widget.account.id,
                  );
                  break;
                case TransactionPageAction.reveal:
                  // Get all hiddent transactions
                  final transactionUpdates = await _transactionsCollection
                      .where("hidden", isEqualTo: true)
                      .get();

                  // Show each hidden transaction
                  void revealTransaction(transaction) {
                    transaction.reference.update(
                      {"hidden": false},
                    );
                  }
                  transactionUpdates.docs.forEach(revealTransaction);
                  break;
                case TransactionPageAction.recurring:
                  // TODO: Handle this case.
                  break;
              }
            },
            itemBuilder: (_) => buildPageActions(),
          )
        ],
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot<Account>>(
            stream: _accountStream,
            builder: (context, snapshot) {
              var accountCard = const AccountSummaryCard(
                totalCurrentBalance: 0,
                totalAvailableBalance: 0,
              );
              if (snapshot.hasError ||
                  snapshot.connectionState == ConnectionState.waiting) {
                return accountCard;
              }

              final Account? account = snapshot.data!.data();

              if (account != null) {
                accountCard = AccountSummaryCard(
                  totalCurrentBalance: account.currentBalance,
                  totalAvailableBalance: account.availableBalance,
                );
              }
              return accountCard;
            },
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Transaction>>(
              stream: _transactionsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var transactionData = snapshot.data!.docs;
                if (transactionData.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.payment, size: 64),
                      Text("Add a new transaction!"),
                    ],
                  );
                }

                transactionData = transactionData
                    .where((element) => !element.data().hidden)
                    .toList();
                if (isSearching) {
                  final String query = searchController.text.toLowerCase();
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
                    final Transaction transaction =
                        transactionData[index].data();
                    final String transactionID = transactionData[index].id;

                    return TransactionCard(
                      transaction: transaction,
                      query: searchController.text,
                      actions: buildTransactionActions(transaction),
                      onSelected: (selectedAction) async {
                        switch (selectedAction) {
                          case TransactionAction.hide:
                            await hideTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.clear:
                            await clearTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.move:
                            moveTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.edit:
                            await editTransaction(transactionID, transaction);
                            break;
                          case TransactionAction.delete:
                            final bool confirm = await ConfirmDialog.show(
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
          final Transaction? createdTransaction = await Navigator.of(context)
              .pushNamed<Transaction>(TransactionModal.routeName);

          if (createdTransaction != null) {
            addTransaction(createdTransaction);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> addTransaction(Transaction transaction) {
    return _transactionsCollection.add(transaction);
  }

  Future<void> editTransaction(
    String transactionID,
    Transaction transaction,
  ) async {
    final Transaction? editedTransaction = await Navigator.of(context).push(
      MaterialPageRoute<Transaction>(
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

  Future<void> clearTransaction(String transactionID, Transaction transaction) {
    transaction.cleared = true;
    return _transactionsCollection.doc(transactionID).set(transaction);
  }

  Future<void> hideTransaction(String transactionID, Transaction transaction) {
    transaction.hidden = true;
    return _transactionsCollection.doc(transactionID).set(transaction);
  }

  void moveTransaction(String transactionID, Transaction transaction) {
    TransferTransactionModal.show(
      context,
      transaction,
      transactionID,
      widget.account.id,
    );
  }

  List<PopupMenuItem<TransactionAction>> buildTransactionActions(
    Transaction transaction,
  ) {
    return [
      if (transaction.cleared)
        const PopupMenuItem<TransactionAction>(
          value: TransactionAction.hide,
          child: ListTile(
            leading: Icon(Icons.visibility_off),
            title: Text("Hide"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      if (!transaction.cleared)
        const PopupMenuItem<TransactionAction>(
          value: TransactionAction.clear,
          child: ListTile(
            leading: Icon(Icons.check),
            title: Text("Mark Cleared"),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      const PopupMenuItem<TransactionAction>(
        value: TransactionAction.move,
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text("Move"),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem<TransactionAction>(
        value: TransactionAction.edit,
        child: ListTile(
          leading: Icon(Icons.edit),
          title: Text("Edit"),
          contentPadding: EdgeInsets.zero,
        ),
      ),
      const PopupMenuItem<TransactionAction>(
        value: TransactionAction.delete,
        child: ListTile(
          leading: Icon(Icons.delete),
          title: Text("Delete"),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ];
  }

  List<PopupMenuEntry<TransactionPageAction>> buildPageActions() {
    return <PopupMenuEntry<TransactionPageAction>>[
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.correction,
        child: ListTile(
          leading: Icon(Icons.price_change),
          title: Text("Balance Correction"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.reveal,
        child: ListTile(
          leading: Icon(Icons.visibility),
          title: Text("Reveal Transactions"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.transfer,
        child: ListTile(
          leading: Icon(Icons.swap_horiz),
          title: Text("Transfer Funds"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.recurring,
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
