import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'
    show
        CollectionReference,
        DocumentReference,
        FieldValue,
        FirebaseFirestore,
        Query,
        WriteBatch;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/recurring_transaction.dart';
import 'package:stabill/models/transaction.dart';

class DataProvider {
  final FirebaseFirestore firebaseFirestore;
  final User? user;

  static const String userCol = "users";
  static const String accountCol = "accounts";
  static const String transactionCol = "transactions";
  static const String recurringCol = "recurringTransactions";

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

  Query<RecurringTransaction> getRecurringTransactionCollectionGroup() {
    return firebaseFirestore
        .collectionGroup(recurringCol)
        .withConverter<RecurringTransaction>(
          fromFirestore: (snapshot, _) => RecurringTransaction.fromJson(
            snapshot.data()!,
          ),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  CollectionReference<RecurringTransaction> getRecurringTransactionCollection(
      String accountID) {
    return getAccountDocument(accountID)
        .collection(recurringCol)
        .withConverter<RecurringTransaction>(
          fromFirestore: (snapshot, _) => RecurringTransaction.fromJson(
            snapshot.data()!,
          ),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  DocumentReference<RecurringTransaction> getRecurringTransactionDocument(
    String accountID,
    String recurringTransactionID,
  ) {
    return getRecurringTransactionCollection(accountID)
        .doc(recurringTransactionID);
  }

  Future<RecurringTransaction> getRecurringTransaction(
    String accountID,
    String recurringTransactionID,
  ) async {
    return (await getRecurringTransactionDocument(
      accountID,
      recurringTransactionID,
    ).get())
        .data()!;
  }

  Future<Account> createAccount(Account account, int startingBalance) async {
    try {
      // Add the new account to the collection
      final accountRef = await getAccountsCollection().add(account);
      account.id = accountRef.id;

      // Don't create a starting transaction if there is no balance
      if (startingBalance == 0) return account;

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

      await incrementBalance(account, transaction: startingTransaction);

      return account;
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
      // Add the transaction to the new account
      await addTransaction(toAccount, transaction);

      // Delete the transaction from the old account
      await deleteTransaction(fromAccount, transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferFunds(
    Account fromAccount,
    Account toAccount,
    int transferAmount,
  ) async {
    // Create a withdrawal transaction
    final Transaction transaction = Transaction(
      name: "Transfer To ${toAccount.name}",
      amount: transferAmount,
      timestamp: DateTime.now(),
      cleared: true,
      memo: "System Generated",
    );

    // Add the withdrawal transaction to the from account
    await addTransaction(fromAccount, transaction);

    // Modify the transaction to be identical but a deposit from the from account
    transaction.name = "Transfer From ${fromAccount.name}";
    transaction.method = TransactionType.deposit;

    // Add the deposit transasction to the to account
    await addTransaction(toAccount, transaction);
  }

  Future<void> importCSV(File csv) async {
    // Splite the CSV by newline
    final List<String> lines = await csv.readAsLines();

    // Obtain the CSV headers and remove them from the data
    final List<String> headers = lines[0].split(",");
    lines.removeAt(0);

    // Create an index map that maps a header to its column index
    final Map<String, int> headerIndex = headers
        .asMap()
        .map<String, int>((index, header) => MapEntry(header, index));

    // Create a map that maps an account name to a list of transactions
    final Map<String, List<Transaction>> accounts = {};

    // Create a transaction for each line
    for (final String line in lines) {
      // Obtain the information for each transaction
      final List<String> entries = line.split(",");
      final String name = entries[headerIndex["Transaction_Name"]!];
      final int amount = int.parse(entries[headerIndex["Amount"]!]);
      final TransactionType method =
          entries[headerIndex["Transaction_Type"]!].toLowerCase() == "true"
              ? TransactionType.deposit
              : TransactionType.withdrawal;
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.parse(entries[headerIndex["Creation_Date"]!]),
      );
      final int checkNumber = int.parse(entries[headerIndex["Check_No"]!]);
      final bool cleared =
          entries[headerIndex["Has_Cleared"]!].toLowerCase() == "true";
      final bool hidden =
          entries[headerIndex["Is_Hidden"]!].toLowerCase() == "true";
      final String memo = entries[headerIndex["Memo"]!];

      final Transaction transaction = Transaction(
        name: name,
        amount: amount,
        timestamp: timestamp,
        checkNumber: checkNumber,
        cleared: cleared,
        method: method,
        memo: memo,
        hidden: hidden,
      );

      // Add the transaction to it's corresponding list
      accounts
          .putIfAbsent(
            entries[headerIndex["Account_Name"]!],
            () => [],
          )
          .add(transaction);
    }

    for (final MapEntry<String, List<Transaction>> entry in accounts.entries) {
      // Add the newAccount to the database
      Account newAccount = Account(name: entry.key);
      newAccount = await createAccount(newAccount, 0);

      // Calculate the current and avaialable balances
      int currentBalance = 0;
      int availableBalance = 0;
      for (final Transaction transaction in entry.value) {
        final int currentDelta = transaction.amount *
            (transaction.method == TransactionType.deposit ? 1 : -1);
        final int availDelta = transaction.cleared ? currentDelta : 0;
        currentBalance += currentDelta;
        availableBalance += availDelta;
      }

      // Create sublists of Transactions to write as WriteBatch is limited to 500 documents
      final List<List<Transaction>> sublists = [];
      for (int i = 0; i < entry.value.length; i += 500) {
        sublists.add(
          entry.value.sublist(
            i,
            i + 500 > entry.value.length ? entry.value.length : i + 500,
          ),
        );
      }

      // Create a list of WriteBatches from each sublist
      final transactionCol = getTransactionCollection(newAccount.id);
      final List<WriteBatch> batches = [];
      for (final List<Transaction> sublist in sublists) {
        final WriteBatch batch = firebaseFirestore.batch();
        // Create a document for each transaction in the sublist
        for (final Transaction transaction in sublist) {
          batch.set<Transaction>(transactionCol.doc(), transaction);
        }
        batches.add(batch);
      }

      // Commit each BatchWrites changes
      await Future.wait(batches.map((batch) => batch.commit()));

      // Update the balance of the new account
      await incrementBalance(
        newAccount,
        deltaCurrent: currentBalance,
        deltaAvailable: availableBalance,
      );
    }
  }
}
