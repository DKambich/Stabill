import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseFirestore, CollectionReference;
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

  CollectionReference<Transaction> getTransactionCollection(String accountID) {
    if (user == null) throw Exception("User is not signed in");
    String uid = user!.uid;
    return getAccountsCollection()
        .doc(accountID)
        .collection(transactionCol)
        .withConverter<Transaction>(
          fromFirestore: (snapshot, _) =>
              Transaction.fromJson(snapshot.data()!),
          toFirestore: (transaction, _) => transaction.toJson(),
        );
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

  // Future<String> signUp({String email = "", String password = ""}) async {
  //   try {
  //     await firebaseAuth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return "Signed up!";
  //   } on FirebaseAuthException catch (e) {
  //     return e.message ?? "An exception occured at sign up";
  //   }
  // }

  // Future<String> signIn({String email = "", String password = ""}) async {
  //   try {
  //     await firebaseAuth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     return "Signed in!";
  //   } on FirebaseAuthException catch (e) {
  //     return e.message ?? "An exception occured at sign in";
  //   }
  // }

  // Future<void> signOut() async {
  //   await firebaseAuth.signOut();
  // }
}
