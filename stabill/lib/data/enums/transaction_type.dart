import 'package:flutter/material.dart';

/// Enum representing the type of a transaction.
enum TransactionType {
  deposit,
  withdrawal,
  voided;

  IconData get icon {
    switch (this) {
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.voided:
        return Icons.cancel;
    }
  }

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

  int get sortOrder {
    switch (this) {
      case TransactionType.deposit:
        return 0;
      case TransactionType.withdrawal:
        return 1;
      case TransactionType.voided:
        return 2;
    }
  }

  /// Supabase string
  String toJson() => name;

  /// From Supabase string
  static TransactionType fromJson(String value) {
    return TransactionType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => throw ArgumentError('Unknown TransactionType: $value'),
    );
  }
}
