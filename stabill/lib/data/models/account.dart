/// Represents a user's financial account.
class Account {
  /// Unique identifier for the account.
  final String id;

  /// The name of the account.
  final String name;

  /// The current balance, including both cleared and pending transactions (stored in cents).
  final int currentBalance;

  /// The available balance, excluding pending transactions (stored in cents).
  final int availableBalance;

  /// The timestamp when the account was created.
  final DateTime createdAt;

  /// Indicates whether the account is archived (inactive).
  final bool archived;

  Account({
    required this.id,
    required this.name,
    required this.currentBalance,
    required this.availableBalance,
    required this.createdAt,
    required this.archived,
  });

  /// Creates an [Account] from a JSON object.
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String,
      name: json['name'] as String,
      currentBalance: json['current_balance'] as int,
      availableBalance: json['available_balance'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      archived: json['is_archived'] as bool,
    );
  }

  /// Converts the [Account] instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'current_balance': currentBalance,
      'available_balance': availableBalance,
      'created_at': createdAt.toIso8601String(),
      'archived': archived,
    };
  }

  /// Returns a string representation of the [Account] instance.
  @override
  String toString() {
    return 'Account('
        'id: $id, '
        'name: $name, '
        'currentBalance: ${currentBalance / 100}, '
        'availableBalance: ${availableBalance / 100}, '
        'createdAt: ${createdAt.toIso8601String()}, '
        'archived: $archived'
        ')';
  }
}
