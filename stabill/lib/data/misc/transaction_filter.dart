class TransactionFilter {
  final String? searchText;
  final bool includeArchived;

  const TransactionFilter({
    this.searchText,
    this.includeArchived = false,
  });
}
