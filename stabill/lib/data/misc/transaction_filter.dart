import 'package:stabill/data/enums/transaction_category.dart';

class TransactionFilter {
  final String? searchText;
  final bool includeArchived;
  final Set<TransactionCategory> categories;

  const TransactionFilter({
    this.searchText,
    this.includeArchived = false,
    this.categories = const {},
  });
}
