import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A service responsible for managing user accounts.
class AccountService {
  final AbstractDatabaseRepository _databaseRepository;
  late final Stream<List<Account>> _sharedAccountsStream;

  AccountService(this._databaseRepository) {
    _sharedAccountsStream = _getRetryStream(
      _databaseRepository.getAccountsStream(),
    );
  }

  /// Creates a new account with the given [accountName] and [startingBalance].
  ///
  /// Returns a [Result] containing the created [Account] on success,
  /// or an error if the operation fails.
  Future<Result<Account>> createAccount(
    String accountName,
    int startingBalance,
  ) async {
    try {
      var account = await _databaseRepository.createAccount(
        accountName: accountName,
        startingBalance: startingBalance,
      );
      return Result.success(account);
    } catch (error, stackTrace) {
      debugPrint("createAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  /// Deletes an account identified by the given [accountId].
  ///
  /// Returns a [Result] with `null` on success,
  /// or an error if the operation fails.
  Future<Result<void>> deleteAccount(String accountId) async {
    try {
      await _databaseRepository.deleteAccount(accountId);
      return Result.success(null);
    } catch (error, stackTrace) {
      debugPrint("deleteAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  /// Retrieves an account by its [accountId].
  ///
  /// Returns a [Result] containing the requested [Account] on success,
  /// or an error if the operation fails.
  Future<Result<Account>> getAccount(String accountId) async {
    try {
      var account = await _databaseRepository.getAccount(accountId);
      return Result.success(account);
    } catch (error, stackTrace) {
      debugPrint("getAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  Stream<Account> getAccountAsStream(String accountId) {
    return _getRetryStream(_databaseRepository.getAccountAsStream(accountId));
  }

  /// Retrieves a list of all user accounts.
  ///
  /// Returns a [Result] containing a list of [Account] objects on success,
  /// or an error if the operation fails.
  Stream<List<Account>> getAccounts() => _sharedAccountsStream;

  Stream<Balance> getTotalBalance() {
    return _sharedAccountsStream
        .map(
          (accounts) => Balance(
            current: accounts.fold(
              0,
              (currentBalance, account) =>
                  currentBalance + account.balance.current,
            ),
            available: accounts.fold(
              0,
              (availableBalance, account) =>
                  availableBalance + account.balance.available,
            ),
          ),
        )
        .distinct(
          (previous, next) =>
              previous.current == next.current &&
              previous.available == next.available,
        );
  }

  Stream<T> _getRetryStream<T>(
    Stream<T> stream, {
    Duration retryDelay = const Duration(seconds: 2),
  }) {
    return Rx.retryWhen(
      () => stream,
      (error, stackTrace) {
        if (error is RealtimeSubscribeException) {
          var status = error.status;
          if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.timedOut) {
            return Stream.value(null).delay(retryDelay);
          }
        }
        return Stream.error(error, stackTrace);
      },
    ).shareReplay(maxSize: 1);
  }
}
