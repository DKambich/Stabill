import 'package:flutter/material.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';

/// A service responsible for managing user accounts.
class TransactionService {
  final AbstractDatabaseRepository _databaseRepository;

  TransactionService(this._databaseRepository);

  Function getTransactionChanges(
    String accountId, {
    Function(Transaction)? onInsert,
    Function(Transaction, Transaction)? onUpdate,
    Function(Transaction)? onDelete,
  }) {
    return _databaseRepository.getTransactionChanges(
      accountId,
      onInsert: onInsert,
      onUpdate: onUpdate,
      onDelete: onDelete,
    );
  }

  Future<Result<List<Transaction>>> getTransactions(String accountId) async {
    try {
      var transactions = await _databaseRepository.getTransactions(accountId);
      return Result.success(transactions);
    } catch (error, stackTrace) {
      debugPrint("getAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }
}
