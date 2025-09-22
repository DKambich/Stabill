import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';

class MockDatabaseRepository implements AbstractDatabaseRepository {
  final List<Account> _accounts = [];
  final Map<String, List<Transaction>> _transactions = {};

  @override
  Future<Account> createAccount(Account account) async {
    var newAccount = Account(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Utilize a date-based uid, good enough for a mock, potentially use the uuid package if a better id is needed
      name: account.name,
      balance: Balance(
          current: account.balance?.current ?? 0,
          available: account.balance?.current ?? 0),
      createdAt: DateTime.now(),
      isArchived: false,
    );

    // TODO: Add a related transaction to the list of transactions

    _accounts.add(newAccount);

    _transactions[newAccount.id ?? ''] = [];

    return newAccount;
  }

  @override
  Future<Transaction> createTransaction(
      Transaction transaction, String accountId) async {
    var createdTransaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: transaction.name,
        createdAt: DateTime.now(),
        amount: transaction.amount,
        transactionDate: transaction.transactionDate,
        transactionType: transaction.transactionType,
        category: transaction.category,
        checkNumber: transaction.checkNumber,
        memo: transaction.memo,
        isCleared: transaction.isCleared,
        isArchived: false);

    _transactions[accountId]?.add(createdTransaction);
    return createdTransaction;
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    _accounts.removeWhere((account) => account.id == accountId);
  }

  @override
  Future<void> deleteTransaction(String transactionId) {
    // TODO: implement deleteTransaction
    throw UnimplementedError();
  }

  @override
  Future<Account> getAccount(String accountId) async {
    var account = _accounts.firstWhere((account) => account.id == accountId);
    return account;
  }

  @override
  Stream<Account> getAccountAsStream(String accountId) {
    // TODO: implement getAccountAsStream
    throw UnimplementedError();
  }

  @override
  Stream<List<Account>> getAccountsStream() {
    return Stream.value([..._accounts]);
  }

  @override
  Future<Transaction> getTransaction(String transactionId) {
    // TODO: implement getTransaction
    throw UnimplementedError();
  }

  @override
  Function getTransactionChanges(String accountId,
      {Function(Transaction p1)? onInsert,
      Function(Transaction p1, Transaction p2)? onUpdate,
      Function(Transaction p1)? onDelete}) {
    // TODO: implement getTransactionChanges
    throw UnimplementedError();
  }

  @override
  Future<List<Transaction>> getTransactions(String accountId) {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) {
    // TODO: implement updateTransaction
    throw UnimplementedError();
  }
}
