// lib/repositories/supabase_database_service.dart

import 'package:stabill/core/services/auth/abstract_auth_service.dart';
import 'package:stabill/core/services/auth/auth_service.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/data/stored_procedures/create_account_procedure.dart';
import 'package:stabill/data/tables/accounts_table.dart';
import 'package:stabill/data/tables/transactions_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'abstract_database_repository.dart';

class SupabaseDatabaseRepository implements AbstractDatabaseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final AbstractAuthService _authService = AuthService.instance;
  @override
  Future<Account> createAccount(Account account) async {
    var userId = _getUserId();
    try {
      final createdAccount = await _supabase.rpc<Map<String, dynamic>>(
        CreateAccountProcedure.procedureName,
        params: CreateAccountProcedure.createParams(
          userId,
          account.name,
          account.balance?.current ?? 0,
        ),
      );
      return Account.fromJson(createdAccount);
    } on PostgrestException {
      rethrow;
    }
  }

  @override
  Future<Transaction> createTransaction(
      Transaction transaction, String accountId) async {
    final createdTransaction = await _supabase
        .from(TransactionsTable.tableName)
        .insert({
          TransactionsTable.accountId: accountId,
          TransactionsTable.name: transaction.name,
          TransactionsTable.amount: transaction.amount,
          TransactionsTable.transactionDate:
              transaction.transactionDate.toIso8601String(),
          TransactionsTable.transactionType:
              transaction.transactionType.toJson(),
          TransactionsTable.transactionCategory: transaction.category.toJson(),
          TransactionsTable.checkNumber: transaction.checkNumber,
          TransactionsTable.memo: transaction.memo,
          TransactionsTable.isCleared: transaction.isCleared,
          TransactionsTable.isArchived: transaction.isArchived,
        })
        .select()
        .single();
    return Transaction.fromJson(createdTransaction);
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    if (accountId.isEmpty) {
      throw ArgumentError('Cannot delete an account without an id');
    }
    // TODO: implement actual delete logic
    throw UnimplementedError();
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    if (transactionId.isEmpty) {
      throw ArgumentError('Cannot delete a transaction without an id');
    }
    await _supabase
        .from(TransactionsTable.tableName)
        .delete()
        .eq(TransactionsTable.id, transactionId);
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

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('Cannot update a transaction without an id');
    }
    final updated = await _supabase
        .from(TransactionsTable.tableName)
        .update(transaction.toJson())
        .eq(TransactionsTable.id, transaction.id!)
        .select()
        .single();
    return Transaction.fromJson(updated);
  }

  String _getUserId() {
    final user = _authService.currentUser;
    if (user == null || user.id.isEmpty) {
      throw Exception('User is not authenticated');
    }
    return user.id;
  }
}
