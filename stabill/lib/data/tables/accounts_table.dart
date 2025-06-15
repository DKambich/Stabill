class AccountsTable {
  static const String tableName = 'accounts';

  static const String id = 'id';
  static const String userId = 'user_id';
  static const String name = 'name';
  static const String currentBalance = 'current_balance';
  static const String availableBalance = 'available_balance';
  static const String createdAt = 'created_at';
  static const String isArchived = 'is_archived';

  static List<String> get columns => [
        id,
        userId,
        name,
        currentBalance,
        availableBalance,
        createdAt,
        isArchived,
      ];
}
