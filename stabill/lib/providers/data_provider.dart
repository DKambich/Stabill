import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'
    show
        CollectionReference,
        DocumentReference,
        FieldValue,
        FirebaseFirestore,
        WriteBatch;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';

class DataProvider {
  final FirebaseFirestore firebaseFirestore;
  final User? user;

  static const String userCol = "users";
  static const String accountCol = "accounts";
  static const String transactionCol = "transactions";

  DataProvider(this.firebaseFirestore, this.user);

  CollectionReference<Account> getAccountsCollection() {
    if (user == null) throw Exception("User is not signed in");
    final String uid = user!.uid;
    return firebaseFirestore
        .collection(userCol)
        .doc(uid)
        .collection(accountCol)
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(
            snapshot.data()!,
            snapshot.id,
          ),
          toFirestore: (account, _) => account.toJson(),
        );
  }

  DocumentReference<Account> getAccountDocument(String accountID) {
    return getAccountsCollection().doc(accountID);
  }

  Future<Account> getAccount(String accountID) async {
    return (await getAccountDocument(accountID).get()).data()!;
  }

  CollectionReference<Transaction> getTransactionCollection(String accountID) {
    return getAccountDocument(accountID)
        .collection(transactionCol)
        .withConverter<Transaction>(
          fromFirestore: (snapshot, _) => Transaction.fromJson(
            snapshot.data()!,
            snapshot.id,
          ),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  DocumentReference<Transaction> getTransactionDocument(
    String accountID,
    String transactionID,
  ) {
    return getTransactionCollection(accountID).doc(transactionID);
  }

  Future<Transaction> getTransaction(
    String accountID,
    String transactionID,
  ) async {
    return (await getTransactionDocument(accountID, transactionID).get())
        .data()!;
  }

  Future<void> createAccount(Account account, int startingBalance) async {
    try {
      // Add the new account to the collection
      final accountRef = await getAccountsCollection().add(account);

      // Don't create a starting transaction if there is no balance
      if (startingBalance == 0) return;

      // Create a transaction as the starting balance for the account
      final Transaction startingTransaction = Transaction(
        name: "Starting Balance",
        amount: startingBalance,
        timestamp: DateTime.now(),
        cleared: true,
        method: TransactionType.deposit,
        memo: "System Generated",
      );

      // Add the new transaction to the collection
      await getTransactionCollection(accountRef.id).add(startingTransaction);

      account.id = accountRef.id;
      await incrementBalance(account, transaction: startingTransaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      // Get the Account document
      final accountDoc = getAccountDocument(account.id);
      // Update the Account
      await accountDoc.set(account);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> incrementBalance(
    Account account, {
    Transaction? transaction,
    int? deltaCurrent,
    int? deltaAvailable,
  }) async {
    assert(
      transaction != null || (deltaCurrent != null && deltaAvailable != null),
      "Must specify a transaction or a deltaCurrent and deltaAvailable",
    );
    // assert(
    //   transaction != null && (deltaCurrent != null || deltaAvailable != null),
    //   "Must specify only a transaction or a deltaCurrent and deltaAvailable",
    // );
    int incrementCurrent = 0;
    int incrementAvailable = 0;
    if (transaction != null) {
      incrementCurrent = transaction.amount *
          (transaction.method == TransactionType.deposit ? 1 : -1);
      incrementAvailable = transaction.cleared ? incrementCurrent : 0;
    } else if (deltaCurrent != null && deltaAvailable != null) {
      incrementCurrent = deltaCurrent;
      incrementAvailable = deltaAvailable;
    }
    final accountRef = getAccountDocument(account.id);
    await accountRef.update(
      {
        "currentBalance": FieldValue.increment(incrementCurrent),
        "availableBalance": FieldValue.increment(incrementAvailable),
      },
    );
  }

  // TODO: Convert to transaction since reading account balance
  Future<void> updateBalance(Account account, int newBalance) async {
    final int oldBalance = account.currentBalance;

    if (oldBalance == newBalance) return;

    final transactionCol = getTransactionCollection(account.id);

    final unclearedTransactions =
        await transactionCol.where("cleared", isEqualTo: false).get();

    final transactionUpdates = unclearedTransactions.docs.map(
      (transaction) => transaction.reference.update({"cleared": true}),
    );

    await Future.wait(transactionUpdates);

    final int balanceDelta = newBalance - oldBalance;

    final Transaction correction = Transaction(
      name: "Balance Correction",
      amount: balanceDelta.abs(),
      method: balanceDelta > 0
          ? TransactionType.deposit
          : TransactionType.withdrawal,
      timestamp: DateTime.now(),
      cleared: true,
      memo: "System Generated",
    );

    // Add the new correction transaction to the transactions of the account
    await transactionCol.add(correction);
    await incrementBalance(account, transaction: correction);
  }

  Future<void> addTransaction(Account account, Transaction transaction) async {
    final transactionCol = getTransactionCollection(account.id);

    await transactionCol.add(transaction);
    await incrementBalance(account, transaction: transaction);
  }

  Future<void> deleteTransaction(
    Account account,
    Transaction transaction,
  ) async {
    final transactionRef = getTransactionDocument(account.id, transaction.id);

    final int oldCurrDelta = -transaction.amount *
        (transaction.method == TransactionType.deposit ? 1 : -1);
    final int oldAvailDelta = transaction.cleared ? oldCurrDelta : 0;

    await transactionRef.delete();
    transaction.method = transaction.method == TransactionType.deposit
        ? TransactionType.withdrawal
        : TransactionType.deposit;

    // transaction.cleared = !transaction.cleared;
    await incrementBalance(
      account,
      deltaCurrent: oldCurrDelta,
      deltaAvailable: oldAvailDelta,
    );
  }

  Future<void> updateTransaction(
    Account account,
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    final transactionRef =
        getTransactionDocument(account.id, oldTransaction.id);

    final int oldCurrDelta = -oldTransaction.amount *
        (oldTransaction.method == TransactionType.deposit ? 1 : -1);
    final int oldAvailDelta = oldTransaction.cleared ? oldCurrDelta : 0;

    final int newCurrDelta = newTransaction.amount *
        (newTransaction.method == TransactionType.deposit ? 1 : -1);
    final int newAvailDelta = newTransaction.cleared ? newCurrDelta : 0;

    await incrementBalance(
      account,
      deltaCurrent: newCurrDelta + oldCurrDelta,
      deltaAvailable: newAvailDelta + oldAvailDelta,
    );

    await transactionRef.set(newTransaction);
  }

  Future<void> clearTransaction(
    Account account,
    Transaction transaction,
  ) async {
    final transactionRef = getTransactionDocument(account.id, transaction.id);
    transaction.cleared = true;
    await transactionRef.set(transaction);

    final int availDelta = transaction.amount *
        (transaction.method == TransactionType.deposit ? 1 : -1);
    await incrementBalance(
      account,
      deltaCurrent: 0,
      deltaAvailable: availDelta,
    );
  }

  Future<void> transferTransaction(
    Account fromAccount,
    Account toAccount,
    Transaction transaction,
  ) async {
    try {
      // Get a reference to the old transaction doc
      final oldTransactionDoc = getTransactionDocument(
        fromAccount.id,
        transaction.id,
      );

      // Get reference to the new transaction's parent collection
      final newTransactionCol = getTransactionCollection(toAccount.id);

      // Batch write and delete to transfer the tranaction
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set<Transaction>(newTransactionCol.doc(), transaction);
      batch.delete(oldTransactionDoc);

      // Commit the changes
      return batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferFunds(
    Account fromAccount,
    Account toAccount,
    int transferAmount,
  ) async {
    final fromAccountTransactions = getTransactionCollection(fromAccount.id);

    final toAccountTransactions = getTransactionCollection(toAccount.id);

    final Transaction transaction = Transaction(
      name: "Transfer To ${toAccount.name}",
      amount: transferAmount,
      timestamp: DateTime.now(),
      cleared: true,
      memo: "SYSTEM GENERATED",
    );

    final WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set<Transaction>(fromAccountTransactions.doc(), transaction);
    // Create and write the toTransaction
    transaction.name = "Transfer From ${fromAccount.name}";
    transaction.method = TransactionType.deposit;
    batch.set<Transaction>(toAccountTransactions.doc(), transaction);

    return batch.commit();
  }

  Future<void> importCSV(File csv) async {
    /*
    final lines = await file.readAsLines();

                  final List<String> headers = lines[0].split(",");
                  lines.removeAt(0);

                  final Map<String, int> headerIndex = headers
                      .asMap()
                      .map<String, int>((key, value) => MapEntry(value, key));

                  final Map<String, List<Transaction>> accounts = {};

                  for (final String line in lines) {
                    final entries = line.split(",");
                    final Transaction transaction = Transaction(
                      name: entries[headerIndex["Transaction_Name"]!],
                      amount: int.parse(entries[headerIndex["Amount"]!]),
                      checkNumber: int.parse(entries[headerIndex["Check_No"]!]),
                      cleared:
                          entries[headerIndex["Has_Cleared"]!].toLowerCase() ==
                              "true",
                      method: entries[headerIndex["Transaction_Type"]!]
                                  .toLowerCase() ==
                              "true"
                          ? TransactionType.deposit
                          : TransactionType.withdrawal,
                      timestamp: DateTime.fromMillisecondsSinceEpoch(
                        int.parse(entries[headerIndex["Creation_Date"]!]),
                      ),
                      hidden:
                          entries[headerIndex["Is_Hidden"]!].toLowerCase() ==
                              "true",
                      memo: entries[headerIndex["Memo"]!],
                    );

                    final list = accounts.putIfAbsent(
                      entries[headerIndex["Account_Name"]!],
                      () => [],
                    );
                    list.add(transaction);
                  }

                  // Initialize Firebase variables
                  DataProvider dataProvider = context.read<DataProvider>();
                  var _accountsCollection =
                      dataProvider.getAccountsCollection();

                  for (String key in accounts.keys) {
                    Account newAccount = Account(name: key);
                    var accountRef = await _accountsCollection.add(newAccount);
                    List<Transaction> transactions = accounts[key]!;
                    List<List<Transaction>> sublists = [];
                    for (int i = 0; i < transactions.length; i += 499) {
                      sublists.add(transactions.sublist(
                          i,
                          i + 499 > transactions.length
                              ? transactions.length
                              : i + 499));
                    }
                    var transactionRef =
                        dataProvider.getTransactionCollection(accountRef.id);
                    List<WriteBatch> batches = [];
                    for (var list in sublists) {
                      WriteBatch batch = FirebaseFirestore.instance.batch();
                      for (var t in list)
                        batch.set<Transaction>(transactionRef.doc(), t);
                      batches.add(batch);
                    }
                    await Future.wait(batches.map((e) => e.commit()));
                  }*/
  }
}
