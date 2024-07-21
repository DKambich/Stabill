import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart'
    show
        CollectionReference,
        DocumentReference,
        FieldValue,
        FirebaseFirestore,
        Query,
        QuerySnapshot,
        WriteBatch;
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/scheduled_transaction.dart';
import 'package:stabill/models/transaction.dart';

class DataProvider {
  final FirebaseFirestore firebaseFirestore;
  final User? user;

  static const String userCol = "users";
  static const String accountCol = "accounts";
  static const String transactionCol = "transactions";
  static const String scheduledCol = "scheduledTransactions";

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

  Query<ScheduledTransaction> getScheduledTransactionCollectionGroup() {
    return firebaseFirestore
        .collectionGroup(scheduledCol)
        .where("uid", isEqualTo: user!.uid)
        .withConverter<ScheduledTransaction>(
          fromFirestore: (snapshot, _) => ScheduledTransaction.fromJson(
            snapshot.data()!,
            snapshot.id,
            snapshot.reference.parent.parent!.id,
          ),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  CollectionReference<ScheduledTransaction> getScheduledTransactionCollection(
    String accountID,
  ) {
    return getAccountDocument(accountID)
        .collection(scheduledCol)
        .withConverter<ScheduledTransaction>(
          fromFirestore: (snapshot, _) => ScheduledTransaction.fromJson(
            snapshot.data()!,
            snapshot.id,
            snapshot.reference.parent.parent!.id,
          ),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  DocumentReference<ScheduledTransaction> getScheduledTransactionDocument(
    String accountID,
    String scheduledTransactionID,
  ) {
    return getScheduledTransactionCollection(accountID)
        .doc(scheduledTransactionID);
  }

  Future<ScheduledTransaction> getScheduledTransaction(
    String accountID,
    String scheduledTransactionID,
  ) async {
    return (await getScheduledTransactionDocument(
      accountID,
      scheduledTransactionID,
    ).get())
        .data()!;
  }

  // Account Methods

  Future<String> createAccount(Account account, int startingBalance) async {
    try {
      // Add the new account to the collection
      final accountRef = await getAccountsCollection().add(account);
      account.id = accountRef.id;

      // Don't create a starting transaction if there is no balance
      if (startingBalance == 0) return accountRef.id;

      // Create a transaction as the starting balance for the account
      final Transaction startingTransaction = Transaction(
        name: "Starting Balance",
        amount: startingBalance,
        timestamp: DateTime.now(),
        cleared: true,
        method: TransactionType.deposit,
        memo: "System Generated",
      );

      // Add the new Transaction to the Account
      await addTransaction(account, startingTransaction);

      // Return the account id
      return accountRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      // Get the Account document and update the Account
      await getAccountDocument(account.id).set(account);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAccount(Account account) async {
    try {
      // Get the Account document and delete the Account
      await getAccountDocument(account.id).delete();
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

  // TODO: Convert to Firestore transaction since reading account balance
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

  Future<bool> transferFunds(
    Account fromAccount,
    Account toAccount,
    int transferAmount,
  ) async {
    try {
      // Create a withdrawal Transaction
      final Transaction transaction = Transaction(
        name: "Transfer To ${toAccount.name}",
        amount: transferAmount,
        timestamp: DateTime.now(),
        cleared: true,
        memo: "System Generated",
      );

      // Add the withdrawal Transaction to the from Account
      await addTransaction(fromAccount, transaction);

      // Modify the Transaction to be identical but a deposit from the from Account
      transaction.name = "Transfer From ${fromAccount.name}";
      transaction.method = TransactionType.deposit;

      // Add the deposit Transasction to the to Account
      await addTransaction(toAccount, transaction);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> importCSV(File csv) async {
    try {
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
          checkNumber: checkNumber,
          cleared: cleared,
          timestamp: timestamp,
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

      for (final MapEntry<String, List<Transaction>> entry
          in accounts.entries) {
        // Add the newAccount to the database
        final Account newAccount = Account(name: entry.key);
        final String accountID = await createAccount(newAccount, 0);
        newAccount.id = accountID;

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
    } catch (e) {
      rethrow;
    }
  }

  Future<String> exportCSV() async {
    // Store the CSV headers
    const List<String> csvHeaders = [
      "AccountID",
      "Account_Name",
      "Transaction_Name",
      "Amount",
      "Check_No",
      "Has_Cleared",
      "Transaction_Type",
      "Creation_Date",
      "Is_Hidden",
      "Memo",
    ];

    // Create a list to store the rows of the CSV
    final List<List<dynamic>> csvList = [csvHeaders];

    // Get and loop through the list of accounts
    final QuerySnapshot<Account> accounts = await getAccountsCollection().get();
    for (final accountSnapshot in accounts.docs) {
      final Account account = accountSnapshot.data();

      // Get a loop through the list of transactions of the current account
      final QuerySnapshot<Transaction> transactions =
          await getTransactionCollection(account.id).orderBy("timestamp").get();
      for (final transactionSnapshot in transactions.docs) {
        final Transaction transaction = transactionSnapshot.data();
        // Add a row in the CSV for the current transaction
        csvList.add([
          account.id,
          account.name,
          transaction.name,
          transaction.amount,
          transaction.checkNumber,
          transaction.cleared.toString().toUpperCase(),
          // ignore: prefer_if_elements_to_conditional_expressions
          transaction.method == TransactionType.deposit ? "TRUE" : "FALSE",
          transaction.timestamp.millisecondsSinceEpoch,
          transaction.hidden.toString().toUpperCase(),
          transaction.memo,
        ]);
      }
    }

    return const ListToCsvConverter().convert(csvList);
  }

  // Transaction Methods

  Future<void> addTransaction(Account account, Transaction transaction) async {
    try {
      // Add the Transaction to the Account
      await getTransactionCollection(account.id).add(transaction);

      // Update the balance of the Account
      await incrementBalance(account, transaction: transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(
    Account account,
    Transaction oldTransaction,
    Transaction newTransaction,
  ) async {
    try {
      // Calculate the current and available delta of the old and new Transactions
      final int oldCurrDelta = -oldTransaction.amount *
          (oldTransaction.method == TransactionType.deposit ? 1 : -1);
      final int oldAvailDelta = oldTransaction.cleared ? oldCurrDelta : 0;

      final int newCurrDelta = newTransaction.amount *
          (newTransaction.method == TransactionType.deposit ? 1 : -1);
      final int newAvailDelta = newTransaction.cleared ? newCurrDelta : 0;

      // Update the Transaction
      await getTransactionDocument(account.id, oldTransaction.id)
          .set(newTransaction);

      // Update the balance of the Account
      await incrementBalance(
        account,
        deltaCurrent: newCurrDelta + oldCurrDelta,
        deltaAvailable: newAvailDelta + oldAvailDelta,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(
    Account account,
    Transaction transaction,
  ) async {
    try {
      // Calculate the current and available delta of the Transaction
      final int oldCurrDelta = -transaction.amount *
          (transaction.method == TransactionType.deposit ? 1 : -1);
      final int oldAvailDelta = transaction.cleared ? oldCurrDelta : 0;

      // Delete the Transaction
      await getTransactionDocument(account.id, transaction.id).delete();

      // Update the balance of the Account
      await incrementBalance(
        account,
        deltaCurrent: oldCurrDelta,
        deltaAvailable: oldAvailDelta,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearTransaction(
    Account account,
    Transaction transaction,
  ) async {
    try {
      // Calculate the available delta of the Transaction and clear it
      final int availDelta = transaction.amount *
          (transaction.method == TransactionType.deposit ? 1 : -1);
      transaction.cleared = true;

      // Update the Transaction
      await getTransactionDocument(account.id, transaction.id).set(transaction);

      // Update the balance of the Account
      await incrementBalance(
        account,
        deltaCurrent: 0,
        deltaAvailable: availDelta,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> transferTransaction(
    Account fromAccount,
    Account toAccount,
    Transaction transaction,
  ) async {
    try {
      // Add the Transaction to the new Account
      await addTransaction(toAccount, transaction);

      // Delete the Transaction from the old Account
      await deleteTransaction(fromAccount, transaction);
    } catch (e) {
      rethrow;
    }
  }

  // ScheduledTransaction Methods

  Future<void> addScheduledTransaction(ScheduledTransaction transaction) async {
    try {
      // Add the ScheduledTransaction to the Account
      await getScheduledTransactionCollection(transaction.accountID)
          .add(transaction);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateScheduledTransaction(
    ScheduledTransaction oldTransaction,
    ScheduledTransaction newTransaction,
  ) async {
    try {
      // If the ScheduledTransaction is for a new account
      if (oldTransaction.accountID != newTransaction.accountID) {
        // Delete the ScheduledTransaction from the old account
        await getScheduledTransactionCollection(oldTransaction.accountID)
            .doc(oldTransaction.id)
            .delete();

        // Add the new ScheduledTransaction to the new account
        await getScheduledTransactionCollection(newTransaction.accountID)
            .add(newTransaction);
      } else {
        // Otherwise, overwrite the old ScheduledTransaction with the new one
        await getScheduledTransactionDocument(
          oldTransaction.accountID,
          oldTransaction.id,
        ).set(newTransaction);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteScheduledTransaction(
    ScheduledTransaction transaction,
  ) async {
    try {
      // Delete the ScheduledTransaction to the corresponding account
      await getScheduledTransactionCollection(transaction.accountID)
          .doc(transaction.id)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}
