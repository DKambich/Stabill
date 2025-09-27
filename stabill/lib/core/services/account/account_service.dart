import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/models/account.dart';
import 'package:stabill/data/models/balance.dart';
import 'package:stabill/data/repository/abstract_database_repository.dart';
import 'package:stabill/utils/lazy_subject.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A service responsible for managing user accounts.
class AccountService {
  final AbstractDatabaseRepository _databaseRepository;

  late final LazySubject<List<Account>> _accountsLazy;
  final Map<String, LazySubject<Account>> _accountLazy = {};

  AccountService(this._databaseRepository) {
    _accountsLazy = LazySubject(
      () => _getRetryStream(_databaseRepository.getAccountsStream()),
    );
  }

  /// Creates a new account with the given [accountName] and [startingBalance].
  Future<Result<Account>> createAccount(
    String accountName,
    int startingBalance,
  ) async {
    try {
      var account = await _databaseRepository.createAccount(
        Account(
          name: accountName,
          balance: Balance(
            current: startingBalance,
            available: startingBalance,
          ),
          isArchived: false,
        ),
      );
      return Result.success(account);
    } catch (error, stackTrace) {
      debugPrint("createAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  Future<Result<void>> deleteAccount(String accountId) async {
    try {
      await _databaseRepository.deleteAccount(accountId);
      return Result.success(null);
    } catch (error, stackTrace) {
      debugPrint("deleteAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  /// Clean up subjects when no longer needed.
  Future<void> dispose() async {
    await _accountsLazy.dispose();
    for (var lazy in _accountLazy.values) {
      await lazy.dispose();
    }
  }

  Future<Result<Account>> getAccount(String accountId) async {
    try {
      var account = await _databaseRepository.getAccount(accountId);
      return Result.success(account);
    } catch (error, stackTrace) {
      debugPrint("getAccount() failed: $error\n$stackTrace");
      return Result.failure(error);
    }
  }

  /// Watch a single account reactively.
  Stream<Account> watchAccount(String accountId) {
    if (_accountLazy.containsKey(accountId)) {
      return _accountLazy[accountId]!.stream;
    }
    final lazy = LazySubject(
      () => _getRetryStream(_databaseRepository.getAccountAsStream(accountId)),
    );
    _accountLazy[accountId] = lazy;
    return lazy.stream;
  }

  /// Watch all accounts reactively.
  Stream<List<Account>> watchAccounts() => _accountsLazy.stream;

  /// Watch the total balance across all accounts reactively.
  Stream<Balance> watchTotalBalance() {
    return _accountsLazy.stream
        .map(
          (accounts) => Balance(
            current: accounts.fold(
              0,
              (curr, acc) => curr + (acc.balance?.current ?? 0),
            ),
            available: accounts.fold(
              0,
              (avail, acc) => avail + (acc.balance?.available ?? 0),
            ),
          ),
        )
        .distinct(
          (prev, next) =>
              prev.current == next.current && prev.available == next.available,
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
    );
  }
}
