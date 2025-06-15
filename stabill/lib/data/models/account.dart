import 'package:stabill/data/models/balance.dart';

/// Represents a user's financial account.
class Account {
  /// Unique identifier for the account.
  final String id;

  /// The name of the account.
  final String name;

  /// The current balance, including both cleared and pending transactions (stored in cents).
  final Balance balance;

  /// The timestamp when the account was created.
  final DateTime createdAt;

  /// Indicates whether the account is archived (inactive).
  final bool archived;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.createdAt,
    required this.archived,
  });

  /// Creates an [Account] from a JSON object.
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      balance: Balance(
        current: (json['current_balance'] as num).toInt(),
        available: (json['available_balance'] as num).toInt(),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      archived: json['is_archived'] as bool,
    );
  }

  /// Converts the [Account] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'current_balance': balance.current,
      'available_balance': balance.available,
      'created_at': createdAt.toIso8601String(),
      'archived': archived,
    };
  }

  /// Returns a string representation of the [Account] instance.
  @override
  String toString() {
    return 'Account(id: $id, name: $name, balance: ${balance.toString()}, createdAt: ${createdAt.toIso8601String()}, archived: $archived)';
  }
}
