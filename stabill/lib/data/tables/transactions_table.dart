class TransactionsTable {
  static const String tableName = 'transactions';

  static const String id = 'id';
  static const String accountId = 'account_id';
  static const String name = 'name';
  static const String createdAt = 'created_at';
  static const String amount = 'amount';
  static const String transactionDate = 'transaction_date';
  static const String transactionType = 'transaction_type';
  static const String transactionCategory = 'transaction_category';
  static const String checkNumber = 'check_number';
  static const String memo = 'memo';
  static const String isCleared = 'is_cleared';
  static const String isArchived = 'is_archived';

  static List<String> get columns => [
        id,
        accountId,
        name,
        createdAt,
        amount,
        transactionDate,
        transactionType,
        transactionCategory,
        checkNumber,
        memo,
        isCleared,
        isArchived
      ];
}
