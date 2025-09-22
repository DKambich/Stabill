import 'package:flutter/material.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/models/transaction.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';

/// A service responsible for managing user accounts.
class TransactionService {
  final AbstractDatabaseRepository _databaseRepository;
  TransactionService(this._databaseRepository);
  Future<Result<Transaction>> createTransaction(
      Transaction transaction, String accountId) async {
    try {
      var created =
          await _databaseRepository.createTransaction(transaction, accountId);
      return Result.success(created);
    } catch (error, stackTrace) {
      debugPrint("createTransaction() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  Future<Result<bool>> deleteTransaction(String transactionId) async {
    try {
      await _databaseRepository.deleteTransaction(transactionId);
      return Result.success(true);
    } catch (error, stackTrace) {
      debugPrint("deleteTransaction() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

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

  Future<Result<Transaction>> updateTransaction(Transaction transaction) async {
    try {
      var updated = await _databaseRepository.updateTransaction(transaction);
      return Result.success(updated);
    } catch (error, stackTrace) {
      debugPrint("updateTransaction() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }
}
