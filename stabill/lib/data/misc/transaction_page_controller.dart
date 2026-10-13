import 'package:stabill/core/services/transaction/transaction_service.dart';
import 'package:stabill/data/misc/transaction_filter.dart';
import 'package:stabill/data/misc/transaction_pager.dart';
import 'package:stabill/data/models/transaction.dart';

class TransactionPageController {
  final TransactionService transactionService;
  late final TransactionPager _pager;

  TransactionPageController(this.transactionService, String accountId,
      {TransactionFilter? filter}) {
    _pager = transactionService.createPager(accountId, filter: filter);
  }

  Stream<List<Transaction>> get stream => _pager.stream;

  void dispose() => _pager.dispose();

  Future<void> loadNextPage() => _pager.loadNextPage();

  /// Reset the pager for a new filter, keeps subscription alive
  Future<void> reset({TransactionFilter? newFilter}) =>
      _pager.reset(newFilter: newFilter);
}
