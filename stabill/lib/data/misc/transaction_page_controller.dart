import 'package:stabill/core/services/transaction/transaction_service.dart';
import 'package:stabill/data/misc/transaction_pager.dart';
import 'package:stabill/data/misc/transaction_query.dart';
import 'package:stabill/data/models/transaction.dart';

class TransactionPageController {
  final TransactionService transactionService;
  late final TransactionPager _pager;

  TransactionPageController(this.transactionService, String accountId,
      {TransactionQuery query = const TransactionQuery()}) {
    _pager = transactionService.createPager(accountId, query: query);
  }

  Stream<List<Transaction>> get stream => _pager.stream;

  void dispose() => _pager.dispose();

  Future<void> loadNextPage() => _pager.loadNextPage();

  /// Reset the pager for a new query, keeping the subscription alive.
  Future<void> reset({TransactionQuery? newQuery}) =>
      _pager.reset(newQuery: newQuery);
}
