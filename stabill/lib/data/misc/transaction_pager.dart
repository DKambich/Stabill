import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/misc/transaction_change.dart';
import 'package:stabill/data/misc/transaction_filter.dart';
import 'package:stabill/data/models/transaction.dart';

class TransactionPager {
  final String accountId;
  TransactionFilter filter;
  final int pageSize;

  final Future<Result<List<Transaction>>> Function({
    required String accountId,
    required int pageSize,
    required int pageIndex,
    TransactionFilter? filter,
  }) getTransactions;

  final Stream<TransactionChange> Function(String accountId) watchTransactions;

  int _pageIndex = 0;
  final List<Transaction> _cache = [];
  final _controller = BehaviorSubject<List<Transaction>>();
  late final StreamSubscription _sub;

  TransactionPager({
    required this.accountId,
    required this.getTransactions,
    required this.watchTransactions,
    this.filter = const TransactionFilter(),
    this.pageSize = 20,
  }) {
    // Subscribe once, never unsubscribed on filter changes
    _sub = watchTransactions(accountId).listen(_applyChange);
  }

  Stream<List<Transaction>> get stream => _controller.stream;

  void dispose() {
    _sub.cancel();
    _controller.close();
  }

  Future<void> loadNextPage() async {
    final newTxns = await getTransactions(
      accountId: accountId,
      pageSize: pageSize,
      pageIndex: _pageIndex,
      filter: filter,
    );
    _pageIndex++;
    _cache.addAll(newTxns.data ?? []);
    _controller.add(List.unmodifiable(_cache));
  }

  /// Reset the pager but keep the subscription
  Future<void> reset({TransactionFilter? newFilter}) async {
    _cache.clear();
    _pageIndex = 0;
    if (newFilter != null) filter = newFilter;
    await loadNextPage();
  }

  void _applyChange(TransactionChange change) {
    // Only insert/update transactions if they match the current filter
    if (!_matchesFilter(change.transaction)) return;

    switch (change.type) {
      case ChangeType.insert:
        _cache.insert(0, change.transaction); // could adjust for ordering
        break;
      case ChangeType.update:
        final idx = _cache.indexWhere((t) => t.id == change.transaction.id);
        if (idx >= 0) {
          _cache[idx] = change.transaction;
        } else {
          _cache.insert(0, change.transaction);
        }
        break;
      case ChangeType.delete:
        _cache.removeWhere((t) => t.id == change.transaction.id);
        break;
    }

    _controller.add(List.unmodifiable(_cache));
  }

  bool _matchesFilter(Transaction txn) {
    // Only client-side filters like search text
    if (filter.searchText?.isNotEmpty ?? false) {
      if (!txn.name.toLowerCase().contains(filter.searchText!.toLowerCase())) {
        return false;
      }
    }
    return true;
  }
}
