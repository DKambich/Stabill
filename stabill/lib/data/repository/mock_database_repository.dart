import 'dart:async';

import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';

class MockDatabaseRepository implements AbstractDatabaseRepository {
  final List<Account> _accounts = [];

  @override
  Future<Account> createAccount(String accountName, int startingBalance) async {
    var newAccount = Account(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Utilize a date-based uid, good enough for a mock, potentially use the uuid package if a better id is needed
      name: accountName,
      currentBalance: startingBalance,
      availableBalance: startingBalance,
      createdAt: DateTime.now(),
      archived: false,
    );

    // TODO: Add a related transaction to the list of transactions

    _accounts.add(newAccount);

    return newAccount;
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    _accounts.removeWhere((account) => account.id == accountId);
  }

  @override
  Future<Account> getAccount(String accountId) async {
    var account = _accounts.firstWhere((account) => account.id == accountId);
    return account;
  }

  @override
  Future<List<Account>> getAccounts() async {
    return [..._accounts];
  }
}
