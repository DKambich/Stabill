import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/transaction.dart';

abstract class AbstractDatabaseRepository {
  Future<Account> createAccount(Account account);
  Future<Transaction> createTransaction(
      Transaction transaction, String accountId);
  Future<void> deleteAccount(String accountId);
  Future<void> deleteTransaction(String transactionId);
  Future<Account> getAccount(String accountId);
  Stream<Account> getAccountAsStream(String accountId);
  Stream<List<Account>> getAccountsStream();

  Future<Transaction> getTransaction(String transactionId);
  // TODO: Change this, maybe return the unsubscribe function to be called?
  Function getTransactionChanges(
    String accountId, {
    Function(Transaction)? onInsert,
    Function(Transaction, Transaction)? onUpdate,
    Function(Transaction)? onDelete,
  });

  Future<List<Transaction>> getTransactions(String accountId);
  Future<Transaction> updateTransaction(Transaction transaction);
}
