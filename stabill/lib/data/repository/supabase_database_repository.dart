// lib/repositories/supabase_database_service.dart

import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/auth_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/stored_procedures/create_account_procedure.dart';
import 'package:stabill/data/tables/accounts_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'abstract_database_repository.dart';

class SupabaseDatabaseRepository implements AbstractDatabaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AbstractAuthService _authService = AuthService.instance;

  @override
  Future<Account> createAccount(String accountName, int startingBalance) async {
    var userId = _getUserId();
    try {
      final createdAccount = await _supabase.rpc<Map<String, dynamic>>(
        CreateAccountProcedure.procedureName,
        params: CreateAccountProcedure.createParams(
          userId,
          accountName,
          startingBalance,
        ),
      );

      return Account.fromJson(createdAccount);
    } on PostgrestException {
      rethrow;
    }
  }

  @override
  Future<void> deleteAccount(String accountId) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Account> getAccount(String accountId) {
    // TODO: implement getAccount
    throw UnimplementedError();
  }

  @override
  Stream<List<Account>> getAccountsStream() {
    // TODO: On web, this is giving DartError: TypeError: Instance of 'JSArray<dynamic>': type 'List<dynamic>' is not a subtype of type 'List<Map<String, dynamic>>'
    return _supabase
        .from(AccountsTable.tableName)
        .stream(primaryKey: [AccountsTable.id])
        .eq(AccountsTable.userId, _getUserId())
        .map(
          (accountRecords) => accountRecords.map(Account.fromJson).toList(),
        );
  }

  String _getUserId() {
    final user = _authService.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('User is not authenticated');
    }
    return user.id;
  }
}
