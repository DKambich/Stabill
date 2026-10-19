import 'package:stabill/data/enums/transaction_category.dart';
import 'package:stabill/data/enums/transaction_type.dart';
import 'package:stabill/data/misc/transaction_change.dart';
import 'package:stabill/data/misc/transaction_query.dart';
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
        accountId: accountId,
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
  Future<List<Account>> getAccounts() async => [..._accounts];

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
  Future<List<Transaction>> getTransactions(
    String accountId, {
    TransactionQuery query = const TransactionQuery(),
  }) {
    // TODO: implement getTransactions
    throw UnimplementedError();
  }

  @override
  Future<void> transferFunds({
    required String fromAccountId,
    required String toAccountId,
    required int amountInCents,
  }) async {
    if (fromAccountId == toAccountId || amountInCents <= 0) {
      throw ArgumentError(
          'A transfer requires two accounts and a positive amount');
    }

    final fromIndex =
        _accounts.indexWhere((account) => account.id == fromAccountId);
    final toIndex =
        _accounts.indexWhere((account) => account.id == toAccountId);
    if (fromIndex == -1 || toIndex == -1) {
      throw ArgumentError('Both transfer accounts must exist');
    }

    final fromAccount = _accounts[fromIndex];
    final toAccount = _accounts[toIndex];
    final now = DateTime.now();
    await createTransaction(
      Transaction(
        name: 'Transfer to ${toAccount.name}',
        amount: amountInCents,
        transactionDate: now,
        transactionType: TransactionType.withdrawal,
        category: TransactionCategory.none,
        isCleared: true,
        isArchived: false,
      ),
      fromAccountId,
    );
    await createTransaction(
      Transaction(
        name: 'Transfer from ${fromAccount.name}',
        amount: amountInCents,
        transactionDate: now,
        transactionType: TransactionType.deposit,
        category: TransactionCategory.none,
        isCleared: true,
        isArchived: false,
      ),
      toAccountId,
    );

    _adjustAccountBalance(fromIndex, -amountInCents);
    _adjustAccountBalance(toIndex, amountInCents);
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) {
    // TODO: implement updateTransaction
    throw UnimplementedError();
  }

  @override
  Stream<TransactionChange> watchTransactions(String accountId) {
    // TODO: implement watchTransactions
    throw UnimplementedError();
  }

  void _adjustAccountBalance(int index, int amountInCents) {
    final account = _accounts[index];
    final balance = account.balance ?? Balance(current: 0, available: 0);
    _accounts[index] = Account(
      id: account.id,
      name: account.name,
      balance: Balance(
        current: balance.current + amountInCents,
        available: balance.available + amountInCents,
      ),
      createdAt: account.createdAt,
      isArchived: account.isArchived,
    );
  }
}
