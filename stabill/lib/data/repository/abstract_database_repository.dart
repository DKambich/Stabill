import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/data/models/transaction_type.dart';

abstract class AbstractDatabaseRepository {
  Future<Account> createAccount({
    required String accountName,
    required int startingBalance,
  });
  Future<Transaction> createTransaction({
    required String accountId,
    required String name,
    required int amount,
    required DateTime transactionDate,
    required TransactionType transactionType,
    int? checkNumber,
    String? memo,
    required bool isCleared,
  });
  Future<void> deleteAccount(String accountId);
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
}
