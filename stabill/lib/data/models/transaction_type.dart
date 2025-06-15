/// Enum representing the type of a transaction.
enum TransactionType {
  deposit,
  withdrawal,
  voided;

  /// Returns a user-friendly label for display purposes.
  String get label {
    switch (this) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.voided:
        return 'Voided';
    }
  }

  /// Converts a [TransactionType] to its corresponding Supabase string value.
  String toJson() => name;

  /// Creates a [TransactionType] from its Supabase string representation.
  static TransactionType fromJson(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: $value'),
    );
  }
}
