import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, CollectionReference, DocumentReference, WriteBatch;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stabill/models/account.dart';
import 'package:stabill/models/transaction.dart';

class DataProvider {
  final FirebaseFirestore firebaseFirestore;
  final User? user;

  static const String userCol = "users",
      accountCol = "accounts",
      transactionCol = "transactions";

  DataProvider(this.firebaseFirestore, this.user);

  CollectionReference<Account> getAccountsCollection() {
    if (user == null) throw Exception("User is not signed in");
    String uid = user!.uid;
    return firebaseFirestore
        .collection(userCol)
        .doc(uid)
        .collection(accountCol)
        .withConverter<Account>(
          fromFirestore: (snapshot, _) => Account.fromJson(snapshot.data()!),
          toFirestore: (account, _) => account.toJson(),
        );
  }

  DocumentReference<Account> getAccountDocument(String accountID) {
    return getAccountsCollection().doc(accountID);
  }

  CollectionReference<Transaction> getTransactionCollection(String accountID) {
    return getAccountDocument(accountID)
        .collection(transactionCol)
        .withConverter<Transaction>(
          fromFirestore: (snapshot, _) =>
              Transaction.fromJson(snapshot.data()!),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
  }

  DocumentReference<Transaction> getTransactionDocument(
    String accountID,
    String transactionID,
  ) {
    return getTransactionCollection(accountID).doc(transactionID);
  }

  Future<void> createAccount(Account account, int startingBalance) async {
    try {
      // Add the new account to the collection
      var accountRef = await getAccountsCollection().add(account);

      // Don't create a starting transaction if there is no balance
      if (startingBalance == 0) return;

      // Create a transaction as the starting balance for the account
      Transaction startingTransaction = Transaction(
        name: "Starting Balance",
        amount: startingBalance,
        timestamp: DateTime.now(),
        cleared: true,
        method: TransactionType.Deposit,
        memo: "System Generated",
      );

      // Add the new transaction to the collection
      await getTransactionCollection(accountRef.id).add(startingTransaction);
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateAccount(String accountID, String newName) async {
    try {
      // Get the account document
      var accountDoc = getAccountDocument(accountID);
      // Get the Account and set the new name
      Account updatedAccount = (await accountDoc.get()).data()!;
      updatedAccount.name = newName;
      // Update the Account
      await accountDoc.set(updatedAccount);
    } catch (e) {
      throw e;
    }
  }

  Future<void> transferTransaction(
    Transaction transaction,
    String transactionID,
    String fromAccountID,
    String toAccountID,
  ) async {
    try {
      // Get a reference to the old transaction doc
      var oldTransactionDoc = getTransactionDocument(
        fromAccountID,
        transactionID,
      );

      // Get reference to the new transaction's parent collection
      var newTransactionCol = getTransactionCollection(toAccountID);

      // Batch write and delete to transfer the tranaction
      WriteBatch batch = FirebaseFirestore.instance.batch();
      batch.set<Transaction>(newTransactionCol.doc(), transaction);
      batch.delete(oldTransactionDoc);

      // Commit the changes
      return batch.commit();
    } catch (e) {
      throw e;
    }
  }
}
