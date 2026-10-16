import 'package:stabill/data/misc/transaction_filter.dart';
import 'package:stabill/data/misc/transaction_sort.dart';

class TransactionQuery {
  final TransactionFilter filter;
  final TransactionSort sort;
  final int pageSize;
  final int offset;

  const TransactionQuery({
    this.filter = const TransactionFilter(),
    this.sort = const TransactionSort(),
    this.pageSize = 25,
    this.offset = 0,
  });

  TransactionQuery copyWith({
    TransactionFilter? filter,
    TransactionSort? sort,
    int? pageSize,
    int? offset,
  }) {
    return TransactionQuery(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      pageSize: pageSize ?? this.pageSize,
      offset: offset ?? this.offset,
    );
  }
}
