import 'package:stabill/data/models/account.dart';

abstract class AbstractDatabaseRepository {
  Future<Account> createAccount(String accountName, int startingBalance);
  Future<void> deleteAccount(String accountId);
  Future<Account> getAccount(String accountId);
  Stream<List<Account>> getAccountsStream();
}
