import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:stabill/core/classes/result.dart';
import 'package:stabill/data/enums/transaction_category.dart';
import 'package:stabill/data/enums/transaction_type.dart';
import 'package:stabill/data/misc/transaction_change.dart';
import 'package:stabill/data/misc/transaction_filter.dart';
import 'package:stabill/data/misc/transaction_pager.dart';
import 'package:stabill/data/misc/transaction_query.dart';
import 'package:stabill/data/models/transaction.dart';

void main() {
  group('TransactionPager realtime changes', () {
    test('prioritizes uncleared transactions before newest cleared ones',
        () async {
      final source = [
        _transaction('cleared-newest', 10, isCleared: true),
        _transaction('uncleared-older', 2),
        _transaction('uncleared-newer', 5),
      ];
      final setup = _createPager(source, pageSize: 3);
      await setup.pager.loadNextPage();

      expect(
        await _ids(setup.pager),
        ['uncleared-newer', 'uncleared-older', 'cleared-newest'],
      );

      setup.pager.dispose();
      await setup.changes.close();
    });

    test('sorts inserts and keeps them inside the loaded window', () async {
      final source = [
        _transaction('newest', 3),
        _transaction('middle', 2),
        _transaction('oldest', 1),
      ];
      final setup = _createPager(source, pageSize: 2);
      await setup.pager.loadNextPage();

      setup.pager.applyLocalChange(
        TransactionChange(
          type: ChangeType.insert,
          transaction: _transaction('new-insert', 4),
        ),
      );
      expect(await _ids(setup.pager), ['new-insert', 'newest']);

      setup.pager.applyLocalChange(
        TransactionChange(
          type: ChangeType.insert,
          transaction: _transaction('old-insert', 0),
        ),
      );
      expect(await _ids(setup.pager), ['new-insert', 'newest']);

      setup.pager.dispose();
      await setup.changes.close();
    });

    test('repositions matching updates and removes deleted IDs', () async {
      final source = [
        _transaction('newest', 3),
        _transaction('middle', 2),
      ];
      final setup = _createPager(source, pageSize: 2);
      await setup.pager.loadNextPage();

      setup.pager.applyLocalChange(
        TransactionChange(
          type: ChangeType.update,
          transaction: _transaction('middle', 4),
        ),
      );
      expect(await _ids(setup.pager), ['middle', 'newest']);

      setup.pager.applyLocalChange(
        TransactionChange(
          type: ChangeType.delete,
          transaction: _transaction('newest', 3),
        ),
      );
      expect(await _ids(setup.pager), ['middle']);

      setup.pager.dispose();
      await setup.changes.close();
    });
  });
}

({TransactionPager pager, StreamController<TransactionChange> changes})
    _createPager(
  List<Transaction> source, {
  required int pageSize,
  TransactionFilter filter = const TransactionFilter(),
}) {
  final changes = StreamController<TransactionChange>();
  final pager = TransactionPager(
    accountId: 'account',
    query: TransactionQuery(filter: filter, pageSize: pageSize),
    getTransactions: ({
      required accountId,
      required query,
    }) async =>
        Result.success(
      source.skip(query.offset).take(query.pageSize).toList(),
    ),
    watchTransactions: (_) => changes.stream,
  );
  return (pager: pager, changes: changes);
}

Future<List<String?>> _ids(TransactionPager pager) =>
    pager.stream.first.then((transactions) =>
        transactions.map((transaction) => transaction.id).toList());

Transaction _transaction(
  String id,
  int day, {
  bool isCleared = false,
}) =>
    Transaction(
      id: id,
      name: id,
      amount: 100,
      transactionDate: DateTime.utc(2026, 10, day),
      transactionType: TransactionType.deposit,
      category: TransactionCategory.none,
      isCleared: isCleared,
      isArchived: false,
    );
