import 'package:stabill/data/models/balance.dart';
import 'package:stabill/data/tables/accounts_table.dart';

/// Represents a user's financial account.

class Account {
  /// Unique identifier for the account.
  final String? id;

  /// The name of the account.
  final String name;

  /// The current balance, including both cleared and pending transactions (stored in cents).
  final Balance? balance;

  /// The timestamp when the account was created.
  final DateTime? createdAt;

  /// Indicates whether the account is archived (inactive).
  final bool isArchived;

  Account({
    this.id,
    required this.name,
    this.balance,
    this.createdAt,
    required this.isArchived,
  });

  /// Creates an [Account] from a JSON object.
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json[AccountsTable.id] as String,
      name: json[AccountsTable.name] as String,
      balance: Balance(
        current: (json[AccountsTable.currentBalance] as num).toInt(),
        available: (json[AccountsTable.availableBalance] as num).toInt(),
      ),
      createdAt: DateTime.parse(json[AccountsTable.createdAt] as String),
      isArchived: json[AccountsTable.isArchived] as bool,
    );
  }

  /// Converts the [Account] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      AccountsTable.id: id,
      AccountsTable.name: name,
      AccountsTable.currentBalance: balance?.current,
      AccountsTable.availableBalance: balance?.available,
      AccountsTable.createdAt: createdAt?.toIso8601String(),
      AccountsTable.isArchived: isArchived,
    };
  }

  /// Returns a string representation of the [Account] instance.
  @override
  String toString() {
    return 'Account(id: $id, name: $name, balance: ${balance?.toString()}, createdAt: ${createdAt?.toIso8601String()}, archived: $isArchived)';
  }
}
