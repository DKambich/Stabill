import 'package:cloud_firestore/cloud_firestore.dart'
    show
        DocumentReference,
        DocumentSnapshot,
        CollectionReference,
        Query,
        QueryDocumentSnapshot,
        QuerySnapshot;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stabill/constants.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';
import 'package:stabill/pages/transaction_form_page.dart';
import 'package:stabill/providers/data_provider.dart';
import 'package:stabill/providers/preference_provider.dart';
import 'package:stabill/utilities/header_list.dart';
import 'package:stabill/widgets/cards/account_summary_card.dart';
import 'package:stabill/widgets/cards/transaction_card.dart';
import 'package:stabill/widgets/dialogs/confirm_dialog.dart';
import 'package:stabill/widgets/dialogs/transaction_details_dialog.dart';
import 'package:stabill/widgets/prompts/balance_correction_prompt.dart';
import 'package:stabill/widgets/prompts/transfer_funds_prompt.dart';
import 'package:stabill/widgets/prompts/transfer_transaction_prompt.dart';

class TransactionsPage extends StatefulWidget {
  static const String routeName = "/transactions";
  final Account account;

  const TransactionsPage({Key? key, required this.account}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

enum TransactionPageAction { correction, transfer, reveal }

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

    // Build transaction query, filter transactions that are hidden
    Query<Transaction> transactionQuery =
        _transactionsCollection.where("hidden", isEqualTo: false);

    // If hiding cleared transactions, filter them out
    if (context.read<PreferenceProvider>().hideCleared) {
      transactionQuery = transactionQuery.where("cleared", isEqualTo: false);
    }
    // Otherwise, if prioritizing cleared transactions, start ordering by them
    else if (context.read<PreferenceProvider>().prioritizePending) {
      transactionQuery = transactionQuery.orderBy("cleared");
    }

    // Order by timestamp
    transactionQuery = transactionQuery.orderBy("timestamp", descending: true);

    _transactionsStream = transactionQuery.snapshots();

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
    final header = StreamBuilder<DocumentSnapshot<Account>>(
      stream: _accountStream,
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const AccountSummaryCard(
            totalCurrentBalance: 0,
            totalAvailableBalance: 0,
          );
        }

        final Account? account = snapshot.data!.data();

        if (account != null) {
          return AccountSummaryCard(
            totalCurrentBalance: account.currentBalance,
            totalAvailableBalance: account.availableBalance,
          );
        }
        return const AccountSummaryCard(
          totalCurrentBalance: 0,
          totalAvailableBalance: 0,
        );
      },
    );

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
                      Icons.close_rounded,
                      key: ValueKey<IconData>(Icons.close_rounded),
                    )
                  : const Icon(
                      Icons.search_rounded,
                      key: ValueKey<IconData>(Icons.search_rounded),
                    ),
            ),
          ),
          PopupMenuButton(
            shape: menuShape,
            onSelected: (TransactionPageAction selected) async {
              switch (selected) {
                case TransactionPageAction.correction:
                  BalanceCorrectionPrompt.show(context, widget.account.id);
                  break;
                case TransactionPageAction.transfer:
                  TransferFundsPrompt.show(
                    context,
                    defaultAccountID: widget.account.id,
                  );
                  break;
                case TransactionPageAction.reveal:
                  // Get all hidden transactions
                  final transactionUpdates = await _transactionsCollection
                      .where("hidden", isEqualTo: true)
                      .get();

                  // Show each hidden transaction
                  void revealTransaction(
                    QueryDocumentSnapshot<Transaction> transaction,
                  ) {
                    transaction.reference.update(
                      {"hidden": false},
                    );
                  }
                  transactionUpdates.docs.forEach(revealTransaction);
                  break;
              }
            },
            itemBuilder: (_) => buildPageActions(),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Transaction>>(
        stream: _transactionsStream,
        builder: (context, snapshot) {
          List<QueryDocumentSnapshot<Transaction>> transactionData = [];
          if (snapshot.data != null) transactionData = snapshot.data!.docs;

          if (isSearching) {
            final String query = searchController.text.toLowerCase();
            transactionData = transactionData
                .where(
                  (element) =>
                      element.data().name.toLowerCase().contains(query),
                )
                .toList();
          }

          return HeaderList(
            header: header,
            error: snapshot.hasError,
            onError: const Center(child: Text('Something went wrong')),
            isLoading: snapshot.connectionState == ConnectionState.waiting,
            onLoading: const Center(child: CircularProgressIndicator()),
            itemHeight: 110,
            onEmpty: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.payment_rounded, size: 64),
                Text(
                  "Add a new transaction!",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            itemCount: transactionData.length,
            itemBuilder: (context, index) {
              final Transaction transaction = transactionData[index].data();
              final String transactionID = transactionData[index].id;

              return TransactionCard(
                transaction: transaction,
                query: searchController.text,
                onTap: () {
                  TransactionDetailsDialog.show(context, transaction);
                },
                onSelected: (selectedAction) async {
                  switch (selectedAction) {
                    case TransactionAction.hide:
                      await hideTransaction(transactionID, transaction);
                      break;
                    case TransactionAction.clear:
                      await context
                          .read<DataProvider>()
                          .clearTransaction(widget.account, transaction);
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
                        "Delete Transaction?",
                        "Are you sure you want to delete the transaction '${transaction.name}'?",
                        confirmText: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      );
                      if (confirm) {
                        if (!mounted) return;
                        await context.read<DataProvider>().deleteTransaction(
                              widget.account,
                              transaction,
                            );
                      }
                      break;
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final Transaction? createdTransaction =
              await Navigator.of(context).push(
            MaterialPageRoute<Transaction>(
              builder: (BuildContext context) => TransactionModal(
                accountID: widget.account.id,
              ),
              fullscreenDialog: true,
            ),
          );

          // = await Navigator.of(context)
          //     .pushNamed<Transaction>(TransactionModal.routeName);

          if (createdTransaction != null) {
            if (!mounted) return;
            await context
                .read<DataProvider>()
                .addTransaction(widget.account, createdTransaction);
          }
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Future<void> editTransaction(
    String transactionID,
    Transaction transaction,
  ) async {
    final Transaction? editedTransaction = await Navigator.of(context).push(
      MaterialPageRoute<Transaction>(
        builder: (BuildContext context) => TransactionModal(
          transaction: transaction,
          accountID: widget.account.id,
        ),
        fullscreenDialog: true,
      ),
    );

    if (editedTransaction != null) {
      if (!mounted) return;
      await context
          .read<DataProvider>()
          .updateTransaction(widget.account, transaction, editedTransaction);
    }
  }

  Future<void> hideTransaction(String transactionID, Transaction transaction) {
    transaction.hidden = true;
    return _transactionsCollection.doc(transactionID).set(transaction);
  }

  void moveTransaction(String transactionID, Transaction transaction) {
    TransferTransactionPrompt.show(
      context,
      transaction,
      transactionID,
      widget.account.id,
    );
  }

  List<PopupMenuEntry<TransactionPageAction>> buildPageActions() {
    return <PopupMenuEntry<TransactionPageAction>>[
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.correction,
        child: ListTile(
          leading: Icon(Icons.price_change_rounded),
          title: Text("Balance Correction"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.reveal,
        child: ListTile(
          leading: Icon(Icons.visibility_rounded),
          title: Text("Reveal Transactions"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
      const PopupMenuItem<TransactionPageAction>(
        value: TransactionPageAction.transfer,
        child: ListTile(
          leading: Icon(Icons.swap_horiz_rounded),
          title: Text("Transfer Funds"),
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    ];
  }
}
