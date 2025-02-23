import 'dart:async';

import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';

class MockDatabaseRepository implements AbstractDatabaseRepository {
  final List<Account> _accounts = [];

  @override
  Future<Account> createAccount(String accountName, int startingBalance) {
    // TODO: implement createAccount
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAccount(String accountId) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Account> getAccount() {
    // TODO: implement getAccount
    throw UnimplementedError();
  }

  @override
  Future<List<Account>> getAccounts() {
    // TODO: implement getAccounts
    throw UnimplementedError();
  }
}
