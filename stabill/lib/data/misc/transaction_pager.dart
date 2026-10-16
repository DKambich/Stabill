import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/misc/transaction_change.dart';
import 'package:stabill/data/misc/transaction_query.dart';
import 'package:stabill/data/models/transaction.dart';

class TransactionPager {
  final String accountId;
  TransactionQuery query;

  final Future<Result<List<Transaction>>> Function({
    required String accountId,
    required TransactionQuery query,
  }) getTransactions;

  final Stream<TransactionChange> Function(String accountId) watchTransactions;

  final List<Transaction> _cache = [];
  final _controller = BehaviorSubject<List<Transaction>>();
  late final StreamSubscription _sub;
  final void Function()? onStateChanged;
  int _generation = 0;
  int _pagesFetched = 0;
  bool hasMore = true;
  bool isLoading = false;
  Object? loadError;

  TransactionPager({
    required this.accountId,
    required this.getTransactions,
    required this.watchTransactions,
    this.query = const TransactionQuery(),
    this.onStateChanged,
  }) {
    // Subscribe once, never unsubscribed on filter changes
    _sub = watchTransactions(accountId).listen(_applyChange);
  }

  Stream<List<Transaction>> get stream => _controller.stream;

  int get _loadedWindowCapacity =>
      (_pagesFetched + (_pagesFetched == 0 && isLoading ? 1 : 0)) *
      query.pageSize;

  void applyLocalChange(TransactionChange change) => _applyChange(change);

  void dispose() {
    unawaited(_sub.cancel());
    unawaited(_controller.close());
  }

  Future<void> loadNextPage() async {
    if (isLoading || !hasMore) return;

    final generation = _generation;
    isLoading = true;
    loadError = null;
    onStateChanged?.call();

    try {
      final result = await getTransactions(
        accountId: accountId,
        query: query.copyWith(offset: query.offset + _cache.length),
      );
      if (generation != _generation) return;
      if (result.isFailure) {
        loadError = result.error;
        return;
      }

      final newTransactions = result.data ?? [];
      for (final transaction in newTransactions) {
        final index = _cache.indexWhere((item) => item.id == transaction.id);
        if (index == -1) {
          _cache.add(transaction);
        } else {
          _cache[index] = transaction;
        }
      }
      _pagesFetched++;
      hasMore = newTransactions.length == query.pageSize;
      _cache.sort(_compareTransactions);
      _trimToLoadedWindow();
      _controller.add(List.unmodifiable(_cache));
    } catch (error) {
      if (generation == _generation) loadError = error;
    } finally {
      if (generation == _generation) {
        isLoading = false;
        onStateChanged?.call();
      }
    }
  }

  Future<void> reset({TransactionQuery? newQuery}) async {
    _generation++;
    _cache.clear();
    _pagesFetched = 0;
    hasMore = true;
    isLoading = false;
    loadError = null;
    if (newQuery != null) query = newQuery;
    _controller.add(const []);
    onStateChanged?.call();
    await loadNextPage();
  }

  void _applyChange(TransactionChange change) {
    final existingIndex = _cache.indexWhere(
      (transaction) => transaction.id == change.transaction.id,
    );
    final matchesFilter = _matchesFilter(change.transaction);
    var changed = false;

    switch (change.type) {
      case ChangeType.insert:
        if (!matchesFilter) return;
        if (existingIndex >= 0) _cache.removeAt(existingIndex);
        changed = _insertWithinLoadedWindow(change.transaction);
        break;
      case ChangeType.update:
        if (existingIndex >= 0) {
          _cache.removeAt(existingIndex);
          changed = true;
        }
        if (matchesFilter) {
          changed = _insertWithinLoadedWindow(change.transaction) || changed;
        }
        break;
      case ChangeType.delete:
        if (existingIndex >= 0) {
          _cache.removeAt(existingIndex);
          changed = true;
        }
        break;
    }

    if (!changed) return;
    _controller.add(List.unmodifiable(_cache));
    onStateChanged?.call();
  }

  int _compareTransactions(Transaction left, Transaction right) {
    // TODO: Resolve uncleared-first from the user's saved sort preference.
    if (query.sort.unclearedFirst && left.isCleared != right.isCleared) {
      return left.isCleared ? 1 : -1;
    }

    final dateComparison = query.sort.dateDescending
        ? right.transactionDate.compareTo(left.transactionDate)
        : left.transactionDate.compareTo(right.transactionDate);
    if (dateComparison != 0) return dateComparison;
    return (right.id ?? '').compareTo(left.id ?? '');
  }

  bool _insertWithinLoadedWindow(Transaction transaction) {
    var insertionIndex = _cache.indexWhere(
      (existing) => _compareTransactions(transaction, existing) < 0,
    );
    if (insertionIndex == -1) insertionIndex = _cache.length;

    if (insertionIndex == _cache.length &&
        _cache.length >= _loadedWindowCapacity) {
      return false;
    }

    _cache.insert(insertionIndex, transaction);
    _trimToLoadedWindow();
    return _cache.contains(transaction);
  }

  bool _matchesFilter(Transaction txn) {
    if (!query.filter.includeArchived && txn.isArchived) return false;

    final search = query.filter.searchText?.trim().toLowerCase() ?? '';
    if (search.isEmpty) return true;

    return txn.name.toLowerCase().contains(search) ||
        (txn.memo?.toLowerCase().contains(search) ?? false) ||
        txn.category.label.toLowerCase().contains(search) ||
        txn.category.name.toLowerCase().contains(search) ||
        txn.transactionType.label.toLowerCase().contains(search) ||
        txn.transactionType.name.toLowerCase().contains(search);
  }

  void _trimToLoadedWindow() {
    final overflow = _cache.length - _loadedWindowCapacity;
    if (overflow > 0) _cache.removeRange(_loadedWindowCapacity, _cache.length);
  }
}
