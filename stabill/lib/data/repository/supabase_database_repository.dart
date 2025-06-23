// lib/repositories/supabase_database_service.dart

import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/auth_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/data/models/transaction_type.dart';
import 'package:stabill/data/stored_procedures/create_account_procedure.dart';
import 'package:stabill/data/tables/accounts_table.dart';
import 'package:stabill/data/tables/transactions_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'abstract_database_repository.dart';

class SupabaseDatabaseRepository implements AbstractDatabaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AbstractAuthService _authService = AuthService.instance;

  @override
  Future<Account> createAccount({
    required String accountName,
    required int startingBalance,
  }) async {
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
  Future<Transaction> createTransaction({
    required String accountId,
    required String name,
    required int amount,
    required DateTime transactionDate,
    required TransactionType transactionType,
    int? checkNumber,
    String? memo,
    required bool isCleared,
  }) async {
    final createdTransaction = await _supabase
        .from(TransactionsTable.tableName)
        .insert({
          TransactionsTable.accountId: accountId,
          TransactionsTable.name: name,
          TransactionsTable.amount: amount,
          TransactionsTable.transactionDate: transactionDate.toIso8601String(),
          TransactionsTable.transactionType: transactionType,
          TransactionsTable.checkNumber: checkNumber,
          TransactionsTable.memo: memo,
          TransactionsTable.isCleared: isCleared,
        })
        .select()
        .single();

    return Transaction.fromJson(createdTransaction);
  }

  @override
  Future<void> deleteAccount(String accountId) {
    // TODO: implement deleteAccount
    throw UnimplementedError();
  }

  @override
  Future<Account> getAccount(String accountId) async {
    return Account.fromJson(
      await _supabase
          .from(AccountsTable.tableName)
          .select()
          .eq(AccountsTable.id, accountId)
          .single(),
    );
  }

  @override
  Stream<Account> getAccountAsStream(String accountId) {
    return _supabase
        .from(AccountsTable.tableName)
        .stream(primaryKey: [AccountsTable.id])
        .eq(AccountsTable.id, accountId)
        .map<Account>(
          (accountRecords) => Account.fromJson(accountRecords.first),
        );
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

  @override
  Future<Transaction> getTransaction(String transactionId) async {
    return Transaction.fromJson(
      await _supabase
          .from(TransactionsTable.tableName)
          .select()
          .eq(TransactionsTable.id, transactionId)
          .single(),
    );
  }

  @override
  Function getTransactionChanges(
    String accountId, {
    Function(Transaction)? onInsert,
    Function(Transaction, Transaction)? onUpdate,
    Function(Transaction)? onDelete,
  }) {
    var transactionChannel = _supabase.channel("transaction-table-changes");

    if (onInsert != null) {
      transactionChannel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: TransactionsTable.tableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: TransactionsTable.accountId,
          value: accountId,
        ),
        callback: (change) => onInsert(Transaction.fromJson(change.newRecord)),
      );
    }

    if (onUpdate != null) {
      transactionChannel.onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: TransactionsTable.tableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: TransactionsTable.accountId,
          value: accountId,
        ),
        callback: (change) => onUpdate(
          Transaction.fromJson(change.oldRecord),
          Transaction.fromJson(change.newRecord),
        ),
      );
    }
    if (onDelete != null) {
      transactionChannel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: TransactionsTable.tableName,
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: TransactionsTable.accountId,
          value: accountId,
        ),
        callback: (change) => onDelete(Transaction.fromJson(change.oldRecord)),
      );
    }

    return transactionChannel.subscribe().unsubscribe;
  }

  @override
  Future<List<Transaction>> getTransactions(String accountId) async {
    // TODO: Implement pagination
    var transactions = await _supabase
        .from(TransactionsTable.tableName)
        .select()
        .eq(TransactionsTable.accountId, accountId);

    return transactions.map(Transaction.fromJson).toList();
  }

  String _getUserId() {
    final user = _authService.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('User is not authenticated');
    }
    return user.id;
  }
}
