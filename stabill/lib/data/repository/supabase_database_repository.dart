// lib/repositories/supabase_database_service.dart
import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/auth_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'abstract_database_repository.dart';

class SupabaseDatabaseRepository implements AbstractDatabaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AbstractAuthService _authService = AuthService.instance;

  @override
  Future<Account> createAccount(String accountName, int startingBalance) async {
    final user = _authService.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('User is not authenticated');
    }

    try {
      // TODO: This should create a transaction instead of setting current and available balance
      final response = await _supabase
          .from('accounts')
          .insert({
            'user_id': user.id,
            'name': accountName,
            'current_balance': startingBalance,
            'available_balance': startingBalance,
            'is_archived': false,
          })
          .select()
          .single();

      return Account.fromJson(response);
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
