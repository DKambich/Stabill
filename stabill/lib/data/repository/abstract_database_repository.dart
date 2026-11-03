import 'package:stabill/data/misc/transaction_change.dart';
import 'package:stabill/data/misc/transaction_query.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/transaction.dart';

abstract class AbstractDatabaseRepository {
  Future<bool> correctAccountBalance({
    required String accountId,
    required int targetBalanceInCents,
  });
  Future<Account> createAccount(Account account);
  Future<Transaction> createTransaction(
      Transaction transaction, String accountId);
  Future<void> deleteAccount(String accountId);
  Future<void> deleteTransaction(String transactionId);
  Future<Account> getAccount(String accountId);
  Stream<Account> getAccountAsStream(String accountId);
  Future<List<Account>> getAccounts();
  Stream<List<Account>> getAccountsStream();
  Future<Transaction> getTransaction(String transactionId);
  // TODO: Change this, maybe return the unsubscribe function to be called?
  Function getTransactionChanges(
    String accountId, {
    Function(Transaction)? onInsert,
    Function(Transaction, Transaction)? onUpdate,
    Function(Transaction)? onDelete,
  });
  Future<List<Transaction>> getTransactions(
    String accountId, {
    TransactionQuery query = const TransactionQuery(),
  });

  Future<void> reorderAccounts(List<String> accountIds);
  Future<Account> setAccountArchived(String accountId, bool isArchived);
  Future<void> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required int amountInCents,
  });
  Future<Account> updateAccountName(String accountId, String name);
  Future<Transaction> updateTransaction(Transaction transaction);
  Stream<TransactionChange> watchTransactions(String accountId);
}
